class CoversController < ApplicationController
  def show
    # Never cache a draft or keep a published image after it is unpublished.
    response.headers["Cache-Control"] = "private, no-store, max-age=0"
    response.headers["X-Content-Type-Options"] = "nosniff"
    scope = Article.publicly_visible
    if current_user&.editorial_access?
      scope = Article.publicly_visible.or(Article.where(environment: current_user.allowed_environments))
    end
    article = scope.in_environment(current_environment).find(params[:id])
    cover = article.cover
    return head :not_found unless cover.attached?
    return head :not_found unless Article::COVER_CONTENT_TYPES.include?(cover.content_type)

    bytes, content_type = EditorialImage.bytes(cover, params[:size])
    send_data bytes,
      type: content_type,
      disposition: "inline",
      filename: cover.filename.to_s
  rescue ActiveStorage::FileNotFoundError
    head :not_found
  end
end
