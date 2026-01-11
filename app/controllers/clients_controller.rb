class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy]

  def index
    @clients = Client.includes(:leads, :bookings)

    # Search by name, phone, or email
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @clients = @clients.where("name LIKE ? OR phone LIKE ? OR email LIKE ?", search_term, search_term, search_term)
    end

    # Filter by language preference
    @clients = @clients.by_language(params[:language]) if params[:language].present?

    # Filter clients with active leads
    if params[:active_leads] == 'true'
      @clients = @clients.joins(:leads).where.not(leads: { status: ['won', 'lost'] }).distinct
    end

    # Filter clients with bookings
    @clients = @clients.joins(:bookings).distinct if params[:has_bookings] == 'true'

    # Order and paginate
    @clients = @clients.recent.page(params[:page]).per(25)
  end

  def show
    @leads = @client.leads.includes(:assigned_agent, :tour_interest).recent
    @bookings = @client.bookings.includes(:tour_departure).order(created_at: :desc)
    @communications = @client.communications.includes(:lead, :booking).recent.limit(50)

    # Calculate client metrics
    @active_leads_count = @client.active_leads.count
    @lifetime_bookings = @client.lifetime_bookings_count
    @lifetime_revenue = @client.lifetime_revenue
    @last_booking = @client.last_booking
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)

    if @client.save
      redirect_to @client, notice: "Client was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @client.update(client_params)
      redirect_to @client, notice: "Client was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Check if client has bookings before deletion
    if @client.bookings.any?
      redirect_to @client, alert: "Cannot delete client with existing bookings."
      return
    end

    @client.destroy
    redirect_to clients_path, notice: "Client was successfully deleted."
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(
      :name,
      :phone,
      :email,
      :preferred_language,
      :notes
    )
  end
end
