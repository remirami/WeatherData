require "httparty"

class WeatherService
  include HTTParty
  base_uri "https://api.openweathermap.org/data/2.5"

  def initialize(city)
    @api_key = ENV["OPENWEATHER_API_KEY"]
    @city = city
  end

  def get_weather
    response = self.class.get("/weather", query: {
      q: @city,
      appid: @api_key,
      units: "metric"
    })

    if response.success?
      {
        temperature: response["main"]["temp"],
        feels_like: response["main"]["feels_like"],
        temp_min: response["main"]["temp_min"],
        temp_max: response["main"]["temp_max"],
        description: response["weather"][0]["description"],
        humidity: response["main"]["humidity"],
        pressure: response["main"]["pressure"],
        wind_speed: response["wind"]["speed"],
        wind_direction: response["wind"]["deg"],
        city: response["name"],
        country: response["sys"]["country"],
        sunrise: response["sys"]["sunrise"],
        sunset: response["sys"]["sunset"],
        icon: response["weather"][0]["icon"],
        visibility: response["visibility"],
        clouds: response["clouds"]["all"],
        rain: response["rain"]&.fetch("1h", 0),
        snow: response["snow"]&.fetch("1h", 0)
      }
    else
      nil
    end
  end

  def fetch_forecast
    Rails.cache.fetch("weather_#{@city}", expires_in: 10.minutes) do
      response = self.class.get("/forecast", query: {
        q: @city,
        units: "metric",
        appid: @api_key
      })

      Rails.logger.debug "API Full Response: #{response.body}"

      return { error: "Failed to fetch weather data: #{response.code} - #{response.body}" } unless response.success?

      parsed_data = parse_weather_data(response.parsed_response)
      Rails.logger.debug "Parsed Forecast Data: #{parsed_data.inspect}"
      parsed_data
    end
  end

  private

  def parse_weather_data(data)
    return { error: "Invalid data format" } unless data["list"]

    data["list"].group_by { |entry| Time.at(entry["dt"]).strftime("%Y-%m-%d") }
                .map do |date, entries|
      {
        "date" => date,
        "temperature" => safe_max(entries, "main", "temp"),
        "temp_min" => safe_min(entries, "main", "temp_min"),
        "temp_max" => safe_max(entries, "main", "temp_max"),
        "humidity" => safe_max(entries, "main", "humidity"),
        "wind_speed" => safe_max(entries, "wind", "speed"),
        "description" => entries.first.dig("weather", 0, "description") || "Unknown",
        "icon" => entries.first.dig("weather", 0, "icon") || "01d",
        "pressure" => safe_max(entries, "main", "pressure"),
        "clouds" => safe_max(entries, "clouds", "all"),
        "rain" => safe_sum(entries, "rain", "3h"),
        "snow" => safe_sum(entries, "snow", "3h")
      }
    end
  end

  def safe_max(entries, *keys)
    entries.map { |e| e.dig(*keys) }.compact.max || 0
  end

  def safe_min(entries, *keys)
    entries.map { |e| e.dig(*keys) }.compact.min || 0
  end

  def safe_sum(entries, *keys)
    entries.map { |e| e.dig(*keys) || 0 }.sum
  end

  def wind_direction_to_text(degrees)
    directions = {
      0..22.5 => "N",
      22.5..45 => "NNE",
      45..67.5 => "NE",
      67.5..90 => "ENE",
      90..112.5 => "E",
      112.5..135 => "ESE",
      135..157.5 => "SE",
      157.5..180 => "SSE",
      180..202.5 => "S",
      202.5..225 => "SSW",
      225..247.5 => "SW",
      247.5..270 => "WSW",
      270..292.5 => "W",
      292.5..315 => "WNW",
      315..337.5 => "NW",
      337.5..360 => "NNW"
    }

    directions.find { |range, _| range.include?(degrees) }&.last || "N"
  end
end
