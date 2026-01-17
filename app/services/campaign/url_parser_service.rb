# frozen_string_literal: true

module Campaign
  class UrlParserService
    PLATFORM_PATTERNS = {
      instagram: [
        # Instagram post: https://www.instagram.com/p/DSC3_DQANZB/
        %r{(?:https?://)?(?:www\.)?instagram\.com/p/([A-Za-z0-9_-]+)}i,
        # Instagram reel: https://www.instagram.com/reel/DSC3_DQANZB/
        %r{(?:https?://)?(?:www\.)?instagram\.com/reel/([A-Za-z0-9_-]+)}i,
        # Instagram story highlight
        %r{(?:https?://)?(?:www\.)?instagram\.com/stories/[^/]+/(\d+)}i
      ],
      facebook: [
        # Facebook permalink: https://www.facebook.com/permalink.php?story_fbid=123&id=456
        %r{(?:https?://)?(?:www\.)?facebook\.com/permalink\.php\?.*?story_fbid=(\d+)}i,
        # Facebook post: https://www.facebook.com/pagename/posts/123456
        %r{(?:https?://)?(?:www\.)?facebook\.com/[^/]+/posts/([A-Za-z0-9]+)}i,
        # Facebook photo: https://www.facebook.com/photo/?fbid=123
        %r{(?:https?://)?(?:www\.)?facebook\.com/photo/?\?.*?fbid=(\d+)}i,
        # Mobile Facebook: https://m.facebook.com/story.php?story_fbid=123
        %r{(?:https?://)?m\.facebook\.com/story\.php\?.*?story_fbid=(\d+)}i
      ],
      tiktok: [
        # TikTok video: https://www.tiktok.com/@user/video/1234567890
        %r{(?:https?://)?(?:www\.)?tiktok\.com/@[^/]+/video/(\d+)}i,
        # TikTok short link: https://vm.tiktok.com/ABC123/
        %r{(?:https?://)?vm\.tiktok\.com/([A-Za-z0-9]+)}i
      ]
    }.freeze

    attr_reader :text

    def initialize(text)
      @text = text
    end

    def call
      return empty_result if text.blank?

      PLATFORM_PATTERNS.each do |platform, patterns|
        patterns.each do |pattern|
          match = text.match(pattern)
          if match
            return {
              campaign_source: platform.to_s,
              campaign_id: match[1],
              campaign_url: extract_full_url
            }
          end
        end
      end

      empty_result
    end

    private

    def extract_full_url
      url_match = text.match(%r{https?://[^\s<>"]+}i)
      url_match&.[](0)&.gsub(/[.,;:!?)\]]+\z/, '') # Remove trailing punctuation
    end

    def empty_result
      { campaign_source: nil, campaign_id: nil, campaign_url: nil }
    end
  end
end
