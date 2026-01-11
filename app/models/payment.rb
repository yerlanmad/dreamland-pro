class Payment < ApplicationRecord
  # Associations
  belongs_to :booking

  # Enums
  enum :currency, {
    USD: 'USD',
    KZT: 'KZT',
    EUR: 'EUR',
    RUB: 'RUB'
  }

  enum :status, {
    pending: 'pending',
    completed: 'completed',
    failed: 'failed',
    refunded: 'refunded'
  }

  enum :payment_method, {
    cash: 'cash',
    bank_transfer: 'bank_transfer',
    credit_card: 'credit_card',
    online: 'online'
  }

  # Validations
  validates :booking, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :payment_date, presence: true
  validates :payment_method, presence: true
  validates :status, presence: true

  # Scopes
  scope :completed, -> { where(status: 'completed') }
  scope :pending, -> { where(status: 'pending') }
  scope :recent, -> { order(payment_date: :desc) }
  scope :by_method, ->(method) { where(payment_method: method) }

  # Delegations
  delegate :client, :client_name, :reference_number, to: :booking

  # Instance methods
  def mark_as_completed!
    update(status: 'completed')
  end

  def mark_as_failed!
    update(status: 'failed')
  end

  def formatted_amount
    "#{currency_symbol} #{amount}"
  end

  private

  def currency_symbol
    case currency
    when 'USD' then '$'
    when 'KZT' then '₸'
    when 'EUR' then '€'
    when 'RUB' then '₽'
    else currency
    end
  end
end
