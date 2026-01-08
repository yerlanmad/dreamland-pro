FactoryBot.define do
  factory :lead do
    name { Faker::Name.name }
    phone { "+#{Faker::Number.unique.number(digits: 12)}" }
    email { Faker::Internet.email }
    source { :whatsapp }
    status { :new }
    unread_messages_count { 0 }

    trait :with_agent do
      association :assigned_agent, factory: :user
    end

    trait :contacted do
      status { :contacted }
    end

    trait :won do
      status { :won }
    end
  end
end
