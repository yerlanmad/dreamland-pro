require 'rails_helper'

RSpec.describe Wazzup24Client do
  let(:api_key) { 'test_api_key' }
  let(:client) { described_class.new(api_key) }
  let(:channel_id) { 'd08f693e-9808-469b-92be-3af1c46c7b53' }

  describe '#send_message' do
    context 'when sending a text message successfully' do
      it 'returns success with message data' do
        stub_request(:post, 'https://api.wazzup24.com/v3/message')
          .with(
            headers: {
              'Authorization' => 'Bearer test_api_key',
              'Content-Type' => 'application/json'
            },
            body: {
              channelId: channel_id,
              chatType: 'whatsapp',
              chatId: '1234567890',
              text: 'Test message'
            }.to_json
          )
          .to_return(
            status: 201,
            body: { messageId: 'msg_123', chatId: '1234567890' }.to_json
          )

        result = client.send_message(
          channel_id: channel_id,
          phone: '+1234567890',
          text: 'Test message'
        )

        expect(result[:success]).to be true
        expect(result[:data]).to include('messageId' => 'msg_123')
      end
    end

    context 'when sending media via contentUri' do
      it 'sends contentUri instead of text' do
        stub_request(:post, 'https://api.wazzup24.com/v3/message')
          .with(
            body: hash_including(
              chatId: '1234567890',
              contentUri: 'https://example.com/image.jpg'
            )
          )
          .to_return(
            status: 201,
            body: { messageId: 'msg_125', chatId: '1234567890' }.to_json
          )

        result = client.send_message(
          phone: '+1234567890',
          content_uri: 'https://example.com/image.jpg'
        )

        expect(result[:success]).to be true
      end
    end

    context 'when including crmMessageId for idempotency' do
      it 'includes crmMessageId in request' do
        stub_request(:post, 'https://api.wazzup24.com/v3/message')
          .with(
            body: hash_including(
              chatId: '1234567890',
              text: 'Test',
              crmMessageId: 'unique_id_123'
            )
          )
          .to_return(
            status: 201,
            body: { messageId: 'msg_126', chatId: '1234567890' }.to_json
          )

        result = client.send_message(
          phone: '+1234567890',
          text: 'Test',
          crm_message_id: 'unique_id_123'
        )

        expect(result[:success]).to be true
      end
    end

    context 'when phone number needs normalization' do
      it 'removes spaces, dashes and plus sign' do
        stub_request(:post, 'https://api.wazzup24.com/v3/message')
          .with(
            body: hash_including(chatId: '1234567890')
          )
          .to_return(
            status: 201,
            body: { messageId: 'msg_123', chatId: '1234567890' }.to_json
          )

        # Test with spaces and dashes
        result = client.send_message(phone: '+1 234-567-890', text: 'Test')
        expect(result[:success]).to be true
      end
    end

    context 'when API returns error' do
      it 'returns error with proper error code' do
        stub_request(:post, 'https://api.wazzup24.com/v3/message')
          .to_return(
            status: 400,
            body: {
              error: 'INVALID_MESSAGE_DATA',
              description: 'Message data is invalid'
            }.to_json
          )

        result = client.send_message(phone: 'invalid', text: 'Test')

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Message data is invalid')
        expect(result[:error_code]).to eq('INVALID_MESSAGE_DATA')
      end
    end

    context 'when API returns repeated crmMessageId error' do
      it 'returns error message' do
        stub_request(:post, 'https://api.wazzup24.com/v3/message')
          .to_return(
            status: 400,
            body: {
              error: 'REPEATED_CRM_MESSAGE_ID',
              description: 'You have already sent message with same crmMessageId'
            }.to_json
          )

        result = client.send_message(
          phone: '+1234567890',
          text: 'Test',
          crm_message_id: 'duplicate_id'
        )

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Message with same crmMessageId already sent')
      end
    end

    context 'when network timeout occurs' do
      it 'handles timeout gracefully' do
        stub_request(:post, 'https://api.wazzup24.com/v3/message')
          .to_timeout

        result = client.send_message(phone: '+1234567890', text: 'Test')

        expect(result[:success]).to be false
        expect(result[:error]).to be_present
      end
    end

    context 'when neither text nor contentUri provided' do
      it 'returns error' do
        result = client.send_message(phone: '+1234567890')

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Either text or contentUri must be provided')
      end
    end
  end

  describe '#get_channels' do
    context 'when request is successful' do
      it 'returns list of channels' do
        stub_request(:get, 'https://api.wazzup24.com/v3/channels')
          .with(
            headers: {
              'Authorization' => 'Bearer test_api_key'
            }
          )
          .to_return(
            status: 200,
            body: [
              {
                channelId: channel_id,
                transport: 'whatsapp',
                plainId: '79865784457',
                state: 'active'
              }
            ].to_json
          )

        result = client.get_channels

        expect(result[:success]).to be true
        expect(result[:data]).to be_an(Array)
        expect(result[:data].first).to include(
          'channelId' => channel_id,
          'transport' => 'whatsapp',
          'state' => 'active'
        )
      end
    end

    context 'when request fails' do
      it 'returns error' do
        stub_request(:get, 'https://api.wazzup24.com/v3/channels')
          .to_timeout

        result = client.get_channels

        expect(result[:success]).to be false
        expect(result[:error]).to be_present
      end
    end
  end

  describe '#edit_message' do
    let(:message_id) { 'msg_123' }

    context 'when editing text successfully' do
      it 'returns success' do
        stub_request(:patch, "https://api.wazzup24.com/v3/message/#{message_id}")
          .with(
            headers: {
              'Authorization' => 'Bearer test_api_key',
              'Content-Type' => 'application/json'
            },
            body: {
              text: 'Updated text'
            }.to_json
          )
          .to_return(status: 200, body: {}.to_json)

        result = client.edit_message(message_id: message_id, text: 'Updated text')

        expect(result[:success]).to be true
      end
    end

    context 'when editing time expired' do
      it 'returns error' do
        stub_request(:patch, "https://api.wazzup24.com/v3/message/#{message_id}")
          .to_return(
            status: 400,
            body: {
              error: 'MESSAGES_EDITING_TIME_EXPIRED',
              description: 'The message editing time has expired'
            }.to_json
          )

        result = client.edit_message(message_id: message_id, text: 'Updated')

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Message editing time expired')
      end
    end

    context 'when neither text nor contentUri provided' do
      it 'returns error' do
        result = client.edit_message(message_id: message_id)

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Either text or contentUri must be provided')
      end
    end
  end

  describe '#delete_message' do
    let(:message_id) { 'msg_123' }

    context 'when deleting successfully' do
      it 'returns success' do
        stub_request(:delete, "https://api.wazzup24.com/v3/message/#{message_id}")
          .with(
            headers: {
              'Authorization' => 'Bearer test_api_key'
            }
          )
          .to_return(status: 200, body: {}.to_json)

        result = client.delete_message(message_id: message_id)

        expect(result[:success]).to be true
      end
    end

    context 'when deletion time expired' do
      it 'returns error' do
        stub_request(:delete, "https://api.wazzup24.com/v3/message/#{message_id}")
          .to_return(
            status: 400,
            body: {
              error: 'MESSAGES_DELETION_TIME_EXPIRED',
              description: 'The deletion time for the message has expired'
            }.to_json
          )

        result = client.delete_message(message_id: message_id)

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Message deletion time expired')
      end
    end
  end

  describe 'private #normalize_phone' do
    it 'removes plus sign, spaces, and dashes' do
      normalized = client.send(:normalize_phone, '+1 234-567-890')
      expect(normalized).to eq('1234567890')
    end

    it 'handles phone without plus sign' do
      normalized = client.send(:normalize_phone, '1234567890')
      expect(normalized).to eq('1234567890')
    end

    it 'handles empty phone' do
      normalized = client.send(:normalize_phone, nil)
      expect(normalized).to be_nil
    end
  end
end
