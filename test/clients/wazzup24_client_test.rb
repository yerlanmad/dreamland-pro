require 'test_helper'

class Wazzup24ClientTest < ActiveSupport::TestCase
  setup do
    @client = Wazzup24Client.new('test_api_key')
    @channel_id = 'd08f693e-9808-469b-92be-3af1c46c7b53'
  end

  test 'sends message successfully with new API format' do
    stub_request(:post, 'https://api.wazzup24.com/v3/message')
      .with(
        headers: {
          'Authorization' => 'Bearer test_api_key',
          'Content-Type' => 'application/json'
        },
        body: {
          channelId: @channel_id,
          chatType: 'whatsapp',
          chatId: '1234567890',
          text: 'Test message'
        }.to_json
      )
      .to_return(status: 201, body: { messageId: 'msg_123', chatId: '1234567890' }.to_json)

    result = @client.send_message(
      channel_id: @channel_id,
      phone: '+1234567890',
      text: 'Test message'
    )

    assert result[:success]
    assert_equal 'msg_123', result[:data]['messageId']
  end

  test 'normalizes phone number format' do
    stub_request(:post, 'https://api.wazzup24.com/v3/message')
      .with(
        body: hash_including(chatId: '1234567890')
      )
      .to_return(status: 201, body: { messageId: 'msg_123', chatId: '1234567890' }.to_json)

    # Test with spaces
    @client.send_message(phone: '+1 234 567 890', text: 'Test')

    # Test with dashes
    stub_request(:post, 'https://api.wazzup24.com/v3/message')
      .with(
        body: hash_including(chatId: '1234567890')
      )
      .to_return(status: 201, body: { messageId: 'msg_124', chatId: '1234567890' }.to_json)

    @client.send_message(phone: '+1-234-567-890', text: 'Test')
  end

  test 'handles API errors gracefully' do
    stub_request(:post, 'https://api.wazzup24.com/v3/message')
      .to_return(
        status: 400,
        body: {
          error: 'INVALID_MESSAGE_DATA',
          description: 'Message data is invalid'
        }.to_json
      )

    result = @client.send_message(phone: 'invalid', text: 'Test')

    assert_not result[:success]
    assert_equal 'Message data is invalid', result[:error]
    assert_equal 'INVALID_MESSAGE_DATA', result[:error_code]
  end

  test 'handles network timeouts' do
    stub_request(:post, 'https://api.wazzup24.com/v3/message')
      .to_timeout

    result = @client.send_message(phone: '+1234567890', text: 'Test')

    assert_not result[:success]
    assert result[:error].present?
  end

  test 'sends media via contentUri' do
    stub_request(:post, 'https://api.wazzup24.com/v3/message')
      .with(
        body: hash_including(
          chatId: '1234567890',
          contentUri: 'https://example.com/image.jpg'
        )
      )
      .to_return(status: 201, body: { messageId: 'msg_125', chatId: '1234567890' }.to_json)

    result = @client.send_message(
      phone: '+1234567890',
      content_uri: 'https://example.com/image.jpg'
    )

    assert result[:success]
  end

  test 'includes crmMessageId for idempotency' do
    stub_request(:post, 'https://api.wazzup24.com/v3/message')
      .with(
        body: hash_including(
          chatId: '1234567890',
          text: 'Test',
          crmMessageId: 'unique_id_123'
        )
      )
      .to_return(status: 201, body: { messageId: 'msg_126', chatId: '1234567890' }.to_json)

    result = @client.send_message(
      phone: '+1234567890',
      text: 'Test',
      crm_message_id: 'unique_id_123'
    )

    assert result[:success]
  end

  test 'handles repeated crmMessageId error' do
    stub_request(:post, 'https://api.wazzup24.com/v3/message')
      .to_return(
        status: 400,
        body: {
          error: 'REPEATED_CRM_MESSAGE_ID',
          description: 'You have already sent message with same crmMessageId'
        }.to_json
      )

    result = @client.send_message(
      phone: '+1234567890',
      text: 'Test',
      crm_message_id: 'duplicate_id'
    )

    assert_not result[:success]
    assert_equal 'Message with same crmMessageId already sent', result[:error]
  end

  test 'gets channels successfully' do
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
            channelId: @channel_id,
            transport: 'whatsapp',
            plainId: '79865784457',
            state: 'active'
          }
        ].to_json
      )

    result = @client.get_channels

    assert result[:success]
    assert_equal 1, result[:data].length
    assert_equal @channel_id, result[:data].first['channelId']
  end

  test 'edits message successfully' do
    message_id = 'msg_123'
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

    result = @client.edit_message(message_id: message_id, text: 'Updated text')

    assert result[:success]
  end

  test 'deletes message successfully' do
    message_id = 'msg_123'
    stub_request(:delete, "https://api.wazzup24.com/v3/message/#{message_id}")
      .with(
        headers: {
          'Authorization' => 'Bearer test_api_key'
        }
      )
      .to_return(status: 200, body: {}.to_json)

    result = @client.delete_message(message_id: message_id)

    assert result[:success]
  end

  test 'handles edit time expired error' do
    message_id = 'msg_123'
    stub_request(:patch, "https://api.wazzup24.com/v3/message/#{message_id}")
      .to_return(
        status: 400,
        body: {
          error: 'MESSAGES_EDITING_TIME_EXPIRED',
          description: 'The message editing time has expired'
        }.to_json
      )

    result = @client.edit_message(message_id: message_id, text: 'Updated')

    assert_not result[:success]
    assert_equal 'Message editing time expired', result[:error]
  end
end
