class OpenWeatherService
  def initialize(city)
    @weather_service = WeatherService.new(city)
  end

  def current_weather
    @weather_service.get_weather
  end

  def forecast
    @weather_service.fetch_forecast
  end

  def fetch_weather
    current_weather
  end

  class << self
    def fetch_weather(*args)
      new(*args).fetch_weather
    end
  end
end 