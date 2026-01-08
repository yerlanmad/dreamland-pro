require 'rails_helper'

RSpec.describe Whatsapp::MessageHandler do
  describe '#process' do
    let(:valid_payload) do
      {
        'chatId' => '+77001234567',
        'text' => 'Hello, I want to book a tour',
        'senderName' => 'John Doe',
        'messageId' => 'msg_123456'
      }
    end

    context 'with valid payload' do
      subject(:handler) { described_class.new(valid_payload) }

      context 'when lead does not exist' do
        it 'creates a new lead' do
          expect { handler.process }.to change(Lead, :count).by(1)
        end

        it 'sets lead attributes correctly' do
          handler.process
          lead = Lead.last

          expect(lead.phone).to eq('+77001234567')
          expect(lead.name).to eq('John Doe')
          expect(lead.source).to eq('whatsapp')
          expect(lead.status).to eq('contacted')  # Status changes from 'new' to 'contacted' during processing
        end

        it 'creates a communication record' do
          expect { handler.process }.to change(Communication, :count).by(1)
        end

        it 'sets communication attributes correctly' do
          handler.process
          communication = Communication.last

          expect(communication.communicable).to be_a(Lead)
          expect(communication.communication_type).to eq('whatsapp')
          expect(communication.direction).to eq('inbound')
          expect(communication.body).to eq('Hello, I want to book a tour')
          expect(communication.whatsapp_message_id).to eq('msg_123456')
        end

        it 'increments unread messages count' do
          handler.process
          lead = Lead.last

          expect(lead.unread_messages_count).to eq(1)
        end

        it 'updates last_message_at timestamp' do
          handler.process
          lead = Lead.last

          expect(lead.last_message_at).to be_present
          expect(lead.last_message_at).to be_within(1.second).of(Time.current)
        end

        it 'marks lead as contacted' do
          handler.process
          lead = Lead.last

          expect(lead.status).to eq('contacted')
        end

        it 'returns success response with lead_id' do
          result = handler.process

          expect(result[:success]).to be true
          expect(result[:lead_id]).to be_present
        end
      end

      context 'when lead already exists' do
        let!(:existing_lead) do
          create(:lead,
                 phone: '+77001234567',
                 name: 'Jane Smith',
                 status: :qualified,
                 unread_messages_count: 2)
        end

        it 'does not create a new lead' do
          expect { handler.process }.not_to change(Lead, :count)
        end

        it 'does not update lead name' do
          handler.process
          expect(existing_lead.reload.name).to eq('Jane Smith')
        end

        it 'does not change lead status if not new' do
          handler.process
          expect(existing_lead.reload.status).to eq('qualified')
        end

        it 'increments unread messages count' do
          handler.process
          expect(existing_lead.reload.unread_messages_count).to eq(3)
        end

        it 'creates a new communication' do
          expect { handler.process }.to change(Communication, :count).by(1)
        end

        it 'associates communication with existing lead' do
          handler.process
          communication = Communication.last

          expect(communication.communicable).to eq(existing_lead)
        end
      end

      context 'when sender name is blank' do
        before { valid_payload['senderName'] = '' }

        it 'uses default name "WhatsApp Contact"' do
          handler.process
          lead = Lead.last

          expect(lead.name).to eq('WhatsApp Contact')
        end
      end
    end

    context 'with invalid payload' do
      context 'when chatId is missing' do
        let(:invalid_payload) { { 'text' => 'Hello', 'senderName' => 'John' } }
        subject(:handler) { described_class.new(invalid_payload) }

        it 'does not create a lead' do
          expect { handler.process }.not_to change(Lead, :count)
        end

        it 'does not create a communication' do
          expect { handler.process }.not_to change(Communication, :count)
        end

        it 'returns nil' do
          expect(handler.process).to be_nil
        end
      end

      context 'when text is missing' do
        let(:invalid_payload) { { 'chatId' => '+77001234567', 'senderName' => 'John' } }
        subject(:handler) { described_class.new(invalid_payload) }

        it 'does not create a lead' do
          expect { handler.process }.not_to change(Lead, :count)
        end

        it 'does not create a communication' do
          expect { handler.process }.not_to change(Communication, :count)
        end

        it 'returns nil' do
          expect(handler.process).to be_nil
        end
      end
    end

    context 'phone normalization' do
      subject(:handler) { described_class.new(payload) }

      context 'when phone has spaces and dashes' do
        let(:payload) do
          {
            'chatId' => '7 (700) 123-45-67',
            'text' => 'Hello',
            'senderName' => 'John',
            'messageId' => 'msg_123'
          }
        end

        it 'normalizes phone correctly' do
          handler.process
          lead = Lead.last

          expect(lead.phone).to eq('+77001234567')
        end
      end

      context 'when phone has @ symbol (wazzup24 format)' do
        let(:payload) do
          {
            'chatId' => '77001234567@c.us',
            'text' => 'Hello',
            'senderName' => 'John',
            'messageId' => 'msg_123'
          }
        end

        it 'removes @ and domain' do
          handler.process
          lead = Lead.last

          expect(lead.phone).to eq('+77001234567')
        end
      end

      context 'when phone already has + prefix' do
        let(:payload) do
          {
            'chatId' => '+77001234567',
            'text' => 'Hello',
            'senderName' => 'John',
            'messageId' => 'msg_123'
          }
        end

        it 'does not add another +' do
          handler.process
          lead = Lead.last

          expect(lead.phone).to eq('+77001234567')
        end
      end
    end

    context 'error handling' do
      let(:payload_with_error) do
        {
          'chatId' => '+77001234567',
          'text' => 'Hello',
          'senderName' => 'John',
          'messageId' => 'msg_123'
        }
      end
      subject(:handler) { described_class.new(payload_with_error) }

      before do
        allow(Lead).to receive(:find_or_initialize_by).and_raise(StandardError.new('Database error'))
      end

      it 'rescues exceptions and returns error response' do
        result = handler.process

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Database error')
      end

      it 'logs the error' do
        allow(Rails.logger).to receive(:error)
        handler.process

        expect(Rails.logger).to have_received(:error).with(/WhatsApp message processing failed: Database error/)
      end
    end
  end
end
