FactoryBot.define do
  factory :whatsapp_template do
    name { Faker::Lorem.words(number: 3).join('_') }
    content { "Hello {{customer_name}}, welcome to Dreamland! {{message}}" }
    variables { ['customer_name', 'message'].to_json }
    category { 'greeting' }
    active { true }

    trait :inactive do
      active { false }
    end

    trait :booking_confirmation do
      category { 'booking_confirmation' }
      content { "Your booking {{reference_number}} for {{tour_name}} on {{departure_date}} is confirmed!" }
      variables { ['reference_number', 'tour_name', 'departure_date'].to_json }
    end

    trait :payment_reminder do
      category { 'payment_reminder' }
      content { "Reminder: Payment of {{amount}} {{currency}} is due for your booking {{reference_number}}." }
      variables { ['amount', 'currency', 'reference_number'].to_json }
    end
  end
end
