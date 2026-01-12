require 'rails_helper'

RSpec.describe Whatsapp::WebhookProcessor do
  describe '#process' do
    context 'test webhook' do
      let(:payload) { { 'test' => true } }
      subject(:processor) { described_class.new(payload) }

      it 'returns success for test webhook' do
        result = processor.process

        expect(result[:success]).to be true
        expect(result[:type]).to eq(:test)
      end
    end

    context 'incoming message webhook' do
      let(:payload) do
        {
          'messages' => [
            {
              'messageId' => 'msg-123',
              'channelId' => 'channel-456',
              'chatType' => 'whatsapp',
              'chatId' => '79001234567',
              'dateTime' => '2026-01-11T10:00:00.000Z',
              'type' => 'text',
              'status' => 'inbound',
              'isEcho' => false,
              'contact' => {
                'name' => 'John Doe'
              },
              'text' => 'Hello, I need help'
            }
          ]
        }
      end

      subject(:processor) { described_class.new(payload) }

      it 'creates a new client, lead, and communication' do
        expect { processor.process }.to change(Client, :count).by(1)
          .and change(Lead, :count).by(1)
          .and change(Communication, :count).by(1)
      end

      it 'sets correct communication attributes' do
        processor.process
        communication = Communication.last

        expect(communication.direction).to eq('inbound')
        expect(communication.communication_type).to eq('whatsapp')
        expect(communication.whatsapp_message_id).to eq('msg-123')
        expect(communication.body).to eq('Hello, I need help')
      end

      it 'returns success result' do
        result = processor.process

        expect(result[:success]).to be true
        expect(result[:results].first[:type]).to eq(:messages)
      end
    end

    context 'outbound echo message webhook' do
      let!(:client) { create(:client, phone: '+79001234567') }
      let!(:lead) { create(:lead, client: client, status: :qualified) }

      let(:payload) do
        {
          'messages' => [
            {
              'messageId' => 'msg-echo-123',
              'channelId' => 'channel-456',
              'chatType' => 'whatsapp',
              'chatId' => '79001234567',
              'dateTime' => '2026-01-11T10:00:00.000Z',
              'type' => 'text',
              'status' => 'sent',
              'isEcho' => true,
              'text' => 'Reply from phone',
              'authorName' => 'Agent'
            }
          ]
        }
      end

      subject(:processor) { described_class.new(payload) }

      it 'creates outbound communication for existing client' do
        expect { processor.process }.to change(Communication, :count).by(1)
      end

      it 'sets correct outbound attributes' do
        processor.process
        communication = Communication.last

        expect(communication.direction).to eq('outbound')
        expect(communication.client).to eq(client)
        expect(communication.lead).to eq(lead)
        expect(communication.whatsapp_message_id).to eq('msg-echo-123')
        expect(communication.whatsapp_status).to eq('sent')
      end
    end

    context 'status update webhook' do
      let!(:client) { create(:client, phone: '+79001234567') }
      let!(:communication) do
        create(:communication,
               client: client,
               communication_type: :whatsapp,
               direction: :outbound,
               whatsapp_message_id: 'msg-456',
               whatsapp_status: 'sent',
               body: 'Test message')
      end

      let(:payload) do
        {
          'statuses' => [
            {
              'messageId' => 'msg-456',
              'timestamp' => '2026-01-11T10:05:00.000Z',
              'status' => 'delivered'
            }
          ]
        }
      end

      subject(:processor) { described_class.new(payload) }

      it 'updates communication status' do
        processor.process
        communication.reload

        expect(communication.whatsapp_status).to eq('delivered')
      end

      it 'does not create new communication' do
        expect { processor.process }.not_to change(Communication, :count)
      end

      it 'returns success result' do
        result = processor.process

        expect(result[:success]).to be true
        expect(result[:results].first[:type]).to eq(:statuses)
      end
    end

    context 'error status update webhook' do
      let!(:client) { create(:client, phone: '+79001234567') }
      let!(:communication) do
        create(:communication,
               client: client,
               communication_type: :whatsapp,
               direction: :outbound,
               whatsapp_message_id: 'msg-error',
               whatsapp_status: 'sent',
               body: 'Test message')
      end

      let(:payload) do
        {
          'statuses' => [
            {
              'messageId' => 'msg-error',
              'timestamp' => '2026-01-11T10:05:00.000Z',
              'status' => 'error',
              'error' => {
                'error' => 'BAD_CONTACT',
                'description' => 'The contact does not exist'
              }
            }
          ]
        }
      end

      subject(:processor) { described_class.new(payload) }

      it 'updates status to error and stores error message' do
        processor.process
        communication.reload

        expect(communication.whatsapp_status).to eq('error')
        expect(communication.error_message).to include('BAD_CONTACT')
        expect(communication.error_message).to include('The contact does not exist')
      end
    end

    context 'edited message webhook' do
      let!(:client) { create(:client, phone: '+79001234567') }
      let!(:communication) do
        create(:communication,
               client: client,
               communication_type: :whatsapp,
               direction: :outbound,
               whatsapp_message_id: 'msg-edit-123',
               body: 'Original text')
      end

      let(:payload) do
        {
          'messages' => [
            {
              'messageId' => 'msg-edit-123',
              'chatType' => 'whatsapp',
              'chatId' => '79001234567',
              'isEdited' => true,
              'text' => 'Edited text',
              'oldInfo' => {
                'oldText' => 'Original text'
              }
            }
          ]
        }
      end

      subject(:processor) { described_class.new(payload) }

      it 'updates message text' do
        processor.process
        communication.reload

        expect(communication.body).to eq('Edited text')
      end

      it 'does not create new communication' do
        expect { processor.process }.not_to change(Communication, :count)
      end
    end

    context 'deleted message webhook' do
      let!(:client) { create(:client, phone: '+79001234567') }
      let!(:communication) do
        create(:communication,
               client: client,
               communication_type: :whatsapp,
               direction: :outbound,
               whatsapp_message_id: 'msg-delete-123',
               body: 'Message to delete')
      end

      let(:payload) do
        {
          'messages' => [
            {
              'messageId' => 'msg-delete-123',
              'chatType' => 'whatsapp',
              'chatId' => '79001234567',
              'isDeleted' => true,
              'oldInfo' => {
                'oldText' => 'Message to delete'
              }
            }
          ]
        }
      end

      subject(:processor) { described_class.new(payload) }

      it 'marks message as deleted' do
        processor.process
        communication.reload

        expect(communication.deleted_at).to be_present
        expect(communication.deleted?).to be true
      end

      it 'does not create new communication' do
        expect { processor.process }.not_to change(Communication, :count)
      end
    end

    context 'media message webhook' do
      let(:payload) do
        {
          'messages' => [
            {
              'messageId' => 'msg-media-123',
              'channelId' => 'channel-456',
              'chatType' => 'whatsapp',
              'chatId' => '79001234567',
              'dateTime' => '2026-01-11T10:00:00.000Z',
              'type' => 'image',
              'status' => 'inbound',
              'isEcho' => false,
              'contact' => {
                'name' => 'John Doe'
              },
              'contentUri' => 'https://store.wazzup24.com/image.jpg'
            }
          ]
        }
      end

      subject(:processor) { described_class.new(payload) }

      it 'creates communication with media' do
        processor.process
        communication = Communication.last

        expect(communication.media_url).to eq('https://store.wazzup24.com/image.jpg')
        expect(communication.media_type).to eq('image')
        expect(communication.body).to eq('[Media]')
      end
    end

    context 'combined webhook with messages and statuses' do
      let!(:client) { create(:client, phone: '+79001234567') }
      let!(:existing_communication) do
        create(:communication,
               client: client,
               communication_type: :whatsapp,
               direction: :outbound,
               whatsapp_message_id: 'msg-existing',
               whatsapp_status: 'sent',
               body: 'Existing message')
      end

      let(:payload) do
        {
          'messages' => [
            {
              'messageId' => 'msg-new',
              'chatType' => 'whatsapp',
              'chatId' => '79001234567',
              'type' => 'text',
              'status' => 'inbound',
              'isEcho' => false,
              'contact' => { 'name' => 'John' },
              'text' => 'New message'
            }
          ],
          'statuses' => [
            {
              'messageId' => 'msg-existing',
              'timestamp' => '2026-01-11T10:05:00.000Z',
              'status' => 'read'
            }
          ]
        }
      end

      subject(:processor) { described_class.new(payload) }

      it 'processes both messages and statuses' do
        result = processor.process

        expect(result[:success]).to be true
        expect(result[:results].size).to eq(2)
        expect(result[:results].map { |r| r[:type] }).to contain_exactly(:messages, :statuses)
      end

      it 'creates new message and updates existing' do
        expect { processor.process }.to change(Communication, :count).by(1)

        existing_communication.reload
        expect(existing_communication.whatsapp_status).to eq('read')
      end
    end

    context 'error handling' do
      let(:payload) do
        {
          'messages' => [
            {
              'messageId' => 'msg-invalid',
              'chatType' => 'whatsapp'
              # Missing required fields
            }
          ]
        }
      end

      subject(:processor) { described_class.new(payload) }

      it 'handles errors gracefully' do
        result = processor.process

        # Should not crash, but may have partial success
        expect(result).to be_a(Hash)
      end
    end
  end
end
