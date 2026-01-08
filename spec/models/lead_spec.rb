require 'rails_helper'

RSpec.describe Lead, type: :model do
  describe 'associations' do
    it { should belong_to(:assigned_agent).class_name('User').optional }
    it { should belong_to(:tour_interest).class_name('Tour').optional }
    it { should have_many(:communications) }
    it { should have_one(:booking) }
  end

  describe 'validations' do
    subject { build(:lead) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:phone) }
    it { should validate_uniqueness_of(:phone).case_insensitive }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:source) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(new: 'new', contacted: 'contacted', qualified: 'qualified', quoted: 'quoted', won: 'won', lost: 'lost').with_prefix(:status).backed_by_column_of_type(:string) }
    it { should define_enum_for(:source).with_values(whatsapp: 'whatsapp', website: 'website', manual: 'manual', import: 'import').backed_by_column_of_type(:string) }
  end

  describe 'phone normalization' do
    it 'normalizes phone number before validation' do
      lead = build(:lead, phone: '+7 (700) 123-45-67')
      lead.valid?
      expect(lead.phone).to eq('+77001234567')
    end

    it 'adds + prefix if missing' do
      lead = build(:lead, phone: '77001234567')
      lead.valid?
      expect(lead.phone).to start_with('+')
    end
  end

  describe '#mark_as_contacted!' do
    it 'updates status to contacted if new' do
      lead = create(:lead, status: :new)
      lead.mark_as_contacted!
      expect(lead.status).to eq('contacted')
    end

    it 'does not update if not new' do
      lead = create(:lead, status: :qualified)
      lead.mark_as_contacted!
      expect(lead.status).to eq('qualified')
    end
  end

  describe '#increment_unread_messages!' do
    it 'increments unread message count' do
      lead = create(:lead, unread_messages_count: 2)
      expect { lead.increment_unread_messages! }.to change { lead.unread_messages_count }.from(2).to(3)
    end

    it 'updates last_message_at timestamp' do
      lead = create(:lead)
      expect { lead.increment_unread_messages! }.to change { lead.last_message_at }
    end
  end

  describe '#convert_to_booking!' do
    let(:tour) { create(:tour) }
    let(:tour_departure) { create(:tour_departure, tour: tour, price: 1000, currency: 'USD') }
    let(:lead) { create(:lead, status: :qualified) }

    it 'creates a booking and marks lead as won' do
      booking = lead.convert_to_booking!(tour_departure, 2)

      expect(booking).to be_persisted
      expect(booking.num_participants).to eq(2)
      expect(booking.total_amount).to eq(2000)
      expect(lead.reload.status).to eq('won')
    end
  end
end
