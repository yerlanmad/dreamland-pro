class LeadsController < ApplicationController
  before_action :set_lead, only: [:show, :edit, :update, :destroy, :assign, :mark_contacted, :mark_messages_read, :convert_to_booking]

  def index
    @leads = Lead.includes(:client, :assigned_agent, :tour_interest)

    # Filter by status
    @leads = @leads.by_status(params[:status]) if params[:status].present?

    # Filter by source
    @leads = @leads.where(source: params[:source]) if params[:source].present?

    # Filter by assigned agent
    @leads = @leads.where(assigned_agent_id: params[:agent_id]) if params[:agent_id].present?

    # Filter unassigned
    @leads = @leads.unassigned if params[:unassigned] == 'true'

    # Filter unread messages
    @leads = @leads.with_unread_messages if params[:unread] == 'true'

    # Filter active leads (not won or lost)
    @leads = @leads.active if params[:active] == 'true'

    # Filter by campaign source
    if params[:campaign_source].present?
      if params[:campaign_source] == 'none'
        @leads = @leads.without_campaign
      else
        @leads = @leads.by_campaign_source(params[:campaign_source])
      end
    end

    # Search by client name, email, or phone
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @leads = @leads.joins(:client).where(
        "clients.name LIKE ? OR clients.email LIKE ? OR clients.phone LIKE ?",
        search_term, search_term, search_term
      )
    end

    # Order and paginate
    @leads = @leads.recent.page(params[:page]).per(25)

    # For agent dropdown in filters
    @agents = User.agents.order(:name)
  end

  def show
    @communications = @lead.client.communications
                           .where(lead_id: @lead.id)
                           .or(@lead.client.communications.where(lead_id: nil, booking_id: nil))
                           .recent
                           .limit(50)
    @available_tours = Tour.active.order(:name)
    @available_departures = TourDeparture.upcoming.includes(:tour).order(:departure_date)
  end

  def new
    # Check if client_id is provided (creating lead for existing client)
    if params[:client_id].present?
      @client = Client.find(params[:client_id])
      @lead = @client.leads.new
    else
      # Creating new lead with new client
      @lead = Lead.new
      @lead.build_client
    end

    @tours = Tour.active.order(:name)
  end

  def create
    # Check if we're creating a lead for an existing client or a new one
    if params[:lead][:client_id].present?
      # Existing client
      @client = Client.find(params[:lead][:client_id])
      @lead = @client.leads.new(lead_params_without_client)
    else
      # New client - build both together
      @lead = Lead.new(lead_params_without_client)
      @lead.build_client(client_params) if params[:lead][:client_attributes].present?
    end

    @lead.source ||= :manual # Default to manual entry from CRM

    if @lead.save
      redirect_to @lead, notice: "Lead was successfully created."
    else
      @tours = Tour.active.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @tours = Tour.active.order(:name)
    @agents = User.agents.order(:name)
  end

  def update
    # Guard clause: ensure lead params are present
    return redirect_to @lead, alert: "Invalid request." unless params[:lead]

    # Check if we're switching to an existing client or creating a new one
    if params[:lead][:client_id].present?
      # Switching to an existing client
      @lead.update(lead_params_without_client)
    elsif params[:lead][:client_attributes].present?
      # Creating a new client - don't modify the existing client
      new_client = Client.new(client_params)
      if new_client.save
        @lead.update(lead_params_without_client.merge(client_id: new_client.id))
      else
        @lead.errors.merge!(new_client.errors)
      end
    else
      # Just updating lead attributes without changing client
      @lead.update(lead_params_without_client)
    end

    if @lead.errors.empty?
      redirect_to @lead, notice: "Lead was successfully updated."
    else
      @tours = Tour.active.order(:name)
      @agents = User.agents.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @lead.destroy
    redirect_to leads_path, notice: "Lead was successfully deleted."
  end

  # Custom action: Assign lead to an agent
  def assign
    agent = User.find_by(id: params[:agent_id])

    if agent && @lead.update(assigned_agent: agent)
      redirect_to @lead, notice: "Lead assigned to #{agent.name}."
    else
      redirect_to @lead, alert: "Failed to assign lead."
    end
  end

  # Custom action: Mark lead as contacted
  def mark_contacted
    @lead.mark_as_contacted!
    redirect_to @lead, notice: "Lead marked as contacted."
  end

  # Custom action: Mark all messages as read
  def mark_messages_read
    @lead.mark_all_messages_read!
    redirect_to @lead, notice: "All messages marked as read."
  end

  # Custom action: Convert lead to booking
  def convert_to_booking
    tour_departure = TourDeparture.find(params[:tour_departure_id])
    num_participants = params[:num_participants].to_i

    begin
      booking = @lead.convert_to_booking!(tour_departure, num_participants)
      redirect_to booking, notice: "Lead successfully converted to booking!"
    rescue StandardError => e
      redirect_to @lead, alert: "Failed to convert lead: #{e.message}"
    end
  end

  private

  def set_lead
    @lead = Lead.includes(:client).find(params[:id])
  end

  def lead_params_without_client
    params.require(:lead).permit(
      :client_id,
      :status,
      :source,
      :assigned_agent_id,
      :tour_interest_id,
      :campaign_source,
      :campaign_id,
      :campaign_url
    )
  end

  def client_params
    params.require(:lead).fetch(:client_attributes, {}).permit(
      :name,
      :phone,
      :email,
      :preferred_language,
      :notes
    )
  end
end
