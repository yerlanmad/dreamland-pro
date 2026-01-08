require 'rails_helper'

RSpec.describe WebhooksController, type: :controller do
  describe 'POST #wazzup24' do
    let(:valid_payload) do
      {
        chatId: '+77001234567',
        text: 'Hello, I want to book a tour',
        senderName: 'John Doe',
        messageId: 'msg_123456'
      }
    end

    context 'with valid webhook payload' do
      it 'returns http success' do
        post :wazzup24, params: valid_payload
        expect(response).to have_http_status(:ok)
      end

      it 'creates a new lead' do
        expect {
          post :wazzup24, params: valid_payload
        }.to change(Lead, :count).by(1)
      end

      it 'creates a new communication' do
        expect {
          post :wazzup24, params: valid_payload
        }.to change(Communication, :count).by(1)
      end

      it 'calls Whatsapp::MessageHandler with params' do
        handler_instance = instance_double(Whatsapp::MessageHandler)
        allow(Whatsapp::MessageHandler).to receive(:new).and_return(handler_instance)
        allow(handler_instance).to receive(:process).and_return({ success: true, lead_id: 1 })

        post :wazzup24, params: valid_payload

        expect(Whatsapp::MessageHandler).to have_received(:new).with(hash_including(
          'chatId' => '+77001234567',
          'text' => 'Hello, I want to book a tour'
        ))
        expect(handler_instance).to have_received(:process)
      end
    end

    context 'with invalid webhook payload' do
      let(:invalid_payload) do
        {
          chatId: '',
          text: ''
        }
      end

      it 'returns unprocessable entity for invalid payload' do
        post :wazzup24, params: invalid_payload
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a lead' do
        expect {
          post :wazzup24, params: invalid_payload
        }.not_to change(Lead, :count)
      end

      it 'does not create a communication' do
        expect {
          post :wazzup24, params: invalid_payload
        }.not_to change(Communication, :count)
      end
    end

    context 'when message handler returns error' do
      before do
        handler_instance = instance_double(Whatsapp::MessageHandler)
        allow(Whatsapp::MessageHandler).to receive(:new).and_return(handler_instance)
        allow(handler_instance).to receive(:process).and_return({ success: false, error: 'Processing failed' })
      end

      it 'returns unprocessable entity status' do
        post :wazzup24, params: valid_payload
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when message handler returns nil' do
      before do
        handler_instance = instance_double(Whatsapp::MessageHandler)
        allow(Whatsapp::MessageHandler).to receive(:new).and_return(handler_instance)
        allow(handler_instance).to receive(:process).and_return(nil)
      end

      it 'returns unprocessable entity status' do
        post :wazzup24, params: valid_payload
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'CSRF protection' do
      it 'skips CSRF token verification' do
        expect(controller).to receive(:verify_authenticity_token).never
        post :wazzup24, params: valid_payload
      end

      it 'allows requests without authenticity token' do
        # Verify the controller processes webhook without CSRF token
        post :wazzup24, params: valid_payload
        expect(response).to have_http_status(:ok)
      end
    end

    context 'existing lead receives new message' do
      let!(:existing_lead) { create(:lead, phone: '+77001234567', unread_messages_count: 0) }

      it 'does not create a duplicate lead' do
        expect {
          post :wazzup24, params: valid_payload
        }.not_to change(Lead, :count)
      end

      it 'increments unread messages count' do
        post :wazzup24, params: valid_payload
        expect(existing_lead.reload.unread_messages_count).to eq(1)
      end

      it 'creates a communication for existing lead' do
        post :wazzup24, params: valid_payload
        communication = Communication.last

        expect(communication.communicable).to eq(existing_lead)
      end
    end
  end
end
