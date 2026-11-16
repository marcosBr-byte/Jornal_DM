class ArticlesController < ApplicationController
  include ReaderIdentity
  def index
    @most_commented = Article.most_commented(current_environment)
    @articles = Article.in_environment(current_environment).publicly_visible.with_attached_cover.editorial_order
    @articles = @articles.where(category: params[:category]) if Article.category_names(current_environment).include?(params[:category])
    if params[:q].present?
      query = "%#{Article.sanitize_sql_like(params[:q].to_s.first(200))}%"
      @articles = @articles.where("title ILIKE :q OR summary ILIKE :q OR body ILIKE :q OR author ILIKE :q", q: query)
    end
    @articles = @articles.reorder(published_at: :desc, id: :desc) if params[:sort] == "recent"
    @articles = @articles.reorder(published_at: :asc, id: :asc) if params[:sort] == "oldest"
    @page = [ params[:page].to_i, 1 ].max
    @has_next = @articles.offset(@page * 12).exists?
    @articles = @articles.limit(12).offset((@page - 1) * 12)
  end
  def show
    @article = Article.in_environment(current_environment).publicly_visible.with_attached_cover.find(params[:id])
    digest = reader_digest
    ArticleReading.record(@article, digest) unless request.headers["X-Live-Update"] == "true"
    @liked = digest.present? && @article.likes.exists?(visitor_digest: digest)
    @photos = @article.photo_submissions.published.with_attached_image
    @comments = @article.comments.approved.order(created_at: :asc).limit(100)
    @related = Article.in_environment(current_environment).publicly_visible.where(category: @article.category).where.not(id: @article.id).editorial_order.limit(3)
  end
end
