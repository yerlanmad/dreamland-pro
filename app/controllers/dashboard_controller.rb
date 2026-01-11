class DashboardController < ApplicationController
  def index
    # Lead metrics
    @total_leads = Lead.count
    @active_leads = Lead.active.count
    @new_leads = Lead.status_new.count
    @leads_with_unread = Lead.with_unread_messages.count
    @leads_by_status = Lead.group(:status).count

    # Client metrics
    @total_clients = Client.count
    @clients_with_active_leads = Client.joins(:leads).where.not(leads: { status: ['won', 'lost'] }).distinct.count
    @returning_clients = Client.joins(:leads).group('clients.id').having('COUNT(leads.id) > 1').count.length

    # Booking metrics
    @total_bookings = Booking.count
    @upcoming_bookings = Booking.upcoming.count
    @confirmed_bookings = Booking.where(status: :confirmed).count
    @paid_bookings = Booking.where(status: :paid).count
    @bookings_by_status = Booking.group(:status).count

    # Revenue metrics
    @total_revenue = Booking.where.not(status: :cancelled).sum(:total_amount)
    @revenue_by_currency = Booking.where.not(status: :cancelled).group(:currency).sum(:total_amount)
    @outstanding_payments = calculate_outstanding_payments

    # Recent activity
    @recent_leads = Lead.includes(:client, :assigned_agent).recent.limit(5)
    @recent_bookings = Booking.includes(:client, :tour_departure).order(created_at: :desc).limit(5)
    @unread_communications = Communication.joins(:lead)
                                          .where('leads.unread_messages_count > 0')
                                          .group('communications.client_id')
                                          .count

    # Agent performance (if current user is manager/admin)
    if current_user&.role.in?(['manager', 'admin'])
      @agent_stats = calculate_agent_stats
    end

    # Tour popularity
    @popular_tours = Tour.joins(tour_departures: :bookings)
                         .where.not(bookings: { status: :cancelled })
                         .group('tours.id', 'tours.name')
                         .select('tours.id, tours.name, COUNT(bookings.id) as bookings_count')
                         .order('bookings_count DESC')
                         .limit(5)
  end

  private

  def calculate_outstanding_payments
    bookings = Booking.includes(:payments).where.not(status: [:cancelled, :paid])
    outstanding = {}

    bookings.each do |booking|
      currency = booking.currency
      outstanding[currency] ||= 0
      outstanding[currency] += booking.outstanding_balance
    end

    outstanding
  end

  def calculate_agent_stats
    User.agents.map do |agent|
      {
        agent: agent,
        active_leads: agent.assigned_leads.active.count,
        leads_this_month: agent.assigned_leads.where('created_at >= ?', 1.month.ago).count,
        conversions_this_month: agent.assigned_leads
                                     .where('created_at >= ?', 1.month.ago)
                                     .where(status: 'won')
                                     .count
      }
    end
  end
end
