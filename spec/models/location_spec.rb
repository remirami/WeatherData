require 'rails_helper'

RSpec.describe Location, type: :model do
  let(:location) { build(:location) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(location).to be_valid
    end

    it "requires name" do
      location.name = nil
      expect(location).not_to be_valid
      expect(location.errors[:name]).to include("can't be blank")
    end

    it "requires city" do
      location.city = nil
      expect(location).not_to be_valid
      expect(location.errors[:city]).to include("can't be blank")
    end

    it "requires country" do
      location.country = nil
      expect(location).not_to be_valid
      expect(location.errors[:country]).to include("can't be blank")
    end

    it "requires latitude" do
      location.latitude = nil
      expect(location).not_to be_valid
      expect(location.errors[:latitude]).to include("can't be blank")
    end

    it "requires latitude to be between -90 and 90" do
      location.latitude = 91
      expect(location).not_to be_valid
      expect(location.errors[:latitude]).to include("must be less than or equal to 90")
    end

    it "requires longitude" do
      location.longitude = nil
      expect(location).not_to be_valid
      expect(location.errors[:longitude]).to include("can't be blank")
    end

    it "requires longitude to be between -180 and 180" do
      location.longitude = 181
      expect(location).not_to be_valid
      expect(location.errors[:longitude]).to include("must be less than or equal to 180")
    end

    it "requires openweather_id to be unique when present" do
      existing_location = create(:location)
      location.openweather_id = existing_location.openweather_id
      expect(location).not_to be_valid
      expect(location.errors[:openweather_id]).to include("has already been taken")
    end
  end

  describe "associations" do
    it "has many weather_records" do
      location = create(:location, :with_recent_weather)
      expect(location.weather_records.count).to eq(5) # 3 rainy + 2 cloudy
    end

    it "has many user_locations" do
      location = create(:location)
      create_list(:user_location, 3, location: location)
      expect(location.user_locations.count).to eq(3)
    end

    it "has many users through user_locations" do
      location = create(:location)
      users = create_list(:user, 2)
      users.each { |user| create(:user_location, user: user, location: location) }
      expect(location.users).to match_array(users)
    end

    it "destroys dependent weather_records" do
      location = create(:location, :with_recent_weather)
      expect { location.destroy }.to change(WeatherRecord, :count).by(-5)
    end

    it "destroys dependent user_locations" do
      location = create(:location)
      create_list(:user_location, 3, location: location)
      expect { location.destroy }.to change(UserLocation, :count).by(-3)
    end
  end

  describe "scopes" do
    let!(:helsinki) { create(:location, :helsinki) }
    let!(:tokyo) { create(:location, :tokyo) }
    let!(:new_york) { create(:location, :new_york) }
    let!(:sydney) { create(:location, :sydney) }

    describe ".by_country" do
      it "returns locations in the specified country" do
        expect(described_class.by_country("FI")).to include(helsinki)
        expect(described_class.by_country("FI")).not_to include(tokyo)
      end
    end

    describe ".by_city" do
      it "returns locations in the specified city" do
        expect(described_class.by_city("Tokyo")).to include(tokyo)
        expect(described_class.by_city("Tokyo")).not_to include(helsinki)
      end
    end

    describe ".with_recent_weather" do
      it "returns locations with weather records" do
        location_with_weather = create(:location, :with_recent_weather)
        expect(described_class.with_recent_weather).to include(location_with_weather)
        expect(described_class.with_recent_weather).not_to include(helsinki)
      end
    end

    describe ".with_severe_weather" do
      it "returns locations with severe weather" do
        location_with_severe_weather = create(:location, :with_severe_weather)
        expect(described_class.with_severe_weather).to include(location_with_severe_weather)
        expect(described_class.with_severe_weather).not_to include(helsinki)
      end
    end
  end

  describe "instance methods" do
    describe "#current_weather" do
      it "returns the most recent weather record" do
        location = create(:location, :with_recent_weather)
        expect(location.current_weather).to eq(location.weather_records.recent.first)
      end

      it "returns nil when no weather records exist" do
        expect(location.current_weather).to be_nil
      end
    end

    describe "#weather_history" do
      it "returns weather records within the specified date range" do
        location = create(:location, :with_historical_weather)
        history = location.weather_history(7)
        expect(history.count).to eq(5) # Only records from 1 week ago
      end

      it "returns empty array when no weather records exist" do
        expect(location.weather_history).to be_empty
      end
    end

    describe "#coordinates" do
      it "returns latitude and longitude as an array" do
        expect(location.coordinates).to eq([ location.latitude, location.longitude ])
      end
    end

    describe "#full_name" do
      it "returns city and country in a formatted string" do
        expect(location.full_name).to eq("Oulu, FI")
      end
    end

    describe "#timezone_offset" do
      it "returns the timezone offset" do
        expect(location.timezone_offset).to eq(7200)
      end

      it "returns 0 when timezone is nil" do
        location.timezone = nil
        expect(location.timezone_offset).to eq(0)
      end
    end

    describe "#local_time" do
      it "returns the current time adjusted for timezone" do
        expected_time = Time.current + location.timezone_offset.seconds
        expect(location.local_time).to be_within(1.second).of(expected_time)
      end
    end

    describe "#sunrise" do
      it "returns the sunrise time adjusted for timezone" do
        location = create(:location, :with_recent_weather)
        expected_time = Time.at(location.current_weather.sunrise) + location.timezone_offset.seconds
        expect(location.sunrise).to be_within(1.second).of(expected_time)
      end

      it "returns nil when no current weather exists" do
        expect(location.sunrise).to be_nil
      end
    end

    describe "#sunset" do
      it "returns the sunset time adjusted for timezone" do
        location = create(:location, :with_recent_weather)
        expected_time = Time.at(location.current_weather.sunset) + location.timezone_offset.seconds
        expect(location.sunset).to be_within(1.second).of(expected_time)
      end

      it "returns nil when no current weather exists" do
        expect(location.sunset).to be_nil
      end
    end

    describe "#day_length" do
      it "returns the length of the day in seconds" do
        location = create(:location, :with_recent_weather)
        expected_length = location.sunset - location.sunrise
        expect(location.day_length).to be_within(1.second).of(expected_length)
      end

      it "returns 0 when sunrise or sunset is nil" do
        expect(location.day_length).to eq(0)
      end
    end

    describe "#is_daytime?" do
      it "returns true during daylight hours" do
        location = create(:location, :with_recent_weather)
        allow(location).to receive(:local_time).and_return(location.sunrise + 1.hour)
        expect(location.is_daytime?).to be true
      end

      it "returns false during nighttime" do
        location = create(:location, :with_recent_weather)
        allow(location).to receive(:local_time).and_return(location.sunset + 1.hour)
        expect(location.is_daytime?).to be false
      end

      it "returns false when sunrise or sunset is nil" do
        expect(location.is_daytime?).to be false
      end
    end
  end

  describe "class methods" do
    describe ".find_or_create_from_openweather" do
      let(:openweather_data) do
        {
          'id' => 643492,
          'name' => 'Oulu',
          'sys' => { 'country' => 'FI' },
          'coord' => { 'lat' => 65.0121, 'lon' => 25.4651 },
          'timezone' => 7200
        }
      end

      context "when location doesn't exist" do
        it "creates a new location" do
          expect {
            described_class.find_or_create_from_openweather(openweather_data)
          }.to change(described_class, :count).by(1)
        end

        it "sets the correct attributes" do
          location = described_class.find_or_create_from_openweather(openweather_data)
          expect(location.name).to eq('Oulu')
          expect(location.city).to eq('Oulu')
          expect(location.country).to eq('FI')
          expect(location.latitude).to eq(65.0121)
          expect(location.longitude).to eq(25.4651)
          expect(location.timezone).to eq(7200)
        end
      end

      context "when location exists" do
        before do
          create(:location, openweather_id: 643492)
        end

        it "does not create a new location" do
          expect {
            described_class.find_or_create_from_openweather(openweather_data)
          }.not_to change(described_class, :count)
        end

        it "updates the existing location" do
          location = described_class.find_or_create_from_openweather(openweather_data)
          expect(location.name).to eq('Oulu')
          expect(location.city).to eq('Oulu')
          expect(location.country).to eq('FI')
        end
      end
    end
  end
end
