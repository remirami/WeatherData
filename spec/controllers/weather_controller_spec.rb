require 'rails_helper'

RSpec.describe WeatherController, type: :controller do
  describe "POST #results" do
    
    before do
      
      weather_service_mock = instance_double(WeatherService)

      allow(WeatherService).to receive(:new).and_return(weather_service_mock)

      allow(weather_service_mock).to receive(:fetch_forecast).and_return([
        # Example forecast data
        { "date" => "2025-05-28", "temperature" => 6.0, "rain" => 0.1, "temp_min" => 3.0, "temp_max" => 8.0, "humidity" => 70, "wind_speed" => 5, "description" => "Light rain", "icon" => "10d" },
        { "date" => "2025-05-29", "temperature" => 4.5, "rain" => 0.0, "temp_min" => 2.0, "temp_max" => 7.0, "humidity" => 65, "wind_speed" => 6, "description" => "Cloudy", "icon" => "03d" },
        { "date" => "2025-05-30", "temperature" => 7.0, "rain" => 0.5, "temp_min" => 4.0, "temp_max" => 10.0, "humidity" => 75, "wind_speed" => 7, "description" => "Rain", "icon" => "10d" },
        { "date" => "2025-05-31", "temperature" => 10.0, "rain" => 0.0, "temp_min" => 6.0, "temp_max" => 12.0, "humidity" => 60, "wind_speed" => 8, "description" => "Sunny", "icon" => "01d" },
      ])


      allow(weather_service_mock).to receive(:get_weather).and_return({
        temperature: 5.0, feels_like: 3.0, temp_min: 2.0, temp_max: 8.0, description: "Cloudy",
        humidity: 65, pressure: 1010, wind_speed: 5, wind_direction: "N", city: "Oulu",
        country: "FI", sunrise: 1678862400, sunset: 1678896000, icon: "03d", visibility: 10000,
        clouds: 75, rain: 0, snow: 0
      })
    end

    it "returns Turbo Stream format" do

      post :results, params: { city: "Oulu", temperature: 5, day_range: 3 }, format: :turbo_stream
      expect(response.media_type).to eq "text/vnd.turbo-stream.html"

    end

    it "redirects with an alert if city is blank" do
      post :results, params: { city: "", day_range: "3", temperature: "5" }, as: :html

      puts "Response body: #{response.body}"
      puts "Response status: #{response.status}"

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to match(/Please enter a valid city/)
    end
    it "redirects with an alert if the API request fails" do
      allow(OpenWeatherService).to receive(:fetch_weather).and_return({ error: "API Error" })

      post :results, params: { city: "InvalidCity", temperature: 20, day_range: 3 }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Weather data could not be retrieved. Please try again later.")
    end
  end
end
