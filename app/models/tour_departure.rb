class TourDeparture < ApplicationRecord
  # Associations
  belongs_to :tour
  has_many :bookings, dependent: :restrict_with_error

  # Enums
  enum :currency, {
    USD: 'USD',
    KZT: 'KZT',
    EUR: 'EUR',
    RUB: 'RUB'
  }

  # Validations
  validates :departure_date, presence: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true

  # Scopes
  scope :upcoming, -> { where('departure_date >= ?', Date.today).order(:departure_date) }
  scope :past, -> { where('departure_date < ?', Date.today).order(departure_date: :desc) }

  # Instance methods
  def available_spots
    capacity - booked_spots
  end

  def booked_spots
    bookings.where.not(status: 'cancelled').sum(:num_participants)
  end

  def full?
    available_spots <= 0
  end
end
