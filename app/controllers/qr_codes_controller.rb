require "open3"
class QrCodesController < ApplicationController
  def show
    destination = "#{request.base_url}#{current_environment == "fect" ? "/fect" : ""}/enviar-fotos"
    output, status = Open3.capture2("qrencode", "-t", "PNG", "-s", "6", "-m", "4", "-o", "-", destination)
    return head :service_unavailable unless status.success?
    send_data output, type: "image/png", disposition: "inline"
  rescue Errno::ENOENT
    head :service_unavailable
  end
end
