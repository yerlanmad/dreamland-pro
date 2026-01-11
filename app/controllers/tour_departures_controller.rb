class TourDeparturesController < ApplicationController
  before_action :require_authentication
  before_action :set_tour, only: [:index, :new, :create]
  before_action :set_tour_departure, only: [:show, :edit, :update, :destroy]

  def index
    @tour_departures = @tour.tour_departures
    @tour_departures = filter_by_timeframe(@tour_departures)
    @tour_departures = @tour_departures.order(departure_date: :asc).page(params[:page]).per(20)

    @stats = {
      total: @tour.tour_departures.count,
      upcoming: @tour.tour_departures.upcoming.count,
      total_capacity: @tour.tour_departures.sum(:capacity),
      available_spots: @tour.tour_departures.upcoming.sum { |d| d.available_spots }
    }
  end

  def show
    @tour = @tour_departure.tour
    @bookings = @tour_departure.bookings.includes(:client).order(created_at: :desc)
  end

  def new
    @tour_departure = @tour.tour_departures.build(
      price: @tour.base_price,
      currency: @tour.currency,
      capacity: @tour.capacity
    )
  end

  def create
    @tour_departure = @tour.tour_departures.build(tour_departure_params)

    if @tour_departure.save
      redirect_to @tour_departure, notice: "Departure was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @tour = @tour_departure.tour
  end

  def update
    if @tour_departure.update(tour_departure_params)
      redirect_to @tour_departure, notice: "Departure was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @tour_departure.bookings.any?
      redirect_to @tour_departure, alert: "Cannot delete departure with existing bookings."
    else
      tour = @tour_departure.tour
      @tour_departure.destroy
      redirect_to tour_path(tour), notice: "Departure was successfully deleted."
    end
  end

  private

  def set_tour
    @tour = Tour.find(params[:tour_id])
  end

  def set_tour_departure
    @tour_departure = TourDeparture.find(params[:id])
  end

  def tour_departure_params
    params.require(:tour_departure).permit(:departure_date, :price, :currency, :capacity)
  end

  def filter_by_timeframe(scope)
    case params[:timeframe]
    when 'upcoming'
      scope.upcoming
    when 'past'
      scope.past
    else
      scope
    end
  end
end
