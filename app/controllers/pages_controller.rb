class PagesController < ApplicationController
  def home
    load_newsroom
  end
  def fect
    load_newsroom
    render :fect
  end
  def school; end
  def agenda
    @events = Event.in_environment(current_environment)
    @events = params[:period] == "past" ? @events.where(starts_at: ...Time.current).order(starts_at: :desc) : @events.where(starts_at: Time.current..).order(:starts_at)
    @events = @events.with_attached_image.limit(100)
    @articles = Article.in_environment(current_environment).publicly_visible.where(category: [ "Eventos", "Avisos" ]).editorial_order.limit(20).with_attached_cover
  end
  private
  def load_newsroom
    scope = Article.in_environment(current_environment).publicly_visible
    @articles = scope.with_attached_cover.order(published_at: :desc, id: :desc).limit(9)
    @highlights = scope.where(featured: true).with_attached_cover.editorial_order.limit(6).load
    @ticker = scope.editorial_order.limit(8).load
    @most_commented = Article.most_commented(current_environment)
  end
end
