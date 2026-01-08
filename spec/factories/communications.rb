FactoryBot.define do
  factory :communication do
    association :communicable, factory: :lead
    communication_type { :whatsapp }
    direction { :inbound }
    body { Faker::Lorem.paragraph }
    whatsapp_message_id { "msg_#{Faker::Alphanumeric.alphanumeric(number: 10)}" }

    trait :outbound do
      direction { :outbound }
    end

    trait :email do
      communication_type { :email }
      subject { Faker::Lorem.sentence }
    end

    trait :phone do
      communication_type { :phone }
    end

    trait :with_media do
      media_url { Faker::Internet.url }
      media_type { 'image/jpeg' }
    end
  end
end
