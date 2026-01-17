module LeadsHelper
  def campaign_badge_class(source)
    case source&.to_s
    when 'instagram'
      'bg-gradient-to-r from-purple-500 to-pink-500 text-white'
    when 'facebook'
      'bg-blue-100 text-blue-800'
    when 'tiktok'
      'bg-gray-900 text-white'
    when 'campaign_manual'
      'bg-gray-100 text-gray-800'
    else
      'bg-gray-100 text-gray-500'
    end
  end
end
