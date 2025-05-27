require 'rails_helper'

RSpec.describe WeatherService do
  describe "#fetch_forecast" do
    let(:city) { "Oulu" }
    subject(:service) { described_class.new(city) }

    context "when the API call is successful" do
      before do
        mock_response_data = [
          {
            "date" => Time.at(Time.now.to_i).strftime("%Y-%m-%d"),
            "temperature" => 20,
            "temp_min" => 10,
            "temp_max" => 20,
            "humidity" => 60,
            "wind_speed" => 5,
            "description" => "clear sky",
            "icon" => "01d",
            "pressure" => 1012,
            "clouds" => 0,
            "rain" => 0,
            "snow" => 0
          },
          {
            "date" => Time.at((Time.now + 1.day).to_i).strftime("%Y-%m-%d"),
            "temperature" => 22,
            "temp_min" => 12,
            "temp_max" => 22,
            "humidity" => 55,
            "wind_speed" => 6,
            "description" => "few clouds",
            "icon" => "02d",
            "pressure" => 1010,
            "clouds" => 20,
            "rain" => 0,
            "snow" => 0
          }
        ]
        allow(Rails.cache).to receive(:fetch).with("weather_#{city}", expires_in: 10.minutes).and_return(mock_response_data)
      end

      it "returns forecast data as an Array" do
        forecast = service.fetch_forecast
        expect(forecast).to be_an(Array)
        expect(forecast.size).to eq(2)  # Two days of forecast data
        expect(forecast.first).to include("date", "temperature")
        expect(forecast.first["temperature"]).to eq(20)
      end
    end

    context "when the API call fails" do
      before do
        mock_error_response_data = { error: "Failed to fetch weather data: 401 - {\"cod\":401, \"message\": \"Invalid API key. Please see https://openweathermap.org/faq#error401 for more info.\"}" }
        allow(Rails.cache).to receive(:fetch).with("weather_#{city}", expires_in: 10.minutes).and_return(mock_error_response_data)
      end

      it "handles API errors gracefully" do
        forecast = service.fetch_forecast
        expect(forecast).to be_a(Hash)
        expect(forecast[:error]).to be_present
        expect(forecast[:error]).to include("Failed to fetch weather data: 401")
      end
    end

    context "when the API returns invalid data format" do
      before do
        mock_invalid_response_data = { error: "Invalid data format" }
        allow(Rails.cache).to receive(:fetch).with("weather_#{city}", expires_in: 10.minutes).and_return(mock_invalid_response_data)
      end

      it "returns an error for invalid data" do
        forecast = service.fetch_forecast
        expect(forecast).to be_a(Hash)
        expect(forecast[:error]).to eq("Invalid data format")
      end
    end
  end
end
