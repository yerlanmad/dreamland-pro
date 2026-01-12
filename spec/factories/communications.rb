FactoryBot.define do
  factory :communication do
    association :client
    association :lead
    communication_type { :whatsapp }
    direction { :inbound }
    body { Faker::Lorem.paragraph }
    whatsapp_message_id { "msg_#{Faker::Alphanumeric.alphanumeric(number: 10)}" }
    whatsapp_status { :inbound }

    trait :outbound do
      direction { :outbound }
      whatsapp_status { :sent }
    end

    trait :email do
      communication_type { :email }
      subject { Faker::Lorem.sentence }
      whatsapp_status { nil }
    end

    trait :phone do
      communication_type { :phone }
      whatsapp_status { nil }
    end

    trait :with_media do
      media_url { Faker::Internet.url }
      media_type { 'image' }
    end

    trait :delivered do
      whatsapp_status { :delivered }
      sent_at { 5.minutes.ago }
    end

    trait :read do
      whatsapp_status { :read }
      sent_at { 10.minutes.ago }
    end

    trait :error do
      whatsapp_status { :error }
      error_message { 'BAD_CONTACT: Contact does not exist' }
    end
  end
end
