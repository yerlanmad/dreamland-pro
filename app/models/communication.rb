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

  # WhatsApp status tracking (matches wazzup24 webhook statuses)
  enum :whatsapp_status, {
    pending: 'pending',      # Initial state when sending
    sent: 'sent',            # Sent (one grey check mark)
    delivered: 'delivered',  # Delivered (two grey check marks)
    read: 'read',            # Read (two blue check marks)
    error: 'error',          # Failed to send
    inbound: 'inbound',      # Incoming message
    edited: 'edited'         # Message was edited
  }, prefix: :status

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
  scope :not_deleted, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }
  scope :sent, -> { where.not(sent_at: nil) }
  scope :with_errors, -> { where.not(error_message: nil) }
  scope :by_status, ->(status) { where(whatsapp_status: status) }

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

  def deleted?
    deleted_at.present?
  end

  def sent?
    sent_at.present?
  end

  def has_error?
    status_error? || error_message.present?
  end

  def delivered?
    status_delivered? || status_read?
  end

  def status_icon
    case whatsapp_status
    when 'pending' then '🕐'
    when 'sent' then '✓'
    when 'delivered' then '✓✓'
    when 'read' then '✓✓'  # Could be blue in UI
    when 'error' then '❌'
    when 'inbound' then '⬇️'
    else '•'
    end
  end

  def editable?
    whatsapp? && outbound? && !deleted? && whatsapp_message_id.present?
  end

  def deletable?
    whatsapp? && outbound? && !deleted? && whatsapp_message_id.present?
  end
end
