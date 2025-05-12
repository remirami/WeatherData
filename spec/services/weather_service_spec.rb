require 'rails_helper'

RSpec.describe WeatherService do
  describe "#fetch_forecast" do
    it "returns forecast data for a valid city" do
      service = WeatherService.new("Oulu")
      forecast = service.fetch_forecast

      expect(forecast).to be_an(Array)
      expect(forecast.first).to have_key("date")
      expect(forecast.first).to have_key("temperature")
    end

    it "handles API errors gracefully" do
      service = WeatherService.new("InvalidCity123")
      forecast = service.fetch_forecast

      expect(forecast).to be_a(Hash)
      expect(forecast[:error]).to be_present
    end
  end
end
