class EventImagesController < ApplicationController
  def show
    event = Event.in_environment(current_environment).find(params[:id])
    return head :not_found unless event.image.attached?
    response.headers["Cache-Control"] = "private, no-store"
    response.headers["X-Content-Type-Options"] = "nosniff"
    bytes, content_type = EditorialImage.bytes(event.image, params[:size])
    send_data bytes, type: content_type, disposition: "inline"
  rescue ActiveStorage::FileNotFoundError
    head :not_found
  end
end
