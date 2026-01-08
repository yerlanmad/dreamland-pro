class LeadsController < ApplicationController
  before_action :set_lead, only: [:show, :edit, :update, :destroy, :assign, :mark_contacted]

  def index
    @leads = Lead.includes(:assigned_agent, :tour_interest)

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

    # Search by name, email, or phone
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @leads = @leads.where("name LIKE ? OR email LIKE ? OR phone LIKE ?", search_term, search_term, search_term)
    end

    # Order and paginate
    @leads = @leads.recent.page(params[:page]).per(25)

    # For agent dropdown in filters
    @agents = User.agents.order(:name)
  end

  def show
    @communications = @lead.communications.recent.limit(50)
    @available_tours = Tour.active.order(:name)
  end

  def new
    @lead = Lead.new
    @tours = Tour.active.order(:name)
  end

  def create
    @lead = Lead.new(lead_params)
    @lead.source = :manual # Manual entry from CRM

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
    if @lead.update(lead_params)
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

  private

  def set_lead
    @lead = Lead.find(params[:id])
  end

  def lead_params
    params.require(:lead).permit(
      :name,
      :email,
      :phone,
      :status,
      :source,
      :assigned_agent_id,
      :tour_interest_id
    )
  end
end
