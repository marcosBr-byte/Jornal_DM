module Admin
  class CommentsController < BaseController
    def index
      @comments = Comment.joins(:article).where(articles: { environment: allowed_environments }).includes(:article).order(created_at: :desc)
      @comments = @comments.where(articles: { environment: params[:environment] }) if allowed_environments.include?(params[:environment])
      @comments = @comments.where(status: params[:status]) if Comment.statuses.key?(params[:status])
      @page = [ params[:page].to_i, 1 ].max
      @comments = @comments.limit(30).offset((@page - 1) * 30)
    end
    def update
      comment = scoped_comments.find(params[:id])
      if comment.update(params.require(:comment).permit(:status))
        redirect_to admin_comments_path, notice: "Moderação salva.", status: :see_other
      else
        redirect_to admin_comments_path, alert: comment.errors.full_messages.to_sentence, status: :see_other
      end
    end
    def destroy
      scoped_comments.find(params[:id]).destroy!
      redirect_to admin_comments_path, notice: "Comentário excluído.", status: :see_other
    end
    private
    def scoped_comments
      Comment.joins(:article).where(articles: { environment: allowed_environments })
    end
  end
end
