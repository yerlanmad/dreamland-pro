module Whatsapp
  class MessageHandler
    attr_reader :payload

    def initialize(payload)
      @payload = payload
    end

    def process
      return unless valid_payload?

      phone = normalize_phone(payload['chatId'])
      message_body = payload['text']
      sender_name = payload['senderName']

      lead = find_or_create_lead(phone, sender_name)
      create_communication(lead, message_body, payload['messageId'])

      lead.increment_unread_messages!
      lead.mark_as_contacted! if lead.status_new?

      { success: true, lead_id: lead.id }
    rescue StandardError => e
      Rails.logger.error("WhatsApp message processing failed: #{e.message}")
      { success: false, error: e.message }
    end

    private

    def valid_payload?
      payload['chatId'].present? && payload['text'].present?
    end

    def find_or_create_lead(phone, name)
      Lead.find_or_initialize_by(phone: phone).tap do |lead|
        if lead.new_record?
          lead.name = name.presence || "WhatsApp Contact"
          lead.source = :whatsapp
          lead.status = :new
          lead.save!
        end
      end
    end

    def create_communication(lead, body, message_id)
      Communication.create!(
        communicable: lead,
        communication_type: :whatsapp,
        direction: :inbound,
        body: body,
        whatsapp_message_id: message_id
      )
    end

    def normalize_phone(phone)
      # Remove wazzup24 domain suffix (e.g., @c.us)
      phone = phone.split('@').first if phone.include?('@')
      # Remove spaces, dashes, and parentheses
      phone = phone.gsub(/[\s\-\(\)]/, '')
      # Add + prefix if missing
      phone = "+#{phone}" unless phone.start_with?('+')
      phone
    end
  end
end
