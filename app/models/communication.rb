class Communication < ApplicationRecord
  # Associations
  belongs_to :client
  belongs_to :lead, optional: true
  belongs_to :booking, optional: true

  # Enums
  enum :communication_type, {
    whatsapp: 'whatsapp',
    email: 'email',
    phone: 'phone',
    sms: 'sms'
  }, prefix: :type

  enum :direction, {
    inbound: 'inbound',
    outbound: 'outbound'
  }

  # Validations
  validates :client, presence: true
  validates :communication_type, presence: true
  validates :direction, presence: true
  validates :body, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :whatsapp_messages, -> { where(communication_type: 'whatsapp') }
  scope :for_client, ->(client_id) { where(client_id: client_id) }
  scope :for_lead, ->(lead_id) { where(lead_id: lead_id) }
  scope :for_booking, ->(booking_id) { where(booking_id: booking_id) }
  scope :inbound_messages, -> { where(direction: 'inbound') }
  scope :outbound_messages, -> { where(direction: 'outbound') }

  # Delegations
  delegate :name, :phone, :email, to: :client, prefix: true

  # Instance methods
  def whatsapp?
    type_whatsapp?
  end

  def email?
    type_email?
  end

  def phone_call?
    type_phone?
  end

  def sms?
    type_sms?
  end

  def has_media?
    media_url.present?
  end

  def context_description
    if lead.present? && booking.present?
      "Lead ##{lead.id} / Booking #{booking.reference_number}"
    elsif lead.present?
      "Lead ##{lead.id}"
    elsif booking.present?
      "Booking #{booking.reference_number}"
    else
      "General communication"
    end
  end
end
