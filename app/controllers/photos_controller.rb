class PhotosController < ApplicationController
  rate_limit to: 5, within: 10.minutes, only: :create, store: AUTH_RATE_LIMIT_STORE
  before_action :check_storage, only: [ :new, :create ]
  def index
    @page = [ params[:page].to_i, 1 ].max
    @photos = PhotoSubmission.in_environment(current_environment).published.with_attached_image.order(created_at: :desc)
    @albums = @photos.where.not(album: [ nil, "" ]).reorder(:album).distinct.pluck(:album)
    @photos = @photos.where(album: params[:album]) if params[:album].present?
    @photos = @photos.limit(24).offset((@page - 1) * 24)
  end
  def show
    photo = PhotoSubmission.in_environment(current_environment).published.find(params[:id])
    response.headers["Cache-Control"] = "private, no-store"
    response.headers["X-Content-Type-Options"] = "nosniff"
    bytes, content_type = EditorialImage.bytes(photo.image, params[:size])
    send_data bytes, type: content_type, disposition: "inline"
  rescue ActiveStorage::FileNotFoundError
    head :not_found
  end
  def new; end
  def create
    return head :unprocessable_entity if params[:website].present?
    unless params[:consent] == "1"
      flash.now[:alert] = "Confirme a autorização de envio das imagens."
      return render :new, status: :unprocessable_entity
    end
    uploads = Array(params[:images]).reject(&:blank?)
    unless uploads.size.between?(1, 8)
      flash.now[:alert] = "Selecione de 1 a 8 fotografias."
      return render :new, status: :unprocessable_entity
    end
    contributor = params[:contributor].to_s.strip
    raise PhotoOptimizer::InvalidImage, "O nome deve ter até 80 caracteres." if contributor.length > 80
    # Decode the entire batch before uploading; an invalid image never causes a partial submission.
    processed = uploads.map { |upload| PhotoOptimizer.call(upload) }
    processed = processed.uniq { |result| result[:fingerprint] }.reject { |result| PhotoSubmission.in_environment(current_environment).exists?(fingerprint: result[:fingerprint]) }
    blobs = []
    begin
      PhotoSubmission.transaction do
        processed.each do |result|
          blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new(result[:bytes]), filename: "fotografia.webp", content_type: "image/webp")
          blobs << blob
          photo = PhotoSubmission.new(environment: current_environment, contributor: contributor, **result.except(:bytes))
          photo.image.attach(blob)
          photo.save!
        end
      end
    rescue StandardError
      blobs.each(&:purge)
      raise
    end
    flash[:notice] = processed.empty? ? "As fotografias selecionadas já foram recebidas neste ambiente." : "#{processed.size} fotografia(s) recebida(s)! A equipe avaliará antes de publicar."
    respond_to do |format|
      format.html { redirect_to request.path, status: :see_other }
      format.json { render json: { redirect: request.path }, status: :created }
    end
  rescue PhotoOptimizer::InvalidImage => error
    respond_to do |format|
      format.html { flash.now[:alert] = error.message; render :new, status: :unprocessable_entity }
      format.json { render json: { error: error.message }, status: :unprocessable_entity }
    end
  end
  private
  def check_storage
    setting = SiteSetting.find_by(environment: current_environment)
    if setting && !setting.uploads_enabled?
      return render plain: "O recebimento de fotografias deste ambiente está temporariamente fechado.", status: :service_unavailable
    end
    return unless Rails.env.production? && !ENV["ACTIVE_STORAGE_SERVICE"].in?(%w[amazon r2])
    render plain: "O envio de fotografias aguarda a configuração de armazenamento externo persistente.", status: :service_unavailable
  end
end
