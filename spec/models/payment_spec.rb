require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'associations' do
    it { should belong_to(:booking) }
  end

  describe 'factory' do
    it 'creates a valid payment' do
      payment = create(:payment)
      expect(payment).to be_persisted
    end

    it 'creates pending payment with trait' do
      payment = create(:payment, :pending)
      expect(payment.status).to eq('pending')
    end

    it 'creates failed payment with trait' do
      payment = create(:payment, :failed)
      expect(payment.status).to eq('failed')
    end

    it 'creates refunded payment with trait' do
      payment = create(:payment, :refunded)
      expect(payment.status).to eq('refunded')
    end
  end

  describe 'attributes' do
    let(:payment) { create(:payment, amount: 1500.50, currency: 'USD', payment_method: 'card') }

    it 'has an amount' do
      expect(payment.amount).to eq(1500.50)
    end

    it 'has a currency' do
      expect(payment.currency).to eq('USD')
    end

    it 'has a payment_date' do
      expect(payment.payment_date).to be_present
    end

    it 'has a payment_method' do
      expect(payment.payment_method).to eq('card')
    end

    it 'has a status' do
      expect(payment.status).to be_present
    end
  end

  describe 'payment tracking' do
    let(:booking) { create(:booking, total_amount: 2000, currency: 'USD') }

    it 'can have multiple payments for a booking' do
      payment1 = create(:payment, booking: booking, amount: 1000)
      payment2 = create(:payment, booking: booking, amount: 1000)

      expect(booking.payments.count).to eq(2)
      expect(booking.payments).to include(payment1, payment2)
    end

    it 'tracks partial payments' do
      create(:payment, booking: booking, amount: 500, status: 'completed')
      create(:payment, booking: booking, amount: 1500, status: 'pending')

      completed_payments = booking.payments.where(status: 'completed')
      expect(completed_payments.sum(:amount)).to eq(500)
    end
  end
end
