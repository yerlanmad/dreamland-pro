module Whatsapp
  class SendMessageService
    def initialize(client:, body: nil, content_uri: nil, template: nil, channel_id: nil, ref_message_id: nil)
      @client = client
      @body = body
      @content_uri = content_uri
      @template = template
      @channel_id = channel_id
      @ref_message_id = ref_message_id
    end

    def call
      # Render template if provided
      message_body = render_message

      # Create communication record first (optimistic)
      communication = create_communication(message_body || '[Media]')

      # Generate idempotent crmMessageId using communication ID
      crm_message_id = "crm_#{communication.id}_#{Time.current.to_i}"

      # Send via wazzup24 API
      result = Wazzup24Client.new.send_message(
        channel_id: @channel_id,
        phone: @client.phone,
        text: message_body,
        content_uri: @content_uri,
        ref_message_id: @ref_message_id,
        crm_message_id: crm_message_id
      )

      # Update communication with result
      if result[:success]
        communication.update!(
          whatsapp_message_id: result.dig(:data, 'messageId'),
          whatsapp_status: 'sent',
          sent_at: Time.current
        )
        { success: true, communication: communication }
      else
        communication.update!(
          whatsapp_status: 'failed',
          error_message: result[:error]
        )
        Rails.logger.error("Failed to send WhatsApp: #{result[:error]}")
        { success: false, error: result[:error], error_code: result[:error_code] }
      end
    rescue => e
      Rails.logger.error("SendMessageService error: #{e.message}")
      communication&.update(whatsapp_status: 'failed', error_message: e.message)
      { success: false, error: e.message }
    end

    private

    def render_message
      return nil if @content_uri.present? # Don't render text if sending media

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
