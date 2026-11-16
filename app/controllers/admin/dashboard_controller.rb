module Admin
  class DashboardController < BaseController
    def index
      @published_count = editorial_scope(Article).published.count
      @featured_count = editorial_scope(Article).published.where(featured: true).count
      @category_count = editorial_scope(Article).published.distinct.count(:category)
      @reads_count = editorial_scope(Article).sum(:reads_count)
      @draft_count = editorial_scope(Article).draft.count
      @article = current_user.articles.new(author: "Redação Jornal DM", environment: allowed_environments.first)
      @articles = editorial_scope(Article).with_attached_cover.order(updated_at: :desc).limit(20)
    end
  end
end
