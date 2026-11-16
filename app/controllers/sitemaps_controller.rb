class SitemapsController < ApplicationController
  def show
    @articles = Article.publicly_visible.select(:id, :title, :environment, :updated_at).order(:id).limit(45000)
    render formats: :xml
  end
end
