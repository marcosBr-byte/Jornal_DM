module Admin
  class UsersController < BaseController
    before_action :require_general_admin
    def index
      @users = User.order(:id).limit(100)
    end
    def create
      user = User.new(params.require(:user).permit(:email, :password, :editor_environment))
      user.editor_environment = nil if user.editor_environment.blank?
      if user.save
        redirect_to admin_users_path, notice: "Usuário criado.", status: :see_other
      else
        redirect_to admin_users_path, alert: user.errors.full_messages.to_sentence, status: :see_other
      end
    end
    def update
      user = User.find(params[:id])
      submitted = params.require(:user)
      attributes = submitted.permit(:editor_environment)
      requested_admin = submitted.key?(:admin) ? ActiveModel::Type::Boolean.new.cast(submitted[:admin]) : user.admin?
      attributes[:editor_environment] = nil if attributes[:editor_environment].blank?
      unless attributes[:editor_environment].nil? || attributes[:editor_environment].in?(%w[dm fect])
        return head :unprocessable_entity
      end
      User.transaction do
        # Serialize role changes so simultaneous requests cannot remove every administrator.
        admins = User.where(admin: true).order(:id).lock.to_a
        user.lock!
        if user.admin? && !requested_admin && admins.size <= 1
          return redirect_to admin_users_path, alert: "Mantenha pelo menos um administrador geral.", status: :see_other
        end
        user.assign_attributes(attributes)
        user.admin = requested_admin
        user.save!
      end
      redirect_to admin_users_path, notice: "Permissões atualizadas.", status: :see_other
    end
    private
    def require_general_admin
      render plain: "Você não tem permissão para acessar esta área.", status: :forbidden unless current_user.admin?
    end
  end
end
