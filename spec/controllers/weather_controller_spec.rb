require 'rails_helper'

RSpec.describe WeatherController, type: :controller do
  describe "POST #results" do
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
      allow(OpenWeatherService).to receive(:fetch_weather).and_return(nil)

      post :results, params: { city: "InvalidCity", temperature: 20, day_range: 3 }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Weather data could not be retrieved. Please try again later.")
    end
  end
end
