class CommunicationsController < ApplicationController
  before_action :set_client
  before_action :set_lead_or_booking, only: [:create]

  def create
    @communication = @client.communications.new(communication_params)
    @communication.direction = :outbound # Messages from CRM are outbound

    # Associate with lead or booking if provided
    @communication.lead_id = @lead.id if @lead
    @communication.booking_id = @booking.id if @booking

    if @communication.save
      # Mark lead messages as read if replying to a lead
      @lead.mark_all_messages_read! if @lead

      # Redirect back to the appropriate page
      if @lead
        redirect_to @lead, notice: "Message sent successfully."
      elsif @booking
        redirect_to @booking, notice: "Message sent successfully."
      else
        redirect_to @client, notice: "Message sent successfully."
      end
    else
      # Handle errors - redirect back with alert
      if @lead
        redirect_to @lead, alert: "Failed to send message: #{@communication.errors.full_messages.join(', ')}"
      elsif @booking
        redirect_to @booking, alert: "Failed to send message: #{@communication.errors.full_messages.join(', ')}"
      else
        redirect_to @client, alert: "Failed to send message: #{@communication.errors.full_messages.join(', ')}"
      end
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
