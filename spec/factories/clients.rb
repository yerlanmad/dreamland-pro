FactoryBot.define do
  factory :client do
    name { Faker::Name.name }
    phone { "+#{Faker::Number.unique.number(digits: 11)}" }
    email { Faker::Internet.email }
    preferred_language { :ru }
    notes { nil }
  end
end
