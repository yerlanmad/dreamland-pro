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
      media_url = payload['contentUri']
      media_type = payload['mediaType']

      # Wrap in transaction for data consistency
      ActiveRecord::Base.transaction do
        # Find or create client first (clients have phone numbers)
        client = find_or_create_client(phone, sender_name)

        # Find or create lead for this client
        lead = find_or_create_lead(client)

        # Create communication linked to both client and lead
        communication = create_communication(client, lead, message_body, media_url, media_type, payload['messageId'])

        # Update lead status and message count
        lead.increment_unread_messages!
        lead.mark_as_contacted! if lead.status_new?

        { success: true, lead_id: lead.id, client_id: client.id, communication_id: communication.id }
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("WhatsApp message validation failed: #{e.message}")
      Rails.logger.error("Payload: #{payload.inspect}")
      { success: false, error: "Validation failed: #{e.record.errors.full_messages.join(', ')}" }
    rescue ActiveRecord::RecordNotUnique => e
      # Retry once on duplicate key error (race condition)
      Rails.logger.warn("Race condition detected, retrying: #{e.message}")
      retry_count ||= 0
      retry_count += 1
      retry if retry_count < 2
      Rails.logger.error("Failed after retry: #{e.message}")
      { success: false, error: "Duplicate record error" }
    rescue StandardError => e
      Rails.logger.error("WhatsApp message processing failed: #{e.message}")
      Rails.logger.error("Payload: #{payload.inspect}")
      Rails.logger.error("Backtrace: #{e.backtrace.first(5).join("\n")}")
      { success: false, error: e.message }
    end

    private

    def valid_payload?
      # Must have chatId and at least one of: text, contentUri
      return false unless payload['chatId'].present?

      payload['text'].present? || payload['contentUri'].present?
    end

    def find_or_create_client(phone, name)
      # Try to find existing client first
      client = Client.find_by(phone: phone)

      return client if client

      # Create new client if not found
      Client.create!(
        phone: phone,
        name: name.presence || "WhatsApp Contact",
        preferred_language: :ru # Default to Russian for WhatsApp contacts
      )
    rescue ActiveRecord::RecordNotUnique
      # Another thread created it, try to find again
      Client.find_by!(phone: phone)
    end

    def find_or_create_lead(client)
      # Find most recent active lead
      lead = client.leads.active.order(updated_at: :desc).first

      return lead if lead

      # Create new lead if no active lead exists
      client.leads.create!(
        source: :whatsapp,
        status: :new
      )
    end

    def create_communication(client, lead, body, media_url, media_type, message_id)
      # Prepare communication attributes
      attrs = {
        client: client,
        lead: lead,
        communication_type: :whatsapp,
        direction: :inbound,
        whatsapp_message_id: message_id
      }

      # Add body if text is present
      if body.present?
        attrs[:body] = body
      elsif media_url.present?
        # If no text but has media, use placeholder
        attrs[:body] = '[Media]'
      end

      # Add media information if present
      if media_url.present?
        attrs[:media_url] = media_url
        attrs[:media_type] = media_type || detect_media_type(media_url)
      end

      Communication.create!(attrs)
    end

    def normalize_phone(phone)
      return nil if phone.blank?

      # Defensive: Remove any domain suffix (e.g., @c.us) if present
      # Note: wazzup24 webhooks send plain numbers, but this handles edge cases
      phone = phone.split('@').first if phone.include?('@')

      # Remove spaces, dashes, and parentheses
      phone = phone.gsub(/[\s\-\(\)]/, '')

      # Add + prefix for E.164 format
      phone = "+#{phone}" unless phone.start_with?('+')

      phone
    end

    def detect_media_type(url)
      return nil if url.blank?

      ext = File.extname(url).downcase
      case ext
      when '.jpg', '.jpeg', '.png', '.gif', '.webp'
        'image'
      when '.mp4', '.mov', '.avi'
        'video'
      when '.mp3', '.ogg', '.wav'
        'audio'
      when '.pdf'
        'document'
      else
        'file'
      end
    end
  end
end
