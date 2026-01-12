FactoryBot.define do
  factory :lead do
    association :client
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
