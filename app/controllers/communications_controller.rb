class CommunicationsController < ApplicationController
  before_action :set_communication, only: [:edit, :update, :destroy]
  before_action :set_client, except: [:edit, :update, :destroy]
  before_action :set_lead_or_booking, only: [:create]

  def edit
    # Render edit form
  end

  def update
    if params[:delete_message]
      delete_message
    else
      edit_message
    end
  end

  def destroy
    delete_message
  end

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

  def set_communication
    @communication = Communication.find(params[:id])
    @client = @communication.client
    @lead = @communication.lead
    @booking = @communication.booking
  end

  def edit_message
    result = Whatsapp::EditMessageService.new(
      communication: @communication,
      text: params[:body]
    ).call

    if result[:success]
      respond_to do |format|
        format.html { redirect_back_with_notice('Message edited successfully') }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "communication_#{@communication.id}",
            partial: "communications/message",
            locals: { communication: @communication }
          )
        end
      end
    else
      respond_to do |format|
        format.html { redirect_back_with_alert("Failed to edit message: #{result[:error]}") }
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "flash",
            partial: "shared/flash",
            locals: { alert: "Failed to edit message: #{result[:error]}" }
          )
        end
      end
    end
  end

  def delete_message
    result = Whatsapp::DeleteMessageService.new(
      communication: @communication
    ).call

    if result[:success]
      respond_to do |format|
        format.html { redirect_back_with_notice('Message deleted successfully') }
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "communication_#{@communication.id}",
            partial: "communications/deleted_message",
            locals: { communication: @communication }
          )
        end
      end
    else
      respond_to do |format|
        format.html { redirect_back_with_alert("Failed to delete message: #{result[:error]}") }
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "flash",
            partial: "shared/flash",
            locals: { alert: "Failed to delete message: #{result[:error]}" }
          )
        end
      end
    end
  end

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
