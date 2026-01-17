class Lead < ApplicationRecord
  # Associations
  belongs_to :client
  belongs_to :assigned_agent, class_name: 'User', foreign_key: 'assigned_agent_id', optional: true
  belongs_to :tour_interest, class_name: 'Tour', foreign_key: 'tour_interest_id', optional: true
  has_one :booking, dependent: :nullify
  has_many :communications, dependent: :destroy

  # Nested attributes
  accepts_nested_attributes_for :client

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
  validates :client, presence: true
  validates :status, presence: true
  validates :source, presence: true

  # Callbacks - none needed, phone normalization is now in Client

  # Scopes
  scope :unassigned, -> { where(assigned_agent_id: nil) }
  scope :with_unread_messages, -> { where('unread_messages_count > 0') }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :active, -> { where.not(status: ['won', 'lost']) }

  # Delegations for convenience
  delegate :name, :phone, :email, :preferred_language, to: :client, prefix: true, allow_nil: false

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
        client: client,
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
end
