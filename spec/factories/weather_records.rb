FactoryBot.define do
  factory :weather_record do
    temperature { 20.5 }
    humidity { 65 }
    wind_speed { 10.2 }
    conditions { "clear sky" }
    recorded_at { Time.current }
    pressure { 1013 }
    visibility { 10000 }
    clouds { 20 }
    weather_code { 800 }
    uv_index { 5 }
    feels_like { temperature }
    wind_direction { 180 }
    precipitation_chance { 0 }
    sunrise { Time.current.beginning_of_day + 6.hours }
    sunset { Time.current.beginning_of_day + 18.hours }
    association :location

    trait :rainy do
      conditions { "light rain" }
      weather_code { 500 }
      precipitation_chance { 80 }
    end

    trait :snowy do
      conditions { "heavy snow" }
      weather_code { 600 }
      precipitation_chance { 90 }
    end

    trait :thunderstorm do
      conditions { "thunderstorm" }
      weather_code { 200 }
      precipitation_chance { 100 }
    end

    trait :cloudy do
      conditions { "overcast clouds" }
      weather_code { 804 }
      clouds { 100 }
    end

    trait :foggy do
      conditions { "fog" }
      weather_code { 741 }
      visibility { 1000 }
    end

    trait :with_severe_weather do
      conditions { "tornado" }
      weather_code { 781 }
    end

    trait :with_high_uv do
      uv_index { 8 }
    end

    trait :with_low_uv do
      uv_index { 2 }
    end

    trait :with_extreme_uv do
      uv_index { 11 }
    end
  end
end
