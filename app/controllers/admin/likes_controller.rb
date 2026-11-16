module Admin
  class LikesController < BaseController
    def index
      @articles = editorial_scope(Article).left_joins(:likes).group("articles.id").select("articles.*, COUNT(likes.id) AS likes_total").order(Arel.sql("COUNT(likes.id) DESC")).limit(100)
    end
  end
end
