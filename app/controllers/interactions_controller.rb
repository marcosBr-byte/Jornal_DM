class InteractionsController < ApplicationController
  include ReaderIdentity
  before_action :set_article
  rate_limit to: 40, within: 5.minutes, only: :like, store: AUTH_RATE_LIMIT_STORE
  rate_limit to: 5, within: 10.minutes, only: [ :comment, :report ], store: AUTH_RATE_LIMIT_STORE
  def like
    digest = reader_digest
    liked = false
    @article.with_lock do
      existing = @article.likes.find_by(visitor_digest: digest)
      if existing
        existing.destroy!
      else
        @article.likes.create!(visitor_digest: digest)
        liked = true
      end
    end
    render json: { liked: liked, count: @article.likes.count }
  end
  def comment
    return head :unprocessable_entity if params[:website].present?
    comment = @article.comments.new(params.require(:comment).permit(:name, :body).merge(status: :approved))
    if comment.save
      redirect_to editorial_article_path(@article), notice: "Comentário publicado! Termos inadequados são removidos automaticamente.", status: :see_other
    else
      redirect_to editorial_article_path(@article), alert: comment.errors.full_messages.to_sentence, status: :see_other
    end
  end
  def report
    comment = @article.comments.approved.find(params[:comment_id])
    key = "reported_comment_#{comment.id}"
    unless session[key]
      comment.increment!(:reports_count)
      session[key] = true
    end
    redirect_to editorial_article_path(@article), notice: "Denúncia recebida para análise.", status: :see_other
  end
  private
  def set_article
    @article = Article.in_environment(current_environment).publicly_visible.find(params[:id])
  end
end
