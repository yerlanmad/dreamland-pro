require 'test_helper'

class SimpleWazzup24Test < ActiveSupport::TestCase
  test 'initializes client with api key' do
    client = Wazzup24Client.new('test_api_key')
    assert_not_nil client
  end

  test 'normalize_phone removes plus prefix' do
    client = Wazzup24Client.new('test_api_key')
    # Call private method using send
    normalized = client.send(:normalize_phone, '+1234567890')
    assert_equal '1234567890', normalized
  end

  test 'normalize_phone removes spaces and dashes' do
    client = Wazzup24Client.new('test_api_key')
    normalized = client.send(:normalize_phone, '+1 234-567-890')
    assert_equal '1234567890', normalized
  end
end
