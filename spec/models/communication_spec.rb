require 'rails_helper'

RSpec.describe Communication, type: :model do
  describe 'associations' do
    it { should belong_to(:communicable) }
  end

  describe 'validations' do
    subject { build(:communication) }

    it { should validate_presence_of(:communication_type) }
    it { should validate_presence_of(:direction) }
    it { should validate_presence_of(:body) }
  end

  describe 'enums' do
    it { should define_enum_for(:communication_type).with_values(whatsapp: 'whatsapp', email: 'email', phone: 'phone', sms: 'sms').with_prefix(:type).backed_by_column_of_type(:string) }
    it { should define_enum_for(:direction).with_values(inbound: 'inbound', outbound: 'outbound').backed_by_column_of_type(:string) }
  end

  describe 'polymorphic associations' do
    context 'when communicable is a Lead' do
      let(:lead) { create(:lead) }
      let(:communication) { create(:communication, communicable: lead) }

      it 'belongs to a lead' do
        expect(communication.communicable).to eq(lead)
        expect(communication.communicable_type).to eq('Lead')
      end
    end

    context 'when communicable is a Booking' do
      let(:booking) { create(:booking) }
      let(:communication) { create(:communication, communicable: booking) }

      it 'belongs to a booking' do
        expect(communication.communicable).to eq(booking)
        expect(communication.communicable_type).to eq('Booking')
      end
    end
  end

  describe 'scopes' do
    describe '.recent' do
      let!(:old_communication) { create(:communication, created_at: 2.days.ago) }
      let!(:new_communication) { create(:communication, created_at: 1.hour.ago) }
      let!(:newest_communication) { create(:communication, created_at: 5.minutes.ago) }

      it 'orders by created_at descending' do
        recent = Communication.recent
        expect(recent.first).to eq(newest_communication)
        expect(recent.second).to eq(new_communication)
        expect(recent.third).to eq(old_communication)
      end
    end

    describe '.whatsapp_messages' do
      let!(:whatsapp_comm) { create(:communication, communication_type: :whatsapp) }
      let!(:email_comm) { create(:communication, communication_type: :email) }
      let!(:phone_comm) { create(:communication, communication_type: :phone) }

      it 'returns only WhatsApp communications' do
        whatsapp_messages = Communication.whatsapp_messages
        expect(whatsapp_messages).to include(whatsapp_comm)
        expect(whatsapp_messages).not_to include(email_comm, phone_comm)
      end
    end
  end

  describe 'enum prefix' do
    let(:communication) { build(:communication, communication_type: :whatsapp) }

    it 'uses type_ prefix for communication_type enum methods' do
      expect(communication).to respond_to(:type_whatsapp?)
      expect(communication).to respond_to(:type_email?)
      expect(communication.type_whatsapp?).to be true
    end
  end

  describe 'WhatsApp-specific attributes' do
    let(:communication) do
      create(:communication,
             communication_type: :whatsapp,
             whatsapp_message_id: 'msg_123',
             media_url: 'https://example.com/image.jpg',
             media_type: 'image/jpeg')
    end

    it 'stores WhatsApp message ID' do
      expect(communication.whatsapp_message_id).to eq('msg_123')
    end

    it 'stores media URL' do
      expect(communication.media_url).to eq('https://example.com/image.jpg')
    end

    it 'stores media type' do
      expect(communication.media_type).to eq('image/jpeg')
    end
  end

  describe 'direction' do
    it 'can be inbound' do
      communication = build(:communication, direction: :inbound)
      expect(communication.inbound?).to be true
      expect(communication.outbound?).to be false
    end

    it 'can be outbound' do
      communication = build(:communication, direction: :outbound)
      expect(communication.outbound?).to be true
      expect(communication.inbound?).to be false
    end
  end
end
