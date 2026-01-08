class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_authentication

  def wazzup24
    result = Whatsapp::MessageHandler.new(webhook_params).process

    if result&.[](:success)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def webhook_params
    params.permit!.to_h
  end
end
