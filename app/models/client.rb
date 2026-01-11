class Client < ApplicationRecord
  # Associations
  has_many :leads, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :communications, dependent: :destroy

  # Enums
  enum :preferred_language, {
    en: 'en',
    ru: 'ru'
  }

  # Validations
  validates :name, presence: true
  validates :phone, presence: true, uniqueness: true, format: { with: /\A\+?[1-9]\d{1,14}\z/, message: :invalid_phone }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }

  # Callbacks
  before_validation :normalize_phone

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_language, ->(language) { where(preferred_language: language) }

  # Instance methods
  def lifetime_bookings_count
    bookings.count
  end

  def lifetime_revenue
    bookings.where.not(status: 'cancelled').sum(:total_amount)
  end

  def last_booking
    bookings.order(created_at: :desc).first
  end

  def active_leads
    leads.where.not(status: ['won', 'lost'])
  end

  private

  def normalize_phone
    return unless phone.present?
    # Remove spaces, dashes, and parentheses
    self.phone = phone.gsub(/[\s\-\(\)]/, '')
    # Ensure it starts with +
    self.phone = "+#{phone}" unless phone.start_with?('+')
  end
end
