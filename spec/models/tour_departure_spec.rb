require 'rails_helper'

RSpec.describe TourDeparture, type: :model do
  describe 'associations' do
    it { should belong_to(:tour) }
    it { should have_many(:bookings).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    subject { build(:tour_departure) }

    it { should validate_presence_of(:departure_date) }
    it { should validate_presence_of(:capacity) }
    it { should validate_presence_of(:price) }
    it { should validate_presence_of(:currency) }

    it { should validate_numericality_of(:capacity).only_integer.is_greater_than(0) }
    it { should validate_numericality_of(:price).is_greater_than(0) }
  end

  describe 'enums' do
    it { should define_enum_for(:currency).with_values(USD: 'USD', KZT: 'KZT', EUR: 'EUR', RUB: 'RUB').backed_by_column_of_type(:string) }
  end

  describe 'scopes' do
    let!(:past_departure) { create(:tour_departure, departure_date: 10.days.ago) }
    let!(:today_departure) { create(:tour_departure, departure_date: Date.today) }
    let!(:future_departure_1) { create(:tour_departure, departure_date: 10.days.from_now) }
    let!(:future_departure_2) { create(:tour_departure, departure_date: 5.days.from_now) }

    describe '.upcoming' do
      it 'returns departures from today onwards' do
        upcoming = TourDeparture.upcoming
        expect(upcoming).to include(today_departure, future_departure_1, future_departure_2)
        expect(upcoming).not_to include(past_departure)
      end

      it 'orders by departure date ascending' do
        upcoming = TourDeparture.upcoming
        expect(upcoming.first).to eq(today_departure)
        expect(upcoming.second).to eq(future_departure_2)
        expect(upcoming.third).to eq(future_departure_1)
      end
    end

    describe '.past' do
      it 'returns only past departures' do
        past = TourDeparture.past
        expect(past).to include(past_departure)
        expect(past).not_to include(today_departure, future_departure_1, future_departure_2)
      end

      it 'orders by departure date descending' do
        past_1 = create(:tour_departure, departure_date: 20.days.ago)
        past_2 = create(:tour_departure, departure_date: 5.days.ago)
        past = TourDeparture.past
        expect(past.first).to eq(past_2)
        expect(past.second).to eq(past_departure)
        expect(past.third).to eq(past_1)
      end
    end
  end

  describe '#booked_spots' do
    let(:tour_departure) { create(:tour_departure, capacity: 20) }

    context 'with no bookings' do
      it 'returns 0' do
        expect(tour_departure.booked_spots).to eq(0)
      end
    end

    context 'with confirmed bookings' do
      before do
        create(:booking, tour_departure: tour_departure, num_participants: 3, status: :confirmed)
        create(:booking, tour_departure: tour_departure, num_participants: 2, status: :paid)
      end

      it 'sums participants from non-cancelled bookings' do
        expect(tour_departure.booked_spots).to eq(5)
      end
    end

    context 'with cancelled bookings' do
      before do
        create(:booking, tour_departure: tour_departure, num_participants: 3, status: :confirmed)
        create(:booking, tour_departure: tour_departure, num_participants: 5, status: :cancelled)
      end

      it 'excludes cancelled bookings from count' do
        expect(tour_departure.booked_spots).to eq(3)
      end
    end
  end

  describe '#available_spots' do
    let(:tour_departure) { create(:tour_departure, capacity: 20) }

    context 'with no bookings' do
      it 'returns full capacity' do
        expect(tour_departure.available_spots).to eq(20)
      end
    end

    context 'with some bookings' do
      before do
        create(:booking, tour_departure: tour_departure, num_participants: 7, status: :confirmed)
      end

      it 'returns capacity minus booked spots' do
        expect(tour_departure.available_spots).to eq(13)
      end
    end

    context 'when fully booked' do
      before do
        create(:booking, tour_departure: tour_departure, num_participants: 20, status: :confirmed)
      end

      it 'returns 0' do
        expect(tour_departure.available_spots).to eq(0)
      end
    end
  end

  describe '#full?' do
    let(:tour_departure) { create(:tour_departure, capacity: 10) }

    context 'when spots are available' do
      before do
        create(:booking, tour_departure: tour_departure, num_participants: 5, status: :confirmed)
      end

      it 'returns false' do
        expect(tour_departure.full?).to be false
      end
    end

    context 'when exactly full' do
      before do
        create(:booking, tour_departure: tour_departure, num_participants: 10, status: :confirmed)
      end

      it 'returns true' do
        expect(tour_departure.full?).to be true
      end
    end

    context 'when overbooked' do
      before do
        create(:booking, tour_departure: tour_departure, num_participants: 11, status: :confirmed)
      end

      it 'returns true' do
        expect(tour_departure.full?).to be true
      end
    end

    context 'with no bookings' do
      it 'returns false' do
        expect(tour_departure.full?).to be false
      end
    end
  end
end
