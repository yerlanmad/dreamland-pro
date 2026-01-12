class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_authentication
  before_action :verify_webhook_authorization, only: [:wazzup24]

  def wazzup24
    result = Whatsapp::WebhookProcessor.new(webhook_params).process

    if result&.[](:success)
      # For test webhooks, return 200 OK as required
      render json: { ok: true }, status: :ok
    else
      Rails.logger.error("Webhook processing failed: #{result&.[](:error)}")
      head :unprocessable_entity
    end
  end

  private

  def webhook_params
    params.permit!.to_h
  end

  def verify_webhook_authorization
    # wazzup24 sends Authorization: Bearer ${crmKey} header if configured
    # Skip verification if no crm_key is configured in credentials
    return unless Rails.application.credentials.dig(:wazzup24, :crm_key).present?

    expected_key = Rails.application.credentials.dig(:wazzup24, :crm_key)
    auth_header = request.headers['Authorization']

    unless auth_header.present? && auth_header == "Bearer #{expected_key}"
      Rails.logger.warn("Unauthorized webhook attempt from #{request.remote_ip}")
      head :unauthorized
    end
  end
end
