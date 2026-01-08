class Communication < ApplicationRecord
  # Associations
  belongs_to :communicable, polymorphic: true

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
  validates :communication_type, presence: true
  validates :direction, presence: true
  validates :body, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :whatsapp_messages, -> { where(communication_type: 'whatsapp') }
end
