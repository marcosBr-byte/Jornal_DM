class ApplicationController < ActionController::Base
  AUTH_RATE_LIMIT_STORE = Rails.env.test? ? ActiveSupport::Cache::MemoryStore.new : Rails.cache

  helper_method :current_environment, :environment_name, :editorial_article_path, :editorial_articles_path, :editorial_cover_path
  def current_environment
    request.path.start_with?("/fect") ? "fect" : "dm"
  end
  def environment_name
    EditorialEnvironment::ENVIRONMENTS.fetch(current_environment)
  end
  def editorial_article_path(article)
    article.environment == "fect" ? fect_article_path(article) : article_path(article)
  end
  def editorial_cover_path(article, **options)
    options = { v: article.updated_at&.utc&.strftime("%Y%m%d%H%M%S%6N") }.merge(options)
    article.environment == "fect" ? cover_fect_article_path(article, **options) : cover_article_path(article, **options)
  end
  def editorial_articles_path(**options)
    current_environment == "fect" ? fect_articles_path(**options) : articles_path(**options)
  end

  before_action do
    response.headers["Cache-Control"] = "private, no-store" if request.headers["X-Live-Update"] == "true"
  end

  layout -> { devise_controller? ? "authentication" : "application" }
  def after_sign_in_path_for(resource)
    session[:verified_login] = true
    resource.editorial_access? ? admin_root_path : root_path
  end

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
