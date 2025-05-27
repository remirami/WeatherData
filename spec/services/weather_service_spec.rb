require 'rails_helper'

RSpec.describe WeatherService do
  describe "#fetch_forecast" do
    let(:city) { "Oulu" }
    subject(:service) { described_class.new(city) }

    before do
      allow(Rails.cache).to receive(:fetch).and_call_original
    end

    context "when the API call is successful" do
      before do
        mock_response = double("HTTP Response",
          success?: true,
          code: 200,
          parsed_response: {
            "list" => [
              {
                "dt" => Time.now.to_i,
                "main" => { "temp" => 15, "temp_min" => 10, "temp_max" => 20, "humidity" => 60, "pressure" => 1012 },
                "weather" => [{ "description" => "clear sky", "icon" => "01d", "id" => 800 }],
                "clouds" => { "all" => 0 },
                "wind" => { "speed" => 5, "deg" => 180 },
                "rain" => {},
                "snow" => {}
              },
              {
                "dt" => (Time.now + 1.day).to_i,
                "main" => { "temp" => 18, "temp_min" => 12, "temp_max" => 22, "humidity" => 55, "pressure" => 1010 },
                "weather" => [{ "description" => "few clouds", "icon" => "02d", "id" => 801 }],
                "clouds" => { "all" => 20 },
                "wind" => { "speed" => 6, "deg" => 200 },
                "rain" => {},
                "snow" => {}
              }
            ]
          }
        )
        allow(HTTParty).to receive(:get).with("/forecast", any_args).and_return(mock_response)
        allow(Rails.cache).to receive(:fetch).with("weather_#{city}", expires_in: 10.minutes).and_yield
      end

      it "returns forecast data as an Array" do
        forecast = service.fetch_forecast
        expect(forecast).to be_an(Array)
        expect(forecast.size).to eq(2)  # Two days of forecast data
        expect(forecast.first).to include("date", "temperature")
        expect(forecast.first["temperature"]).to eq(18)  # Max temp from the second entry
      end
    end

    context "when the API call fails" do
      before do
        mock_error_response = double("HTTP Response",
          success?: false,
          code: 401,
          body: "{\"cod\":401, \"message\": \"Invalid API key. Please see https://openweathermap.org/faq#error401 for more info.\"}"
        )
        allow(HTTParty).to receive(:get).with("/forecast", any_args).and_return(mock_error_response)
        allow(mock_error_response).to receive(:parsed_response).and_return(JSON.parse(mock_error_response.body))
        allow(Rails.cache).to receive(:fetch).with("weather_#{city}", expires_in: 10.minutes).and_yield
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
        mock_invalid_response = double("HTTP Response",
          success?: true,
          code: 200,
          parsed_response: { "not_list" => [] }
        )
        allow(HTTParty).to receive(:get).with("/forecast", any_args).and_return(mock_invalid_response)
        allow(Rails.cache).to receive(:fetch).with("weather_#{city}", expires_in: 10.minutes).and_yield
      end

      it "returns an error for invalid data" do
        forecast = service.fetch_forecast
        expect(forecast).to be_a(Hash)
        expect(forecast[:error]).to eq("Invalid data format")
      end
    end
  end
end
