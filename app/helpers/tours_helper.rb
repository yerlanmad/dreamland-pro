module ToursHelper
  # Tour active status badge
  def tour_status_badge(tour)
    if tour.active
      content_tag :span, "Active",
        class: "inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset bg-green-50 text-green-700 ring-green-600/20"
    else
      content_tag :span, "Inactive",
        class: "inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset bg-gray-50 text-gray-600 ring-gray-500/10"
    end
  end

  # Currency symbol helper
  def currency_symbol(currency)
    case currency.to_s.upcase
    when 'USD' then '$'
    when 'KZT' then '₸'
    when 'EUR' then '€'
    when 'RUB' then '₽'
    else currency
    end
  end

  # Format price with currency
  def format_tour_price(amount, currency)
    "#{currency_symbol(currency)}#{number_with_delimiter(amount, delimiter: ',')}"
  end

  # Capacity indicator color class for progress bar
  def capacity_color_class(available, total)
    return 'bg-gray-300' if total.zero?

    percentage = (available.to_f / total * 100)
    if percentage > 50
      'bg-green-600'
    elsif percentage > 25
      'bg-yellow-500'
    else
      'bg-red-600'
    end
  end

  # Departure status badge (upcoming/past/today)
  def departure_status_badge(departure)
    if departure.departure_date == Date.today
      content_tag :span, "Today",
        class: "inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset bg-blue-50 text-blue-700 ring-blue-700/10"
    elsif departure.departure_date > Date.today
      content_tag :span, "Upcoming",
        class: "inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset bg-green-50 text-green-700 ring-green-600/20"
    else
      content_tag :span, "Past",
        class: "inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset bg-gray-50 text-gray-600 ring-gray-500/10"
    end
  end

  # Full badge for departures with no available spots
  def departure_full_badge
    content_tag :span, "Full",
      class: "inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset bg-red-50 text-red-700 ring-red-600/10"
  end

  # Capacity percentage
  def capacity_percentage(available, total)
    return 0 if total.zero?
    ((available.to_f / total) * 100).round
  end
end
