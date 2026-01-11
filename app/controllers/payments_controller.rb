class PaymentsController < ApplicationController
  before_action :set_booking, only: [:new, :create]
  before_action :set_payment, only: [:show, :edit, :update]

  def index
    @payments = Payment.includes(:booking).order(payment_date: :desc)

    # Filter by status
    @payments = @payments.where(status: params[:status]) if params[:status].present?

    # Filter by payment method
    @payments = @payments.by_method(params[:payment_method]) if params[:payment_method].present?

    # Filter by booking
    @payments = @payments.where(booking_id: params[:booking_id]) if params[:booking_id].present?

    # Search by booking reference or client name
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @payments = @payments.joins(booking: :client).where(
        "clients.name LIKE ?",
        search_term
      )
    end

    # Paginate
    @payments = @payments.page(params[:page]).per(25)
  end

  def show
  end

  def new
    @payment = @booking.payments.new(
      currency: @booking.currency,
      payment_date: Date.today,
      status: :pending
    )
  end

  def create
    @payment = @booking.payments.new(payment_params)

    if @payment.save
      # Update booking status if fully paid
      if @booking.fully_paid?
        @booking.update(status: :paid)
      end

      redirect_to @booking, notice: "Payment was successfully recorded."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @payment.update(payment_params)
      # Update booking status if fully paid
      if @payment.booking.fully_paid?
        @payment.booking.update(status: :paid)
      end

      redirect_to @payment, notice: "Payment was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_booking
    @booking = Booking.find(params[:booking_id])
  end

  def set_payment
    @payment = Payment.includes(:booking).find(params[:id])
  end

  def payment_params
    params.require(:payment).permit(
      :amount,
      :currency,
      :payment_date,
      :payment_method,
      :status
    )
  end
end
