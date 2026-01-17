module ApplicationHelper
  # Flash message styling
  def flash_class(type)
    case type.to_sym
    when :notice, :success
      "bg-white text-green-900 border-l-4 border-green-500 shadow-lg ring-1 ring-green-200"
    when :alert, :error
      "bg-white text-red-900 border-l-4 border-red-500 shadow-lg ring-1 ring-red-200"
    when :warning
      "bg-white text-yellow-900 border-l-4 border-yellow-500 shadow-lg ring-1 ring-yellow-200"
    else
      "bg-white text-blue-900 border-l-4 border-blue-500 shadow-lg ring-1 ring-blue-200"
    end
  end

  # Status badge styling for leads
  def status_badge_class(status)
    case status.to_s
    when 'new'
      'bg-green-100 text-green-800 ring-1 ring-green-600/20'
    when 'contacted'
      'bg-blue-100 text-blue-800 ring-1 ring-blue-600/20'
    when 'qualified'
      'bg-purple-100 text-purple-800 ring-1 ring-purple-600/20'
    when 'quoted'
      'bg-yellow-100 text-yellow-800 ring-1 ring-yellow-600/20'
    when 'won'
      'bg-emerald-100 text-emerald-800 ring-1 ring-emerald-600/20'
    when 'lost'
      'bg-red-100 text-red-800 ring-1 ring-red-600/20'
    else
      'bg-gray-100 text-gray-800 ring-1 ring-gray-600/20'
    end
  end

  # Status badge with improved styling
  def status_badge(status, options = {})
    classes = "inline-flex items-center rounded-md px-2 py-1 text-xs font-medium #{status_badge_class(status)}"
    classes += " #{options[:class]}" if options[:class]

    content_tag(:span, status.to_s.titleize, class: classes)
  end

  # Button helpers for consistent styling
  def primary_button(text, url, options = {})
    default_classes = "inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-colors duration-200"
    classes = options[:class] ? "#{default_classes} #{options[:class]}" : default_classes

    link_to text, url, class: classes
  end

  def secondary_button(text, url, options = {})
    default_classes = "inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md shadow-sm text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-colors duration-200"
    classes = options[:class] ? "#{default_classes} #{options[:class]}" : default_classes

    link_to text, url, class: classes
  end

  def danger_button(text, url, options = {})
    default_classes = "inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 transition-colors duration-200"
    classes = options[:class] ? "#{default_classes} #{options[:class]}" : default_classes

    button_to text, url, class: classes, **options.except(:class)
  end

  # Card component
  def card(options = {}, &block)
    classes = "bg-white overflow-hidden shadow rounded-lg"
    classes += " #{options[:class]}" if options[:class]

    content_tag(:div, class: classes, &block)
  end

  # Page title helper
  def page_title(title, subtitle = nil)
    content = content_tag(:h1, title, class: "text-3xl font-bold leading-tight text-gray-900")
    if subtitle
      content += content_tag(:p, subtitle, class: "mt-2 text-sm text-gray-600")
    end
    content_tag(:div, content, class: "mb-6")
  end

  # Navigation active state
  def nav_link_class(path)
    base_class = "inline-flex items-center px-1 pt-1 text-sm font-medium border-b-2 transition-colors duration-200"
    if current_page?(path)
      "#{base_class} border-indigo-500 text-gray-900"
    else
      "#{base_class} border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700"
    end
  end

  # Empty state component
  def empty_state(title, description, icon: nil, action: nil, &block)
    content_tag(:div, class: "text-center py-12") do
      concat(content_tag(:div, icon, class: "mx-auto h-12 w-12 text-gray-400")) if icon
      concat(content_tag(:h3, title, class: "mt-2 text-sm font-semibold text-gray-900"))
      concat(content_tag(:p, description, class: "mt-1 text-sm text-gray-500"))
      concat(content_tag(:div, action, class: "mt-6")) if action
      concat(capture(&block)) if block_given?
    end
  end

  # Stat card component
  def stat_card(label, value, icon: nil, color: "gray", trend: nil)
    color_classes = {
      "gray" => "text-gray-400",
      "green" => "text-green-400",
      "blue" => "text-blue-400",
      "yellow" => "text-yellow-400",
      "red" => "text-red-400",
      "purple" => "text-purple-400"
    }

    content_tag(:div, class: "bg-white overflow-hidden shadow rounded-lg") do
      content_tag(:div, class: "p-5") do
        content_tag(:div, class: "flex items-center") do
          html = ""
          if icon
            html += content_tag(:div, class: "flex-shrink-0") do
              content_tag(:div, icon.html_safe, class: "h-6 w-6 #{color_classes[color] || color_classes['gray']}")
            end
          end
          html += content_tag(:div, class: "#{icon ? 'ml-5' : ''} w-0 flex-1") do
            content_tag(:dl) do
              dt = content_tag(:dt, label, class: "text-sm font-medium text-gray-500 truncate")
              dd = content_tag(:dd, class: "flex items-baseline") do
                val = content_tag(:div, value, class: "text-2xl font-semibold text-gray-900")
                val += content_tag(:span, trend, class: "ml-2 text-sm font-medium text-green-600") if trend
                val.html_safe
              end
              (dt + dd).html_safe
            end
          end
          html.html_safe
        end
      end
    end
  end
end
