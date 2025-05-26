class WeatherAlert < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :location

  # Validations
  validates :user, presence: true
  validates :location, presence: true
  validates :condition_type, presence: true
  validates :threshold_value, presence: true
  validates :notification_method, presence: true
  validates :active, inclusion: { in: [ true, false ] }

  # Enums
  enum condition_type: {
    temperature_above: 0,
    temperature_below: 1,
    humidity_above: 2,
    humidity_below: 3,
    wind_speed_above: 4,
    precipitation_chance: 5
  }

  enum notification_method: {
    email: 0,
    push_notification: 1,
    sms: 2
  }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_condition, ->(condition_type) { where(condition_type: condition_type) }
  scope :by_location, ->(location_id) { where(location_id: location_id) }

  # Methods
  def should_trigger?(weather_record)
    case condition_type
    when "temperature_above"
      weather_record.temperature > threshold_value
    when "temperature_below"
      weather_record.temperature < threshold_value
    when "humidity_above"
      weather_record.humidity > threshold_value
    when "humidity_below"
      weather_record.humidity < threshold_value
    when "wind_speed_above"
      weather_record.wind_speed > threshold_value
    when "precipitation_chance"
      weather_record.precipitation_chance > threshold_value
    end
  end

  def description
    case condition_type
    when "temperature_above"
      "Temperature above #{threshold_value}°C"
    when "temperature_below"
      "Temperature below #{threshold_value}°C"
    when "humidity_above"
      "Humidity above #{threshold_value}%"
    when "humidity_below"
      "Humidity below #{threshold_value}%"
    when "wind_speed_above"
      "Wind speed above #{threshold_value} km/h"
    when "precipitation_chance"
      "Precipitation chance above #{threshold_value}%"
    end
  end
end
