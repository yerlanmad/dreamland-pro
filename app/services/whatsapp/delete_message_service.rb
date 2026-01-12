module Whatsapp
  class DeleteMessageService
    def initialize(communication:)
      @communication = communication
    end

    def call
      unless @communication.whatsapp_message_id.present?
        return { success: false, error: 'Communication has no whatsapp_message_id' }
      end

      # Delete via wazzup24 API
      result = Wazzup24Client.new.delete_message(
        message_id: @communication.whatsapp_message_id
      )

      # Update communication with result
      if result[:success]
        @communication.update!(
          deleted_at: Time.current,
          body: '[Deleted]'
        )
        { success: true, communication: @communication }
      else
        Rails.logger.error("Failed to delete WhatsApp message: #{result[:error]}")
        { success: false, error: result[:error], error_code: result[:error_code] }
      end
    rescue => e
      Rails.logger.error("DeleteMessageService error: #{e.message}")
      { success: false, error: e.message }
    end
  end
end
