class Lead < ApplicationRecord
  # Associations
  belongs_to :assigned_agent, class_name: 'User', foreign_key: 'assigned_agent_id', optional: true
  belongs_to :tour_interest, class_name: 'Tour', foreign_key: 'tour_interest_id', optional: true
  has_many :communications, as: :communicable, dependent: :destroy
  has_one :booking, dependent: :nullify

  # Enums
  enum :status, {
    new: 'new',
    contacted: 'contacted',
    qualified: 'qualified',
    quoted: 'quoted',
    won: 'won',
    lost: 'lost'
  }, prefix: true

  enum :source, {
    whatsapp: 'whatsapp',
    website: 'website',
    manual: 'manual',
    import: 'import'
  }

  # Validations
  validates :name, presence: true
  validates :phone, presence: true, uniqueness: true, format: { with: /\A\+?[1-9]\d{1,14}\z/, message: :invalid_phone }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :status, presence: true
  validates :source, presence: true

  # Callbacks
  before_validation :normalize_phone

  # Scopes
  scope :unassigned, -> { where(assigned_agent_id: nil) }
  scope :with_unread_messages, -> { where('unread_messages_count > 0') }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }

  # Instance methods
  def mark_as_contacted!
    update(status: 'contacted') if status_new?
  end

  def increment_unread_messages!
    increment!(:unread_messages_count)
    touch(:last_message_at)
  end

  def mark_all_messages_read!
    update(unread_messages_count: 0)
  end

  def convert_to_booking!(tour_departure, num_participants)
    transaction do
      booking = Booking.create!(
        lead: self,
        tour_departure: tour_departure,
        num_participants: num_participants,
        total_amount: tour_departure.price * num_participants,
        currency: tour_departure.currency,
        status: 'confirmed'
      )
      update!(status: 'won')
      booking
    end
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
