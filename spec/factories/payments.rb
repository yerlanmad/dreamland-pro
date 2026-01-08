FactoryBot.define do
  factory :payment do
    association :booking
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    currency { %w[USD KZT EUR RUB].sample }
    payment_date { Date.today }
    payment_method { %w[card bank_transfer cash].sample }
    status { 'completed' }

    trait :pending do
      status { 'pending' }
    end

    trait :failed do
      status { 'failed' }
    end

    trait :refunded do
      status { 'refunded' }
    end
  end
end
