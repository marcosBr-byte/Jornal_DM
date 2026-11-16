module Admin
  class SettingsController < BaseController
    def index
      @settings = allowed_environments.map { |value| SiteSetting.find_or_create_by!(environment: value) }
    end
    def update
      setting = editorial_scope(SiteSetting).find(params[:id])
      setting.update!(params.require(:site_setting).permit(:uploads_enabled))
      redirect_to admin_settings_path, notice: "Configurações salvas.", status: :see_other
    end
  end
end
