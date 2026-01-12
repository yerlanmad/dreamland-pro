class Wazzup24Client
  include HTTParty
  base_uri 'https://api.wazzup24.com'

  # Error codes from wazzup24 API documentation
  ERROR_MESSAGES = {
    'BALANCE_IS_EMPTY' => 'WABA subscription balance has run out of funds',
    'MESSAGE_WRONG_CONTENT_TYPE' => 'Invalid content type',
    'MESSAGE_ONLY_TEXT_OR_CONTENT' => 'Message can contain text or content, not both',
    'MESSAGE_NOTHING_TO_SEND' => 'No message text was found',
    'MESSAGE_TEXT_TOO_LONG' => 'Message text exceeds maximum length',
    'MESSAGES_TOO_LONG_INSTAGRAM' => 'Instagram message text exceeds 10,000 characters',
    'MESSAGES_TOO_LONG_TELEGRAM' => 'Telegram message text exceeds 4096 characters',
    'MESSAGES_TOO_LONG_WABA' => 'WABA message text is too long',
    'MESSAGES_CONTENT_CAN_NOT_BE_BLANK' => 'File content cannot be empty',
    'MESSAGES_CONTENT_SIZE_EXCEEDED' => 'Content exceeds 10 MB limit',
    'MESSAGES_TEXT_CAN_NOT_BE_BLANK' => 'Text message cannot be empty',
    'CHANNEL_NOT_FOUND' => 'Channel not found in integration',
    'CHANNEL_BLOCKED' => 'Channel is turned off',
    'CHANNEL_WAPI_REJECTED' => 'WABA channel is blocked',
    'MESSAGE_DOWNLOAD_CONTENT_ERROR' => 'Failed to download content from link',
    'MESSAGES_NOT_TEXT_FIRST' => 'Cannot write first on Inbox tariff',
    'MESSAGES_IS_SPAM' => 'Message rated as spam',
    'VALIDATION_ERROR' => 'Parameter validation error',
    'CHANNEL_NO_MONEY' => 'Channel is not paid',
    'MESSAGE_CHANNEL_UNAVAILABLE' => 'Channel is not available',
    'MESSAGES_ABNORMAL_SEND' => 'Chat type does not match contact source',
    'MESSAGES_INVALID_CONTACT_TYPE' => 'Chat type mismatch',
    'MESSAGES_CAN_NOT_ADD' => 'Unexpected server error',
    'REPEATED_CRM_MESSAGE_ID' => 'Message with same crmMessageId already sent',
    'INVALID_MESSAGE_DATA' => 'Message data is invalid',
    'WRONG_TRANSPORT' => 'Transport type mismatch',
    'MESSAGES_EDITING_TIME_EXPIRED' => 'Message editing time expired',
    'MESSAGES_CONTAIN_BUTTONS' => 'Message contains buttons and cannot be edited',
    'CHANNEL_INVALID_TRANSPORT_FOR_EDITING' => 'Channel does not support editing',
    'CHANNEL_INVALID_TRANSPORT_FOR_CONTENT_EDITING' => 'Channel does not support content editing',
    'CHAT_NO_ACCESS' => 'No access to chat',
    'MESSAGES_NOT_FOUND' => 'Message not found',
    'CHANNEL_LIMIT_EXCEEDED' => 'Active dialogue limit exceeded',
    'MESSAGES_DELETION_TIME_EXPIRED' => 'Message deletion time expired',
    'CHANNEL_INVALID_TRANSPORT_FOR_DELETION' => 'Channel does not support deletion',
    'TEMPLATE_REJECTED' => 'Meta has restricted the template',
    'BAD_CONTACT' => 'Number may not be on WhatsApp or uses old version'
  }.freeze

  def initialize(api_key = nil)
    @api_key = api_key || Rails.application.credentials.dig(:wazzup24, :api_key)
    @headers = {
      'Authorization' => "Bearer #{@api_key}",
      'Content-Type' => 'application/json'
    }
  end

  def get_channels
    response = self.class.get('/v3/channels',
      headers: @headers,
      timeout: 10
    )

    handle_response(response)
  rescue HTTParty::Error, Timeout::Error => e
    Rails.logger.error("wazzup24 API error (get_channels): #{e.message}")
    { success: false, error: e.message }
  end

  def send_message(channel_id: nil, chat_type: 'whatsapp', phone: nil, chat_id: nil, text: nil, content_uri: nil, ref_message_id: nil, crm_message_id: nil)
    # Use default channel_id from credentials if not provided
    channel_id ||= Rails.application.credentials.dig(:wazzup24, :channel_id) || 'd08f693e-9808-469b-92be-3af1c46c7b53'

    # Normalize phone to chatId format
    chat_id ||= normalize_phone(phone) if phone.present?

    body = {
      channelId: channel_id,
      chatType: chat_type,
      chatId: chat_id
    }

    # Add text or contentUri (but not both)
    if content_uri.present?
      body[:contentUri] = content_uri
    elsif text.present?
      body[:text] = text
    else
      return { success: false, error: 'Either text or contentUri must be provided' }
    end

    # Add optional parameters
    body[:refMessageId] = ref_message_id if ref_message_id.present?
    body[:crmMessageId] = crm_message_id if crm_message_id.present?

    response = self.class.post('/v3/message',
      headers: @headers,
      body: body.to_json,
      timeout: 10
    )

    handle_response(response)
  rescue HTTParty::Error, Timeout::Error => e
    Rails.logger.error("wazzup24 API error (send_message): #{e.message}")
    { success: false, error: e.message }
  end

  def edit_message(message_id:, text: nil, content_uri: nil, crm_user_id: nil)
    body = {}

    # Add text or contentUri (but not both)
    if content_uri.present?
      body[:contentUri] = content_uri
    elsif text.present?
      body[:text] = text
    else
      return { success: false, error: 'Either text or contentUri must be provided' }
    end

    body[:crmUserId] = crm_user_id if crm_user_id.present?

    response = self.class.patch("/v3/message/#{message_id}",
      headers: @headers,
      body: body.to_json,
      timeout: 10
    )

    handle_response(response)
  rescue HTTParty::Error, Timeout::Error => e
    Rails.logger.error("wazzup24 API error (edit_message): #{e.message}")
    { success: false, error: e.message }
  end

  def delete_message(message_id:)
    response = self.class.delete("/v3/message/#{message_id}",
      headers: @headers,
      timeout: 10
    )

    handle_response(response)
  rescue HTTParty::Error, Timeout::Error => e
    Rails.logger.error("wazzup24 API error (delete_message): #{e.message}")
    { success: false, error: e.message }
  end

  private

  def normalize_phone(phone)
    return nil if phone.blank?

    # Remove spaces, dashes, and parentheses
    phone = phone.gsub(/[\s\-\(\)]/, '')
    # Remove + prefix for wazzup24 API (expects format: 79011112233)
    phone = phone.gsub(/^\+/, '')
    phone
  end

  def handle_response(response)
    # Parse JSON response if it's a string
    parsed = response.parsed_response
    parsed = JSON.parse(parsed) if parsed.is_a?(String)

    if response.success?
      { success: true, data: parsed }
    else
      error_code = parsed&.dig('error')
      error_message = ERROR_MESSAGES[error_code] || parsed&.dig('description') || 'Unknown error'

      Rails.logger.error("wazzup24 API error: #{error_code} - #{error_message}")

      {
        success: false,
        error: error_message,
        error_code: error_code,
        status: response.code
      }
    end
  end
end
