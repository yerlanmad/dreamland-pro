FactoryBot.define do
  factory :tour do
    name { Faker::Lorem.words(number: 3).join(' ').titleize }
    description { Faker::Lorem.paragraph }
    base_price { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    currency { %w[USD KZT EUR RUB].sample }
    duration_days { Faker::Number.between(from: 1, to: 14) }
    capacity { Faker::Number.between(from: 10, to: 50) }
    active { true }

    trait :inactive do
      active { false }
    end
  end
end
