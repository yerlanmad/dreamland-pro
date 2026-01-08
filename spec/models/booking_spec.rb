require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe 'associations' do
    it { should belong_to(:lead) }
    it { should belong_to(:tour_departure) }
    it { should have_many(:payments).dependent(:destroy) }
    it { should have_many(:communications).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:booking) }

    it { should validate_presence_of(:num_participants) }
    it { should validate_presence_of(:total_amount) }
    it { should validate_presence_of(:currency) }
    it { should validate_presence_of(:status) }

    it { should validate_numericality_of(:num_participants).only_integer.is_greater_than(0) }
    it { should validate_numericality_of(:total_amount).is_greater_than(0) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(confirmed: 'confirmed', paid: 'paid', completed: 'completed', cancelled: 'cancelled').backed_by_column_of_type(:string) }
    it { should define_enum_for(:currency).with_values(USD: 'USD', KZT: 'KZT', EUR: 'EUR', RUB: 'RUB').backed_by_column_of_type(:string) }
  end

  describe 'scopes' do
    let(:tour_past) { create(:tour) }
    let(:tour_future) { create(:tour) }
    let!(:past_departure) { create(:tour_departure, tour: tour_past, departure_date: 10.days.ago) }
    let!(:future_departure) { create(:tour_departure, tour: tour_future, departure_date: 10.days.from_now) }
    let!(:past_booking) { create(:booking, tour_departure: past_departure) }
    let!(:upcoming_booking) { create(:booking, tour_departure: future_departure) }

    describe '.upcoming' do
      it 'returns bookings for future departures only' do
        upcoming = Booking.upcoming
        expect(upcoming).to include(upcoming_booking)
        expect(upcoming).not_to include(past_booking)
      end
    end

    describe '.by_status' do
      let!(:confirmed_booking) { create(:booking, status: :confirmed) }
      let!(:paid_booking) { create(:booking, :paid) }

      it 'returns bookings with specified status' do
        confirmed = Booking.by_status('confirmed')
        expect(confirmed).to include(confirmed_booking)
        expect(confirmed).not_to include(paid_booking)
      end
    end
  end

  describe '#reference_number' do
    it 'generates a reference number in format BK-XXXXXX' do
      booking = create(:booking)
      expect(booking.reference_number).to match(/\ABK-\d{6}\z/)
    end

    it 'pads the ID with leading zeros' do
      booking = create(:booking)
      allow(booking).to receive(:id).and_return(42)
      expect(booking.reference_number).to eq('BK-000042')
    end

    it 'handles large IDs correctly' do
      booking = create(:booking)
      allow(booking).to receive(:id).and_return(123456)
      expect(booking.reference_number).to eq('BK-123456')
    end
  end

  describe '#tour_name' do
    it 'returns the tour name through tour_departure' do
      tour = create(:tour, name: 'Amazing Tour')
      tour_departure = create(:tour_departure, tour: tour)
      booking = create(:booking, tour_departure: tour_departure)

      expect(booking.tour_name).to eq('Amazing Tour')
    end
  end

  describe 'lifecycle' do
    let(:booking) { create(:booking, status: :confirmed) }

    it 'can transition from confirmed to paid' do
      booking.paid!
      expect(booking.status).to eq('paid')
    end

    it 'can transition from paid to completed' do
      booking.paid!
      booking.completed!
      expect(booking.status).to eq('completed')
    end

    it 'can be cancelled from any status' do
      booking.cancelled!
      expect(booking.status).to eq('cancelled')
    end
  end
end
