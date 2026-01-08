class Tour < ApplicationRecord
  # Associations
  has_many :tour_departures, dependent: :destroy
  has_many :interested_leads, class_name: 'Lead', foreign_key: 'tour_interest_id', dependent: :nullify

  # Enums
  enum :currency, {
    USD: 'USD',
    KZT: 'KZT',
    EUR: 'EUR',
    RUB: 'RUB'
  }

  # Validations
  validates :name, presence: true
  validates :description, presence: true
  validates :base_price, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :duration_days, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_currency, ->(currency) { where(currency: currency) }

  # Instance methods
  def activate!
    update(active: true)
  end

  def deactivate!
    update(active: false)
  end

  def upcoming_departures
    tour_departures.where('departure_date >= ?', Date.today).order(:departure_date)
  end
end
