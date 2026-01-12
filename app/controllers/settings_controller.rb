class SettingsController < ApplicationController
  def index
    # Settings overview page
  end

  def whatsapp_channels
    # Fetch channels from wazzup24
    channel_service = Whatsapp::ChannelManagerService.new
    result = channel_service.get_channels

    if result[:success]
      @channels = result[:channels]
      @active_channels = @channels.select { |c| c[:active] }
    else
      @error = result[:error]
      @channels = []
      @active_channels = []
    end

    # Get the default/current channel from credentials
    @default_channel_id = Rails.application.credentials.dig(:wazzup24, :channel_id)
  end

  def refresh_channels
    channel_service = Whatsapp::ChannelManagerService.new
    result = channel_service.get_channels

    if result[:success]
      redirect_to whatsapp_channels_settings_path, notice: "Channels refreshed successfully. Found #{result[:channels].count} channels."
    else
      redirect_to whatsapp_channels_settings_path, alert: "Failed to refresh channels: #{result[:error]}"
    end
  end
end
