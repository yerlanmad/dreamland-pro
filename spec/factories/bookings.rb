FactoryBot.define do
  factory :booking do
    association :lead
    association :tour_departure
    num_participants { 2 }
    total_amount { tour_departure.price * num_participants }
    currency { tour_departure.currency }
    status { :confirmed }

    trait :paid do
      status { :paid }
    end

    trait :completed do
      status { :completed }
    end
  end
end
