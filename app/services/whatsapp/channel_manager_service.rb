module Whatsapp
  class ChannelManagerService
    CHANNEL_STATES = {
      'active' => 'Channel is active',
      'init' => 'Channel is starting',
      'disabled' => 'Channel is turned off',
      'phoneUnavailable' => 'No connection to phone',
      'qr' => 'QR code must be scanned',
      'openElsewhere' => 'Channel is authorized in another Wazzup account',
      'notEnoughMoney' => 'Channel is not paid',
      'foreignphone' => 'Channel QR was scanned by another phone number',
      'unauthorized' => 'Not authorized',
      'waitForPassword' => 'Waiting for password for two-factor authentication',
      'onModeration' => 'WABA channel is in moderation',
      'rejected' => 'WABA channel is rejected'
    }.freeze

    def get_channels
      result = Wazzup24Client.new.get_channels

      if result[:success]
        channels = result[:data].map do |channel|
          {
            channel_id: channel['channelId'],
            transport: channel['transport'],
            plain_id: channel['plainId'],
            state: channel['state'],
            state_description: CHANNEL_STATES[channel['state']] || 'Unknown state',
            active: channel['state'] == 'active'
          }
        end
        { success: true, channels: channels }
      else
        Rails.logger.error("Failed to get channels: #{result[:error]}")
        { success: false, error: result[:error] }
      end
    rescue => e
      Rails.logger.error("ChannelManagerService error: #{e.message}")
      { success: false, error: e.message }
    end

    def get_active_whatsapp_channels
      result = get_channels
      return result unless result[:success]

      active_channels = result[:channels].select do |channel|
        channel[:transport] == 'whatsapp' && channel[:active]
      end

      { success: true, channels: active_channels }
    end

    def get_default_channel
      result = get_active_whatsapp_channels
      return result unless result[:success]

      if result[:channels].any?
        { success: true, channel: result[:channels].first }
      else
        { success: false, error: 'No active WhatsApp channels found' }
      end
    end
  end
end
