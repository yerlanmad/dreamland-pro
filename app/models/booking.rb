class Booking < ApplicationRecord
  # Associations
  belongs_to :lead
  belongs_to :tour_departure
  has_many :payments, dependent: :destroy
  has_many :communications, as: :communicable, dependent: :destroy

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
  validates :num_participants, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :status, presence: true

  # Scopes
  scope :upcoming, -> { joins(:tour_departure).where('tour_departures.departure_date >= ?', Date.today) }
  scope :by_status, ->(status) { where(status: status) }

  # Instance methods
  def reference_number
    "BK-#{id.to_s.rjust(6, '0')}"
  end

  def tour_name
    tour_departure.tour.name
  end
end
