module Whatsapp
  class WebhookProcessor
    attr_reader :payload

    def initialize(payload)
      @payload = payload
    end

    def process
      # Handle test webhook
      return { success: true, type: :test } if test_webhook?

      results = []

      # Process messages (incoming, edited, deleted)
      if payload['messages'].present?
        results << process_messages(payload['messages'])
      end

      # Process status updates (sent, delivered, read, error)
      if payload['statuses'].present?
        results << process_statuses(payload['statuses'])
      end

      # Process contact creation webhook
      if payload['createContact'].present?
        results << process_create_contact(payload['createContact'])
      end

      # Process deal creation webhook
      if payload['createDeal'].present?
        results << process_create_deal(payload['createDeal'])
      end

      { success: true, results: results }
    rescue StandardError => e
      Rails.logger.error("Webhook processing failed: #{e.message}")
      Rails.logger.error("Payload: #{payload.inspect}")
      Rails.logger.error("Backtrace: #{e.backtrace.first(10).join("\n")}")
      { success: false, error: e.message }
    end

    private

    def test_webhook?
      payload['test'] == true
    end

    def process_messages(messages)
      results = messages.map do |message_data|
        if message_data['isDeleted']
          handle_deleted_message(message_data)
        elsif message_data['isEdited']
          handle_edited_message(message_data)
        else
          handle_new_message(message_data)
        end
      end

      { type: :messages, count: results.size, results: results }
    end

    def process_statuses(statuses)
      results = statuses.map do |status_data|
        handle_status_update(status_data)
      end

      { type: :statuses, count: results.size, results: results }
    end

    def process_create_contact(contact_data)
      # This webhook expects a response with contact details
      # For now, we'll just log it as it requires CRM integration
      Rails.logger.info("Create contact webhook received: #{contact_data.inspect}")
      { type: :create_contact, handled: false, reason: 'Not implemented yet' }
    end

    def process_create_deal(deal_data)
      # This webhook expects a response with deal details
      # For now, we'll just log it as it requires CRM integration
      Rails.logger.info("Create deal webhook received: #{deal_data.inspect}")
      { type: :create_deal, handled: false, reason: 'Not implemented yet' }
    end

    def handle_new_message(message_data)
      # Check if it's an outbound echo message
      if message_data['isEcho']
        handle_echo_message(message_data)
      else
        handle_inbound_message(message_data)
      end
    end

    def handle_inbound_message(message_data)
      # Use existing MessageHandler for inbound messages
      handler_payload = build_handler_payload(message_data)
      result = MessageHandler.new(handler_payload).process

      if result&.[](:success)
        { message_id: message_data['messageId'], status: :processed, result: result }
      else
        { message_id: message_data['messageId'], status: :failed, error: result&.[](:error) }
      end
    end

    def handle_echo_message(message_data)
      # Echo messages are outbound messages sent from phone or iframe (not via our API)
      # We should track these in our system as well

      phone = normalize_phone(message_data['chatId'])
      client = Client.find_by(phone: phone)

      unless client
        Rails.logger.warn("Echo message for unknown client: #{phone}")
        return { message_id: message_data['messageId'], status: :skipped, reason: 'Unknown client' }
      end

      # Check if we already have a communication for this message
      # This prevents duplicates when we send via API and receive echo webhook
      existing_communication = Communication.find_by(whatsapp_message_id: message_data['messageId'])

      if existing_communication
        # Update existing communication with echo data if needed
        existing_communication.update!(
          whatsapp_status: message_data['status'],
          sent_at: parse_datetime(message_data['dateTime']) || existing_communication.sent_at
        )
        Rails.logger.info("Echo message matched existing communication: #{existing_communication.id}")
        return { message_id: message_data['messageId'], status: :updated, communication_id: existing_communication.id }
      end

      # Create new communication only if it doesn't exist (sent from phone/iframe, not our API)
      lead = client.leads.active.order(updated_at: :desc).first

      communication = Communication.create!(
        client: client,
        lead: lead,
        communication_type: :whatsapp,
        direction: :outbound,
        body: message_data['text'] || '[Media]',
        media_url: message_data['contentUri'],
        media_type: map_message_type_to_media_type(message_data['type']),
        whatsapp_message_id: message_data['messageId'],
        whatsapp_status: message_data['status'],
        sent_at: parse_datetime(message_data['dateTime'])
      )

      { message_id: message_data['messageId'], status: :created, communication_id: communication.id }
    rescue StandardError => e
      Rails.logger.error("Echo message handling failed: #{e.message}")
      { message_id: message_data['messageId'], status: :failed, error: e.message }
    end

    def handle_edited_message(message_data)
      communication = Communication.find_by(whatsapp_message_id: message_data['messageId'])

      unless communication
        Rails.logger.warn("Edited message not found: #{message_data['messageId']}")
        return { message_id: message_data['messageId'], status: :not_found }
      end

      old_text = message_data.dig('oldInfo', 'oldText')
      new_text = message_data['text']

      communication.update!(
        body: new_text || communication.body,
        updated_at: Time.current
      )

      Rails.logger.info("Message edited: #{message_data['messageId']} - Old: #{old_text}, New: #{new_text}")

      { message_id: message_data['messageId'], status: :updated, communication_id: communication.id }
    rescue StandardError => e
      Rails.logger.error("Edited message handling failed: #{e.message}")
      { message_id: message_data['messageId'], status: :failed, error: e.message }
    end

    def handle_deleted_message(message_data)
      communication = Communication.find_by(whatsapp_message_id: message_data['messageId'])

      unless communication
        Rails.logger.warn("Deleted message not found: #{message_data['messageId']}")
        return { message_id: message_data['messageId'], status: :not_found }
      end

      communication.update!(
        deleted_at: Time.current,
        body: message_data.dig('oldInfo', 'oldText') || communication.body
      )

      Rails.logger.info("Message deleted: #{message_data['messageId']}")

      { message_id: message_data['messageId'], status: :deleted, communication_id: communication.id }
    rescue StandardError => e
      Rails.logger.error("Deleted message handling failed: #{e.message}")
      { message_id: message_data['messageId'], status: :failed, error: e.message }
    end

    def handle_status_update(status_data)
      communication = Communication.find_by(whatsapp_message_id: status_data['messageId'])

      unless communication
        Rails.logger.warn("Communication not found for status update: #{status_data['messageId']}")
        return { message_id: status_data['messageId'], status: :not_found }
      end

      # Update status
      communication.update!(
        whatsapp_status: status_data['status'],
        sent_at: parse_datetime(status_data['timestamp']) || communication.sent_at
      )

      # Handle error status
      if status_data['status'] == 'error' && status_data['error'].present?
        error_message = "#{status_data['error']['error']}: #{status_data['error']['description']}"
        communication.update!(error_message: error_message)
      end

      Rails.logger.info("Status updated for #{status_data['messageId']}: #{status_data['status']}")

      { message_id: status_data['messageId'], status: :updated, new_status: status_data['status'] }
    rescue StandardError => e
      Rails.logger.error("Status update handling failed: #{e.message}")
      { message_id: status_data['messageId'], status: :failed, error: e.message }
    end

    def build_handler_payload(message_data)
      {
        'chatId' => message_data['chatId'],
        'text' => message_data['text'],
        'senderName' => message_data.dig('contact', 'name'),
        'contentUri' => message_data['contentUri'],
        'mediaType' => map_message_type_to_media_type(message_data['type']),
        'messageId' => message_data['messageId']
      }
    end

    def normalize_phone(phone)
      return nil if phone.blank?
      phone = phone.split('@').first if phone.include?('@')
      phone = phone.gsub(/[\s\-\(\)]/, '')
      phone = "+#{phone}" unless phone.start_with?('+')
      phone
    end

    def parse_datetime(datetime_string)
      return nil if datetime_string.blank?
      Time.parse(datetime_string)
    rescue ArgumentError
      nil
    end

    def map_message_type_to_media_type(type)
      case type
      when 'image' then 'image'
      when 'video' then 'video'
      when 'audio' then 'audio'
      when 'document' then 'document'
      when 'vcard' then 'vcard'
      when 'geo' then 'geo'
      else nil
      end
    end
  end
end
