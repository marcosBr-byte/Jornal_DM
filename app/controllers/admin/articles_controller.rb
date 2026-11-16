module Admin
  class ArticlesController < BaseController
    before_action :set_article, only: [ :edit, :update, :destroy, :publish ]
    rescue_from PhotoOptimizer::InvalidImage do |error|
      redirect_to admin_articles_path, alert: error.message, status: :see_other
    end
    rescue_from ActiveRecord::StaleObjectError do
      redirect_to admin_articles_path, alert: "A notícia foi alterada por outra pessoa. Abra novamente antes de salvar."
    end
    def index
      @published_count = editorial_scope(Article).published.count
      @draft_count = editorial_scope(Article).draft.count
      @page = [ params[:page].to_i, 1 ].max
      @articles = editorial_scope(Article).with_attached_cover.order(updated_at: :desc).limit(20).offset((@page - 1) * 20)
    end
    def new
      @article = current_user.articles.new(author: "Redação Jornal DM", environment: allowed_environments.first)
    end
    def create
      @article = current_user.articles.new({ environment: allowed_environments.first }.merge(article_params))
      persist(:new)
    end
    def edit; end
    def update
      if article_params[:environment].present? && article_params[:environment] != @article.environment && (@article.comments.exists? || @article.likes.exists? || @article.photo_submissions.exists?)
        return redirect_to edit_admin_article_path(@article), alert: "Esta notícia já tem interações. Preserve o ambiente de publicação.", status: :see_other
      end
      @article.assign_attributes(article_params)
      persist(:edit)
    end
    def destroy
      @article.destroy!
      redirect_to admin_articles_path, notice: "Publicação excluída.", status: :see_other
    end
    def publish
      @article.update!(status: :published)
      redirect_to admin_articles_path, notice: "Notícia publicada.", status: :see_other
    end
    def preview
      @article = current_user.articles.new(article_params.except(:cover))
      authorize_environment!(@article)
      @article.valid?
      render :preview
    end
    private
    def set_article
      @article = editorial_scope(Article).find(params[:id])
    end
    def article_params
      @permitted_article_params ||= begin
        attributes = params.require(:article).permit(:environment, :title, :summary, :body, :body_format, :author, :category, :published_at, :featured, :cover, :lock_version).to_h.symbolize_keys
        if attributes[:cover].present? && action_name != "preview"
          if Rails.env.production? && !ENV["ACTIVE_STORAGE_SERVICE"].in?(%w[amazon r2])
            raise PhotoOptimizer::InvalidImage, "Configure S3 ou R2 para enviar novas imagens. As capas existentes foram preservadas."
          end
          result = PhotoOptimizer.call(attributes[:cover])
          attributes[:cover] = { io: StringIO.new(result[:bytes]), filename: "capa.webp", content_type: "image/webp", metadata: result.except(:bytes) }
        end
        attributes
      end
    end
    def persist(template)
      authorize_environment!(@article)
      @article.status = params[:intent] == "publish" ? :published : :draft
      if @article.save
        redirect_to admin_articles_path, notice: "Publicação salva.", status: :see_other
      else
        render template, status: :unprocessable_entity
      end
    end
  end
end
