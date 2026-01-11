module BookingsHelper
  def booking_status_badge(status)
    color_class = case status.to_s
                  when 'confirmed'
                    'bg-blue-100 text-blue-800 ring-1 ring-blue-600/20'
                  when 'paid'
                    'bg-green-100 text-green-800 ring-1 ring-green-600/20'
                  when 'completed'
                    'bg-emerald-100 text-emerald-800 ring-1 ring-emerald-600/20'
                  when 'cancelled'
                    'bg-red-100 text-red-800 ring-1 ring-red-600/20'
                  else
                    'bg-gray-100 text-gray-800 ring-1 ring-gray-600/20'
                  end

    content_tag(:span, status.to_s.titleize,
                class: "inline-flex items-center rounded-md px-2 py-1 text-xs font-medium #{color_class}")
  end

  def payment_status_indicator(booking)
    if booking.fully_paid?
      content_tag(:span, '✓ Fully Paid',
                  class: 'inline-flex items-center px-2 py-1 text-xs font-medium bg-green-100 text-green-800 rounded-full')
    elsif booking.total_paid > 0
      content_tag(:span, "#{number_to_currency(booking.total_paid)} paid",
                  class: 'inline-flex items-center px-2 py-1 text-xs font-medium bg-yellow-100 text-yellow-800 rounded-full')
    else
      content_tag(:span, 'No payments',
                  class: 'inline-flex items-center px-2 py-1 text-xs font-medium bg-gray-100 text-gray-800 rounded-full')
    end
  end
end
