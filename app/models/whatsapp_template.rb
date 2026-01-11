class WhatsappTemplate < ApplicationRecord
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :content, presence: true
  validates :category, presence: true

  # Enums
  enum :category, {
    greeting: 'greeting',
    pricing: 'pricing',
    availability: 'availability',
    confirmation: 'confirmation',
    follow_up: 'follow_up',
    general: 'general'
  }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_category, ->(category) { where(category: category) }

  # Instance methods
  def render_for(client:, lead: nil, tour: nil, booking: nil)
    result = content.dup

    # Replace client variables
    result.gsub!('{{name}}', client.name) if client
    result.gsub!('{{client_name}}', client.name) if client

    # Replace lead variables
    result.gsub!('{{lead_id}}', lead.id.to_s) if lead

    # Replace tour variables
    if tour
      result.gsub!('{{tour_name}}', tour.name)
      result.gsub!('{{tour_price}}', tour.base_price.to_s)
      result.gsub!('{{tour_duration}}', "#{tour.duration_days} days")
    end

    # Replace booking variables
    if booking
      result.gsub!('{{booking_reference}}', booking.reference_number)
      result.gsub!('{{booking_total}}', booking.total_amount.to_s)
      result.gsub!('{{departure_date}}', booking.tour_departure.departure_date.strftime('%d.%m.%Y'))
    end

    result
  end

  def activate!
    update(active: true)
  end

  def deactivate!
    update(active: false)
  end

  def variable_list
    return [] if variables.blank?

    if variables.is_a?(Array)
      variables
    elsif variables.is_a?(String)
      JSON.parse(variables)
    else
      []
    end
  rescue JSON::ParserError
    []
  end
end
