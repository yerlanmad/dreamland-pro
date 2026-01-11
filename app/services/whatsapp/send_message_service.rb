module Whatsapp
  class SendMessageService
    def initialize(client:, body:, template: nil)
      @client = client
      @body = body
      @template = template
    end

    def call
      # Render template if provided
      message_body = render_message

      # Create communication record first (optimistic)
      communication = create_communication(message_body)

      # Send via wazzup24 API
      result = Wazzup24Client.new.send_message(
        phone: @client.phone,
        message: message_body
      )

      # Update communication with result
      if result[:success]
        communication.update!(
          whatsapp_message_id: result.dig(:data, 'messageId'),
          whatsapp_status: 'sent'
        )
        { success: true, communication: communication }
      else
        communication.update!(whatsapp_status: 'failed')
        Rails.logger.error("Failed to send WhatsApp: #{result[:error]}")
        { success: false, error: result[:error] }
      end
    rescue => e
      Rails.logger.error("SendMessageService error: #{e.message}")
      communication&.update(whatsapp_status: 'failed')
      { success: false, error: e.message }
    end

    private

    def render_message
      if @template
        @template.render_for(@client)
      else
        @body
      end
    end

    def create_communication(message_body)
      Communication.create!(
        client: @client,
        lead: @client.leads.active.first, # Link to active lead if exists
        communication_type: 'whatsapp',
        direction: 'outbound',
        body: message_body,
        whatsapp_status: 'pending'
      )
    end
  end
end
