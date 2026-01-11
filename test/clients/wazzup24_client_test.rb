require 'test_helper'

class Wazzup24ClientTest < ActiveSupport::TestCase
  setup do
    @client = Wazzup24Client.new('test_api_key')
  end

  test 'sends message successfully' do
    stub_request(:post, 'https://api.wazzup24.com/api/v3/messages')
      .with(
        headers: {
          'Authorization' => 'Bearer test_api_key',
          'Content-Type' => 'application/json'
        },
        body: {
          phone: '+1234567890@c.us',
          message: 'Test message'
        }.to_json
      )
      .to_return(status: 200, body: { messageId: 'msg_123' }.to_json)

    result = @client.send_message(phone: '+1234567890', message: 'Test message')

    assert result[:success]
    assert_equal 'msg_123', result[:data]['messageId']
  end

  test 'normalizes phone number format' do
    stub_request(:post, 'https://api.wazzup24.com/api/v3/messages')
      .with(
        body: hash_including(phone: '+1234567890@c.us')
      )
      .to_return(status: 200, body: { messageId: 'msg_123' }.to_json)

    # Test with spaces
    @client.send_message(phone: '+1 234 567 890', message: 'Test')

    # Test with dashes
    stub_request(:post, 'https://api.wazzup24.com/api/v3/messages')
      .with(
        body: hash_including(phone: '+1234567890@c.us')
      )
      .to_return(status: 200, body: { messageId: 'msg_124' }.to_json)

    @client.send_message(phone: '+1-234-567-890', message: 'Test')
  end

  test 'handles API errors gracefully' do
    stub_request(:post, 'https://api.wazzup24.com/api/v3/messages')
      .to_return(status: 400, body: { message: 'Invalid phone number' }.to_json)

    result = @client.send_message(phone: 'invalid', message: 'Test')

    assert_not result[:success]
    assert_includes result[:error], 'Invalid phone number'
  end

  test 'handles network timeouts' do
    stub_request(:post, 'https://api.wazzup24.com/api/v3/messages')
      .to_timeout

    result = @client.send_message(phone: '+1234567890', message: 'Test')

    assert_not result[:success]
    assert result[:error].present?
  end

  test 'includes media_url when provided' do
    stub_request(:post, 'https://api.wazzup24.com/api/v3/messages')
      .with(
        body: hash_including(
          phone: '+1234567890@c.us',
          message: 'Check this out',
          media_url: 'https://example.com/image.jpg'
        )
      )
      .to_return(status: 200, body: { messageId: 'msg_125' }.to_json)

    result = @client.send_message(
      phone: '+1234567890',
      message: 'Check this out',
      media_url: 'https://example.com/image.jpg'
    )

    assert result[:success]
  end

  test 'does not add @c.us if already present' do
    stub_request(:post, 'https://api.wazzup24.com/api/v3/messages')
      .with(
        body: hash_including(phone: '+1234567890@c.us')
      )
      .to_return(status: 200, body: { messageId: 'msg_126' }.to_json)

    result = @client.send_message(phone: '+1234567890@c.us', message: 'Test')

    assert result[:success]
  end
end
