require 'rails_helper'

RSpec.describe Tour, type: :model do
  describe 'associations' do
    it { should have_many(:tour_departures).dependent(:destroy) }
    it { should have_many(:interested_leads).class_name('Lead').with_foreign_key('tour_interest_id').dependent(:nullify) }
  end

  describe 'validations' do
    subject { build(:tour) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:base_price) }
    it { should validate_presence_of(:currency) }
    it { should validate_presence_of(:duration_days) }
    it { should validate_presence_of(:capacity) }

    it { should validate_numericality_of(:base_price).is_greater_than(0) }
    it { should validate_numericality_of(:duration_days).only_integer.is_greater_than(0) }
    it { should validate_numericality_of(:capacity).only_integer.is_greater_than(0) }
  end

  describe 'enums' do
    it { should define_enum_for(:currency).with_values(USD: 'USD', KZT: 'KZT', EUR: 'EUR', RUB: 'RUB').backed_by_column_of_type(:string) }
  end

  describe 'scopes' do
    let!(:active_tour) { create(:tour, active: true) }
    let!(:inactive_tour) { create(:tour, :inactive) }

    describe '.active' do
      it 'returns only active tours' do
        expect(Tour.active).to include(active_tour)
        expect(Tour.active).not_to include(inactive_tour)
      end
    end

    describe '.inactive' do
      it 'returns only inactive tours' do
        expect(Tour.inactive).to include(inactive_tour)
        expect(Tour.inactive).not_to include(active_tour)
      end
    end

    describe '.by_currency' do
      let!(:usd_tour) { create(:tour, currency: :USD) }
      let!(:kzt_tour) { create(:tour, currency: :KZT) }

      it 'returns tours with specified currency' do
        expect(Tour.by_currency('USD')).to include(usd_tour)
        expect(Tour.by_currency('USD')).not_to include(kzt_tour)
      end
    end
  end

  describe '#activate!' do
    it 'sets active to true' do
      tour = create(:tour, :inactive)
      tour.activate!
      expect(tour.reload.active).to be true
    end
  end

  describe '#deactivate!' do
    it 'sets active to false' do
      tour = create(:tour, active: true)
      tour.deactivate!
      expect(tour.reload.active).to be false
    end
  end

  describe '#upcoming_departures' do
    let(:tour) { create(:tour) }
    let!(:past_departure) { create(:tour_departure, tour: tour, departure_date: 10.days.ago) }
    let!(:today_departure) { create(:tour_departure, tour: tour, departure_date: Date.today) }
    let!(:future_departure_1) { create(:tour_departure, tour: tour, departure_date: 10.days.from_now) }
    let!(:future_departure_2) { create(:tour_departure, tour: tour, departure_date: 5.days.from_now) }

    it 'returns only departures from today onwards' do
      upcoming = tour.upcoming_departures
      expect(upcoming).to include(today_departure, future_departure_1, future_departure_2)
      expect(upcoming).not_to include(past_departure)
    end

    it 'orders departures by date ascending' do
      upcoming = tour.upcoming_departures
      expect(upcoming.first).to eq(today_departure)
      expect(upcoming.second).to eq(future_departure_2)
      expect(upcoming.third).to eq(future_departure_1)
    end
  end

  describe 'default values' do
    it 'factory defaults active to true' do
      tour = create(:tour)
      expect(tour.active).to be true
    end
  end
end
