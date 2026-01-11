class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :edit, :update, :destroy, :confirm, :cancel]

  def index
    @bookings = Booking.includes(:client, :lead, :tour_departure, :payments)

    # Filter by status
    @bookings = @bookings.by_status(params[:status]) if params[:status].present?

    # Filter by client
    @bookings = @bookings.for_client(params[:client_id]) if params[:client_id].present?

    # Filter upcoming bookings
    @bookings = @bookings.upcoming if params[:upcoming] == 'true'

    # Search by client name, booking reference
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @bookings = @bookings.joins(:client).where(
        "clients.name LIKE ? OR bookings.id = ?",
        search_term,
        params[:search].gsub(/\D/, '').to_i
      )
    end

    # Order and paginate
    @bookings = @bookings.order(created_at: :desc).page(params[:page]).per(25)
  end

  def show
    @payments = @booking.payments.order(payment_date: :desc)
    @communications = @booking.client.communications
                              .where(booking_id: @booking.id)
                              .recent
                              .limit(20)
  end

  def new
    # Check if creating from a lead or client
    if params[:lead_id].present?
      @lead = Lead.find(params[:lead_id])
      @booking = Booking.new(
        client: @lead.client,
        lead: @lead
      )
      # Pre-select tour departure if lead has tour interest
      if @lead.tour_interest
        @available_departures = @lead.tour_interest.tour_departures.upcoming
      end
    elsif params[:client_id].present?
      @client = Client.find(params[:client_id])
      @booking = @client.bookings.new
    else
      @booking = Booking.new
      @clients = Client.order(:name)
    end

    @tours = Tour.active.order(:name)
    @available_departures ||= TourDeparture.upcoming.includes(:tour).order(:departure_date)
  end

  def create
    @booking = Booking.new(booking_params)

    # Set default status
    @booking.status ||= :confirmed

    if @booking.save
      redirect_to @booking, notice: "Booking was successfully created."
    else
      @tours = Tour.active.order(:name)
      @available_departures = TourDeparture.upcoming.includes(:tour).order(:departure_date)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @tours = Tour.active.order(:name)
    @available_departures = TourDeparture.upcoming.includes(:tour).order(:departure_date)
  end

  def update
    if @booking.update(booking_params)
      redirect_to @booking, notice: "Booking was successfully updated."
    else
      @tours = Tour.active.order(:name)
      @available_departures = TourDeparture.upcoming.includes(:tour).order(:departure_date)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Only allow deletion if no payments have been made
    if @booking.payments.any?
      redirect_to @booking, alert: "Cannot delete booking with existing payments. Cancel it instead."
      return
    end

    @booking.destroy
    redirect_to bookings_path, notice: "Booking was successfully deleted."
  end

  # Custom action: Confirm booking
  def confirm
    if @booking.update(status: :confirmed)
      redirect_to @booking, notice: "Booking confirmed."
    else
      redirect_to @booking, alert: "Failed to confirm booking."
    end
  end

  # Custom action: Cancel booking
  def cancel
    if @booking.update(status: :cancelled)
      redirect_to @booking, notice: "Booking cancelled."
    else
      redirect_to @booking, alert: "Failed to cancel booking."
    end
  end

  private

  def set_booking
    @booking = Booking.includes(:client, :lead, :tour_departure, :payments).find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(
      :client_id,
      :lead_id,
      :tour_departure_id,
      :num_participants,
      :total_amount,
      :currency,
      :status
    )
  end
end
