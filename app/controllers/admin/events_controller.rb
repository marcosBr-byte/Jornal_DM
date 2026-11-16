module Admin
  class EventsController < BaseController
    rescue_from PhotoOptimizer::InvalidImage do |error|
      redirect_to admin_events_path, alert: error.message, status: :see_other
    end
    before_action :set_event, only: [ :edit, :update, :destroy ]
    def index
      @events = editorial_scope(Event).order(starts_at: :desc).limit(100)
    end
    def new
      @event = Event.new(environment: allowed_environments.first)
    end
    def create
      @event = Event.new({ environment: allowed_environments.first }.merge(event_params))
      authorize_environment!(@event)
      if @event.save
        redirect_to admin_events_path, notice: "Evento criado.", status: :see_other
      else
        render :new, status: :unprocessable_entity
      end
    end
    def edit; end
    def update
      @event.assign_attributes(event_params)
      authorize_environment!(@event)
      if @event.save
        redirect_to admin_events_path, notice: "Evento atualizado.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end
    def destroy
      @event.destroy!
      redirect_to admin_events_path, notice: "Evento excluído.", status: :see_other
    end
    private
    def set_event
      @event = editorial_scope(Event).find(params[:id])
    end
    def event_params
      attributes = params.require(:event).permit(:title, :description, :starts_at, :location, :category, :environment, :image).to_h.symbolize_keys
      if attributes[:image].present?
        if Rails.env.production? && !ENV["ACTIVE_STORAGE_SERVICE"].in?(%w[amazon r2])
          raise PhotoOptimizer::InvalidImage, "Configure S3 ou R2 para enviar imagens de eventos."
        end
        result = PhotoOptimizer.call(attributes[:image])
        attributes[:image] = { io: StringIO.new(result[:bytes]), filename: "evento.webp", content_type: "image/webp", metadata: result.except(:bytes) }
      end
      attributes
    end
  end
end
