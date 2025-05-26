FactoryBot.define do
  factory :location do
    name { "Oulu" }
    city { "Oulu" }
    country { "FI" }
    latitude { 65.0121 }
    longitude { 25.4651 }
    timezone { 7200 } # UTC+2
    openweather_id { 643492 }

    trait :helsinki do
      name { "Helsinki" }
      city { "Helsinki" }
      country { "FI" }
      latitude { 60.1699 }
      longitude { 24.9384 }
      timezone { 7200 }
      openweather_id { 658225 }
    end

    trait :tokyo do
      name { "Tokyo" }
      city { "Tokyo" }
      country { "JP" }
      latitude { 35.6762 }
      longitude { 139.6503 }
      timezone { 32400 } # UTC+9
      openweather_id { 1850147 }
    end

    trait :new_york do
      name { "New York" }
      city { "New York" }
      country { "US" }
      latitude { 40.7128 }
      longitude { -74.0060 }
      timezone { -18000 } # UTC-5
      openweather_id { 5128581 }
    end

    trait :sydney do
      name { "Sydney" }
      city { "Sydney" }
      country { "AU" }
      latitude { -33.8688 }
      longitude { 151.2093 }
      timezone { 36000 } # UTC+10
      openweather_id { 2147714 }
    end

    trait :with_recent_weather do
      after(:create) do |location|
        create_list(:weather_record, 3, :rainy, location: location, recorded_at: 1.hour.ago)
        create_list(:weather_record, 2, :cloudy, location: location, recorded_at: 2.hours.ago)
      end
    end

    trait :with_severe_weather do
      after(:create) do |location|
        create(:weather_record, :thunderstorm, location: location, recorded_at: 30.minutes.ago)
      end
    end

    trait :with_historical_weather do
      after(:create) do |location|
        create_list(:weather_record, 5, location: location, recorded_at: 1.week.ago)
        create_list(:weather_record, 5, location: location, recorded_at: 2.weeks.ago)
      end
    end

    trait :without_openweather_id do
      openweather_id { nil }
    end
  end
end
