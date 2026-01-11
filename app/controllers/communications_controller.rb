class CommunicationsController < ApplicationController
  before_action :set_client
  before_action :set_lead_or_booking, only: [:create]

  def create
    case params[:communication_type]
    when 'whatsapp'
      send_whatsapp_message
    when 'email'
      send_email_message
    else
      redirect_back_with_alert('Invalid communication type')
    end
  end

  private

  def set_client
    # Client can be set from lead, booking, or directly
    if params[:lead_id].present?
      @lead = Lead.find(params[:lead_id])
      @client = @lead.client
    elsif params[:booking_id].present?
      @booking = Booking.find(params[:booking_id])
      @client = @booking.client
    elsif params[:client_id].present?
      @client = Client.find(params[:client_id])
    else
      redirect_to root_path, alert: "Client, lead, or booking must be specified."
    end
  end

  def set_lead_or_booking
    @lead = Lead.find(params[:lead_id]) if params[:lead_id].present?
    @booking = Booking.find(params[:booking_id]) if params[:booking_id].present?
  end

  def send_whatsapp_message
    template = WhatsappTemplate.find(params[:template_id]) if params[:template_id].present?

    result = Whatsapp::SendMessageService.new(
      client: @client,
      body: params[:body],
      template: template
    ).call

    if result[:success]
      # Mark lead messages as read if replying to a lead
      @lead.mark_all_messages_read! if @lead

      redirect_back_with_notice('Message sent successfully')
    else
      redirect_back_with_alert("Failed to send message: #{result[:error]}")
    end
  end

  def send_email_message
    # TODO: Implement email sending (future phase)
    redirect_back_with_alert('Email communication not yet implemented')
  end

  def redirect_back_with_notice(message)
    if @lead
      redirect_to @lead, notice: message
    elsif @booking
      redirect_to @booking, notice: message
    else
      redirect_to @client, notice: message
    end
  end

  def redirect_back_with_alert(message)
    if @lead
      redirect_to @lead, alert: message
    elsif @booking
      redirect_to @booking, alert: message
    else
      redirect_to @client, alert: message
    end
  end

  def communication_params
    params.require(:communication).permit(
      :communication_type,
      :subject,
      :body,
      :whatsapp_message_id,
      :media_url,
      :media_type
    )
  end
end
