FactoryBot.define do
  factory :tour_departure do
    association :tour
    departure_date { Faker::Date.forward(days: 90) }
    capacity { 20 }
    price { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    currency { tour&.currency || 'USD' }
  end
end
