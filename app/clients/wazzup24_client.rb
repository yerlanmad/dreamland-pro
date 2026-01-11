class Wazzup24Client
  include HTTParty
  base_uri 'https://api.wazzup24.com'

  def initialize(api_key = nil)
    @api_key = api_key || Rails.application.credentials.dig(:wazzup24, :api_key)
    @headers = {
      'Authorization' => "Bearer #{@api_key}",
      'Content-Type' => 'application/json'
    }
  end

  def send_message(channel_id: 'd08f693e-9808-469b-92be-3af1c46c7b53', chat_type: 'whatsapp', phone:, message:, media_url: nil)
    body = {
      channelId: channel_id,
      chatType: chat_type,
      chatId: normalize_phone(phone),
      text: message
    }
    body[:media_url] = media_url if media_url.present?

    response = self.class.post('/v3/message',
      headers: @headers,
      body: body.to_json,
      timeout: 10
    )

    handle_response(response)
  rescue HTTParty::Error, Timeout::Error => e
    Rails.logger.error("wazzup24 API error: #{e.message}")
    { success: false, error: e.message }
  end

  private

  def normalize_phone(phone)
    # wazzup24 expects format: +1234567890@c.us
    phone = phone.gsub(/[\s\-\(\)]/, '')
    # phone += '@c.us' unless phone.include?('@')
    phone
  end

  def handle_response(response)
    if response.success?
      { success: true, data: response.parsed_response }
    else
      { success: false, error: response['message'] || 'Unknown error' }
    end
  end
end
