class LogosController < ApplicationController
  def show
    send_file Rails.root.join("app/assets/images/jornal_dm_logo.png"), type: "image/png", disposition: "inline"
  end
end
