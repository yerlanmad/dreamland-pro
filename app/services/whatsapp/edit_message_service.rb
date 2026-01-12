module Whatsapp
  class EditMessageService
    def initialize(communication:, text: nil, content_uri: nil)
      @communication = communication
      @text = text
      @content_uri = content_uri
    end

    def call
      unless @communication.whatsapp_message_id.present?
        return { success: false, error: 'Communication has no whatsapp_message_id' }
      end

      # Edit via wazzup24 API
      result = Wazzup24Client.new.edit_message(
        message_id: @communication.whatsapp_message_id,
        text: @text,
        content_uri: @content_uri
      )

      # Update communication with result
      if result[:success]
        @communication.update!(
          body: @text || '[Media]',
          updated_at: Time.current
        )
        { success: true, communication: @communication }
      else
        Rails.logger.error("Failed to edit WhatsApp message: #{result[:error]}")
        { success: false, error: result[:error], error_code: result[:error_code] }
      end
    rescue => e
      Rails.logger.error("EditMessageService error: #{e.message}")
      { success: false, error: e.message }
    end
  end
end
