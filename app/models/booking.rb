class Booking < ApplicationRecord
  # Associations
  belongs_to :client
  belongs_to :lead, optional: true
  belongs_to :tour_departure
  has_many :payments, dependent: :destroy
  has_many :communications, dependent: :destroy

  # Enums
  enum :status, {
    confirmed: 'confirmed',
    paid: 'paid',
    completed: 'completed',
    cancelled: 'cancelled'
  }

  enum :currency, {
    USD: 'USD',
    KZT: 'KZT',
    EUR: 'EUR',
    RUB: 'RUB'
  }

  # Validations
  validates :client, presence: true
  validates :num_participants, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :status, presence: true

  # Scopes
  scope :upcoming, -> { joins(:tour_departure).where('tour_departures.departure_date >= ?', Date.today) }
  scope :by_status, ->(status) { where(status: status) }
  scope :for_client, ->(client_id) { where(client_id: client_id) }

  # Delegations
  delegate :name, :phone, :email, to: :client, prefix: true
  delegate :name, to: :tour_departure, prefix: :tour

  # Instance methods
  def reference_number
    "BK-#{id.to_s.rjust(6, '0')}"
  end

  def tour_name
    tour_departure.tour.name
  end

  def total_paid
    payments.where(status: 'completed').sum(:amount)
  end

  def outstanding_balance
    total_amount - total_paid
  end

  def fully_paid?
    outstanding_balance <= 0
  end
end
