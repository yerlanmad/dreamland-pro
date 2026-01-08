class User < ApplicationRecord
  has_secure_password

  # Associations
  has_many :assigned_leads, class_name: 'Lead', foreign_key: 'assigned_agent_id', dependent: :nullify

  # Enums
  enum :role, {
    agent: 'agent',
    manager: 'manager',
    admin: 'admin'
  }

  enum :preferred_language, {
    en: 'en',
    ru: 'ru'
  }

  enum :preferred_currency, {
    USD: 'USD',
    KZT: 'KZT',
    EUR: 'EUR',
    RUB: 'RUB'
  }

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :role, presence: true
  validates :preferred_language, presence: true
  validates :preferred_currency, presence: true

  # Callbacks
  before_save :downcase_email

  # Scopes
  scope :agents, -> { where(role: 'agent') }
  scope :managers, -> { where(role: 'manager') }
  scope :admins, -> { where(role: 'admin') }

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
