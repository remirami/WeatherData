class WeatherRecord < ApplicationRecord
  # Associations
  belongs_to :location

  # Validations
  validates :temperature, presence: true
  validates :humidity, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :wind_speed, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :conditions, presence: true
  validates :recorded_at, presence: true
  validates :pressure, numericality: { greater_than: 0 }, allow_nil: true
  validates :visibility, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :clouds, numericality: { in: 0..100 }, allow_nil: true

  # Scopes
  scope :recent, -> { order(recorded_at: :desc) }
  scope :by_date_range, ->(start_date, end_date) { where(recorded_at: start_date..end_date) }
  scope :by_location, ->(location_id) { where(location_id: location_id) }
  scope :with_rain, -> { where("conditions LIKE ?", "%rain%") }
  scope :with_snow, -> { where("conditions LIKE ?", "%snow%") }
  scope :with_thunderstorm, -> { where("conditions LIKE ?", "%thunderstorm%") }

  # Class methods
  def self.from_openweather_data(data, location)
    create!(
      temperature: data["main"]["temp"],
      feels_like: data["main"]["feels_like"],
      humidity: data["main"]["humidity"],
      pressure: data["main"]["pressure"],
      wind_speed: data["wind"]["speed"],
      wind_direction: data["wind"]["deg"],
      conditions: data["weather"].first["description"],
      weather_code: data["weather"].first["id"],
      clouds: data["clouds"]["all"],
      visibility: data["visibility"],
      recorded_at: Time.at(data["dt"]),
      location: location
    )
  end

  # Instance methods
  def temperature_in_celsius
    temperature
  end

  def temperature_in_fahrenheit
    (temperature * 9/5) + 32
  end

  def wind_speed_in_kmh
    wind_speed
  end

  def wind_speed_in_mph
    wind_speed * 0.621371
  end

  def pressure_in_hpa
    pressure
  end

  def pressure_in_inches
    pressure * 0.02953
  end

  def visibility_in_km
    visibility / 1000.0
  end

  def visibility_in_miles
    visibility * 0.000621371
  end

  def weather_icon
    case weather_code
    when 200..232
      "thunderstorm"
    when 300..321
      "drizzle"
    when 500..531
      "rain"
    when 600..622
      "snow"
    when 701..781
      "atmosphere"
    when 800
      "clear"
    when 801..804
      "clouds"
    else
      "unknown"
    end
  end

  def severe_weather?
    conditions.include?("thunderstorm") ||
    conditions.include?("tornado") ||
    conditions.include?("hurricane")
  end

  def precipitation?
    conditions.include?("rain") || conditions.include?("snow")
  end

  def uv_index_category
    return "low" if uv_index.nil?
    case uv_index
    when 0..2
      "low"
    when 3..5
      "moderate"
    when 6..7
      "high"
    when 8..10
      "very high"
    else
      "extreme"
    end
  end
end
