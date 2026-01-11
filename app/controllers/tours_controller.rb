class ToursController < ApplicationController
  before_action :require_authentication
  before_action :set_tour, only: [:show, :edit, :update, :destroy]

  def index
    @tours = Tour.includes(:tour_departures)
    @tours = filter_by_status(@tours)
    @tours = filter_by_currency(@tours)
    @tours = @tours.order(created_at: :desc).page(params[:page]).per(20)

    @stats = {
      total: Tour.count,
      active: Tour.active.count,
      total_departures: TourDeparture.count,
      upcoming_departures: TourDeparture.upcoming.count
    }
  end

  def show
    @upcoming_departures = @tour.upcoming_departures.limit(10)
  end

  def new
    @tour = Tour.new(active: true)
  end

  def create
    @tour = Tour.new(tour_params)

    if @tour.save
      redirect_to @tour, notice: "Tour was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @tour.update(tour_params)
      redirect_to @tour, notice: "Tour was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @tour.tour_departures.any?
      redirect_to @tour, alert: "Cannot delete tour with existing departures. Please delete all departures first."
    else
      @tour.destroy
      redirect_to tours_path, notice: "Tour was successfully deleted."
    end
  end

  private

  def set_tour
    @tour = Tour.find(params[:id])
  end

  def tour_params
    params.require(:tour).permit(:name, :description, :base_price, :currency, :duration_days, :capacity, :active)
  end

  def filter_by_status(scope)
    case params[:status]
    when 'active'
      scope.active
    when 'inactive'
      scope.inactive
    else
      scope
    end
  end

  def filter_by_currency(scope)
    if params[:currency].present? && params[:currency] != ''
      scope.by_currency(params[:currency])
    else
      scope
    end
  end
end
