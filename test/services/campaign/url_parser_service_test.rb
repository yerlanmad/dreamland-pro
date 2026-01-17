# frozen_string_literal: true

require "test_helper"

module Campaign
  class UrlParserServiceTest < ActiveSupport::TestCase
    # Instagram tests
    test "parses Instagram post URL" do
      text = "Привет! Можно узнать об этом подробнее? https://www.instagram.com/p/DSC3_DQANZB/"
      result = Campaign::UrlParserService.new(text).call

      assert_equal 'instagram', result[:campaign_source]
      assert_equal 'DSC3_DQANZB', result[:campaign_id]
      assert_includes result[:campaign_url], 'instagram.com/p/DSC3_DQANZB'
    end

    test "parses Instagram post URL without www" do
      text = "Check this https://instagram.com/p/ABC123XYZ/"
      result = Campaign::UrlParserService.new(text).call

      assert_equal 'instagram', result[:campaign_source]
      assert_equal 'ABC123XYZ', result[:campaign_id]
    end

    test "parses Instagram reel URL" do
      text = "Check this out https://www.instagram.com/reel/ABC123XYZ/"
      result = Campaign::UrlParserService.new(text).call

      assert_equal 'instagram', result[:campaign_source]
      assert_equal 'ABC123XYZ', result[:campaign_id]
    end

    test "parses Instagram story URL" do
      text = "https://www.instagram.com/stories/username/1234567890123456789/"
      result = Campaign::UrlParserService.new(text).call

      assert_equal 'instagram', result[:campaign_source]
      assert_equal '1234567890123456789', result[:campaign_id]
    end

    # Facebook tests
    test "parses Facebook permalink URL" do
      text = "Здравствуйте! https://www.facebook.com/permalink.php?story_fbid=123456789&id=987654321"
      result = Campaign::UrlParserService.new(text).call

      assert_equal 'facebook', result[:campaign_source]
      assert_equal '123456789', result[:campaign_id]
    end

    test "parses Facebook post URL" do
      text = "Hi https://www.facebook.com/pagename/posts/123456789"
      result = Campaign::UrlParserService.new(text).call

      assert_equal 'facebook', result[:campaign_source]
      assert_equal '123456789', result[:campaign_id]
    end

    test "parses Facebook photo URL" do
      text = "Look at https://www.facebook.com/photo/?fbid=123456789"
      result = Campaign::UrlParserService.new(text).call

      assert_equal 'facebook', result[:campaign_source]
      assert_equal '123456789', result[:campaign_id]
    end

    test "parses mobile Facebook URL" do
      text = "Look at this https://m.facebook.com/story.php?story_fbid=123456789"
      result = Campaign::UrlParserService.new(text).call

      assert_equal 'facebook', result[:campaign_source]
      assert_equal '123456789', result[:campaign_id]
    end

    # TikTok tests
    test "parses TikTok video URL" do
      text = "https://www.tiktok.com/@username/video/1234567890123456789"
      result = Campaign::UrlParserService.new(text).call

      assert_equal 'tiktok', result[:campaign_source]
      assert_equal '1234567890123456789', result[:campaign_id]
    end

    test "parses TikTok short URL" do
      text = "Check https://vm.tiktok.com/ZM6ABC123/"
      result = Campaign::UrlParserService.new(text).call

      assert_equal 'tiktok', result[:campaign_source]
      assert_equal 'ZM6ABC123', result[:campaign_id]
    end

    # Edge cases
    test "returns empty result for text without URLs" do
      text = "Привет, хочу узнать про тур"
      result = Campaign::UrlParserService.new(text).call

      assert_nil result[:campaign_source]
      assert_nil result[:campaign_id]
      assert_nil result[:campaign_url]
    end

    test "returns empty result for nil input" do
      result = Campaign::UrlParserService.new(nil).call

      assert_nil result[:campaign_source]
      assert_nil result[:campaign_id]
      assert_nil result[:campaign_url]
    end

    test "returns empty result for empty string" do
      result = Campaign::UrlParserService.new("").call

      assert_nil result[:campaign_source]
      assert_nil result[:campaign_id]
      assert_nil result[:campaign_url]
    end

    test "returns empty result for non-social URLs" do
      text = "Check out https://example.com/page"
      result = Campaign::UrlParserService.new(text).call

      assert_nil result[:campaign_source]
    end

    test "handles multiple URLs - returns first match" do
      text = "https://www.instagram.com/p/ABC123/ and also https://facebook.com/posts/456"
      result = Campaign::UrlParserService.new(text).call

      assert_equal 'instagram', result[:campaign_source]
      assert_equal 'ABC123', result[:campaign_id]
    end

    test "handles URL with Cyrillic text around it" do
      text = "Добрый день! Хочу узнать подробности https://www.instagram.com/p/TestPost123/ Спасибо!"
      result = Campaign::UrlParserService.new(text).call

      assert_equal 'instagram', result[:campaign_source]
      assert_equal 'TestPost123', result[:campaign_id]
    end

    test "strips trailing punctuation from URL" do
      text = "Check this: https://www.instagram.com/p/ABC123/."
      result = Campaign::UrlParserService.new(text).call

      assert_equal 'instagram', result[:campaign_source]
      refute result[:campaign_url].end_with?('.')
    end

    test "handles URL at end of message without trailing slash" do
      text = "https://www.instagram.com/p/ABC123"
      result = Campaign::UrlParserService.new(text).call

      assert_equal 'instagram', result[:campaign_source]
      assert_equal 'ABC123', result[:campaign_id]
    end
  end
end
