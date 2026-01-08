FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    role { :agent }
    preferred_language { :ru }
    preferred_currency { :KZT }

    trait :manager do
      role { :manager }
    end

    trait :admin do
      role { :admin }
    end
  end
end
