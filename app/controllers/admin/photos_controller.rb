module Admin
  class PhotosController < BaseController
    def index
      @selectable_articles = editorial_scope(Article).select(:id, :title, :environment).order(:title).group_by(&:environment)
      @selectable_events = editorial_scope(Event).select(:id, :title, :environment).order(:title).group_by(&:environment)
      @page = [ params[:page].to_i, 1 ].max
      @photos = editorial_scope(PhotoSubmission).with_attached_image.order(created_at: :desc)
      @photos = @photos.where(status: params[:status]) if PhotoSubmission.statuses.key?(params[:status])
      @photos = @photos.limit(24).offset((@page - 1) * 24)
    end
    def show
      photo = editorial_scope(PhotoSubmission).find(params[:id])
      response.headers["Cache-Control"] = "private, no-store"
      response.headers["X-Content-Type-Options"] = "nosniff"
      send_data photo.image.download, type: "image/webp", disposition: "inline"
    rescue ActiveStorage::FileNotFoundError
      head :not_found
    end
    def update
      photo = editorial_scope(PhotoSubmission).find(params[:id])
      attributes = params.require(:photo_submission).permit(:status, :caption, :album, :article_id, :event_id)
      if attributes[:status] == "published" && !photo.status.in?(%w[approved published])
        return redirect_to admin_photos_path, alert: "Aprove a fotografia antes de publicar.", status: :see_other
      end
      if photo.update(attributes)
        redirect_to admin_photos_path, notice: "Fotografia atualizada.", status: :see_other
      else
        redirect_to admin_photos_path, alert: photo.errors.full_messages.to_sentence, status: :see_other
      end
    end
    def destroy
      photo = editorial_scope(PhotoSubmission).find(params[:id])
      photo.image.purge
      photo.destroy!
      redirect_to admin_photos_path, notice: "Fotografia excluída.", status: :see_other
    end
  end
end
