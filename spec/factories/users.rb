FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    first_name { "John" }
    last_name { "Doe" }
    timezone { "UTC" }
    notification_preferences { { email: true, push: true, sms: false } }

    trait :with_locations do
      after(:create) do |user|
        create_list(:user_location, 3, user: user)
      end
    end

    trait :with_weather_alerts do
      after(:create) do |user|
        create_list(:weather_alert, 2, user: user)
      end
    end
  end
end
