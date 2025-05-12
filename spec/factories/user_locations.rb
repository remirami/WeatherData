FactoryBot.define do
  factory :user_location do
    association :user
    association :location
    is_default { false }
    display_name { nil }
    notification_enabled { true }
    last_checked_at { Time.current }

    trait :default do
      is_default { true }
    end

    trait :with_display_name do
      display_name { "My Favorite City" }
    end

    trait :notifications_disabled do
      notification_enabled { false }
    end
  end
end 