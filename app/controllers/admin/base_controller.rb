module Admin
  class BaseController < ApplicationController
    layout "admin"
    before_action :authenticate_user!
    before_action :require_admin
    before_action :verification_notice
    def verification_notice
      @verified_login = session.delete(:verified_login)
    end
    helper_method :allowed_environments
    private
    def allowed_environments
      current_user.allowed_environments
    end
    def editorial_scope(model)
      scope = model.where(environment: allowed_environments)
      allowed_environments.include?(params[:environment]) ? scope.where(environment: params[:environment]) : scope
    end
    def authorize_environment!(record)
      raise ActiveRecord::RecordNotFound unless allowed_environments.include?(record.environment)
    end

    def require_admin
      render plain: "Você não tem permissão para acessar esta área.", status: :forbidden unless current_user.editorial_access?
    end
  end
end
