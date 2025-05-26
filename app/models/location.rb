class Location < ApplicationRecord
  # Associations
  has_many :weather_records, dependent: :destroy
  has_many :user_locations, dependent: :destroy
  has_many :users, through: :user_locations

  # Validations
  validates :name, presence: true
  validates :latitude, presence: true, numericality: {
    greater_than_or_equal_to: -90,
    less_than_or_equal_to: 90
  }
  validates :longitude, presence: true, numericality: {
    greater_than_or_equal_to: -180,
    less_than_or_equal_to: 180
  }
  validates :city, presence: true
  validates :country, presence: true
  validates :openweather_id, uniqueness: true, allow_nil: true

  # Scopes
  scope :by_country, ->(country) { where(country: country) }
  scope :by_city, ->(city) { where(city: city) }
  scope :with_recent_weather, -> { joins(:weather_records).distinct }
  scope :with_severe_weather, -> { joins(:weather_records).where("weather_records.conditions LIKE ?", "%thunderstorm%") }

  # Class methods
  def self.find_or_create_from_openweather(data)
    location = find_or_initialize_by(
      openweather_id: data["id"],
      city: data["name"],
      country: data["sys"]["country"]
    )

    location.update!(
      name: data["name"],
      latitude: data["coord"]["lat"],
      longitude: data["coord"]["lon"],
      timezone: data["timezone"].to_i
    )

    location
  end

  # Instance methods
  def current_weather
    weather_records.recent.first
  end

  def weather_history(days = 7)
    weather_records.by_date_range(
      days.days.ago.beginning_of_day,
      Time.current.end_of_day
    )
  end

  def coordinates
    [ latitude, longitude ]
  end

  def full_name
    "#{city}, #{country}"
  end

  def fetch_current_weather
    return unless openweather_id

    response = OpenWeatherAPI::Client.new.current_weather(
      id: openweather_id,
      units: "metric"
    )

    WeatherRecord.from_openweather_data(response, self)
  end

  def fetch_forecast
    return unless openweather_id

    response = OpenWeatherAPI::Client.new.forecast(
      id: openweather_id,
      units: "metric"
    )

    response["list"].map do |data|
      WeatherRecord.from_openweather_data(data, self)
    end
  end

  def fetch_air_quality
    return unless openweather_id

    response = OpenWeatherAPI::Client.new.air_quality(
      lat: latitude,
      lon: longitude
    )

    response["list"].first["main"]["aqi"]
  end

  def timezone
    super.to_i
  end

  def local_time
    Time.current + timezone.seconds
  end

  def sunrise
    return unless current_weather&.sunrise
    Time.at(current_weather.sunrise) + timezone.seconds
  end

  def sunset
    return unless current_weather&.sunset
    Time.at(current_weather.sunset) + timezone.seconds
  end

  def day_length
    return 0 unless sunrise && sunset
    sunset - sunrise
  end

  def is_daytime?
    return false unless sunrise && sunset
    current_time = local_time
    current_time >= sunrise && current_time <= sunset
  end

  def timezone_offset
    timezone || 0
  end
end
