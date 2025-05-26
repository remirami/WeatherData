require 'rails_helper'

RSpec.describe WeatherRecord, type: :model do
  let(:location) { create(:location) }
  let(:weather_record) { build(:weather_record, location: location) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(weather_record).to be_valid
    end

    it "requires temperature" do
      weather_record.temperature = nil
      expect(weather_record).not_to be_valid
      expect(weather_record.errors[:temperature]).to include("can't be blank")
    end

    it "requires humidity" do
      weather_record.humidity = nil
      expect(weather_record).not_to be_valid
      expect(weather_record.errors[:humidity]).to include("can't be blank")
    end

    it "requires humidity to be between 0 and 100" do
      weather_record.humidity = 150
      expect(weather_record).not_to be_valid
      expect(weather_record.errors[:humidity]).to include("must be less than or equal to 100")
    end

    it "requires wind_speed" do
      weather_record.wind_speed = nil
      expect(weather_record).not_to be_valid
      expect(weather_record.errors[:wind_speed]).to include("can't be blank")
    end

    it "requires wind_speed to be non-negative" do
      weather_record.wind_speed = -5
      expect(weather_record).not_to be_valid
      expect(weather_record.errors[:wind_speed]).to include("must be greater than or equal to 0")
    end

    it "requires conditions" do
      weather_record.conditions = nil
      expect(weather_record).not_to be_valid
      expect(weather_record.errors[:conditions]).to include("can't be blank")
    end

    it "requires recorded_at" do
      weather_record.recorded_at = nil
      expect(weather_record).not_to be_valid
      expect(weather_record.errors[:recorded_at]).to include("can't be blank")
    end
  end

  describe "associations" do
    it "belongs to a location" do
      expect(weather_record.location).to eq(location)
    end
  end

  describe "scopes" do
    let!(:old_record) { create(:weather_record, recorded_at: 2.days.ago, location: location) }
    let!(:recent_record) { create(:weather_record, recorded_at: 1.hour.ago, location: location) }
    let!(:rainy_record) { create(:weather_record, :rainy, recorded_at: 3.hours.ago, location: location) }
    let!(:snowy_record) { create(:weather_record, :snowy, recorded_at: 4.hours.ago, location: location) }
    let!(:thunder_record) { create(:weather_record, :thunderstorm, recorded_at: 30.minutes.ago, location: location) }

    describe ".recent" do
      it "returns records ordered by recorded_at in descending order" do
        expect(described_class.recent.first).to eq(thunder_record)
        expect(described_class.recent.second).to eq(recent_record)
        expect(described_class.recent.last).to eq(old_record)
      end
    end

    describe ".by_date_range" do
      it "returns records within the specified date range" do
        records = described_class.by_date_range(1.day.ago, Time.current)
        expect(records).to include(recent_record)
        expect(records).not_to include(old_record)
      end
    end

    describe ".with_rain" do
      it "returns records with rain conditions" do
        expect(described_class.with_rain).to include(rainy_record)
        expect(described_class.with_rain).not_to include(snowy_record)
      end
    end

    describe ".with_snow" do
      it "returns records with snow conditions" do
        expect(described_class.with_snow).to include(snowy_record)
        expect(described_class.with_snow).not_to include(rainy_record)
      end
    end

    describe ".with_thunderstorm" do
      it "returns records with thunderstorm conditions" do
        expect(described_class.with_thunderstorm).to include(thunder_record)
        expect(described_class.with_thunderstorm).not_to include(rainy_record)
      end
    end
  end

  describe "temperature conversions" do
    describe "#temperature_in_celsius" do
      it "returns the temperature in Celsius" do
        expect(weather_record.temperature_in_celsius).to eq(20.5)
      end
    end

    describe "#temperature_in_fahrenheit" do
      it "converts temperature to Fahrenheit" do
        expect(weather_record.temperature_in_fahrenheit).to eq(68.9)
      end
    end
  end

  describe "wind speed conversions" do
    describe "#wind_speed_in_kmh" do
      it "returns the wind speed in km/h" do
        expect(weather_record.wind_speed_in_kmh).to eq(10.2)
      end
    end

    describe "#wind_speed_in_mph" do
      it "converts wind speed to mph" do
        expect(weather_record.wind_speed_in_mph).to be_within(0.1).of(6.34)
      end
    end
  end

  describe "pressure conversions" do
    describe "#pressure_in_hpa" do
      it "returns the pressure in hPa" do
        expect(weather_record.pressure_in_hpa).to eq(1013)
      end
    end

    describe "#pressure_in_inches" do
      it "converts pressure to inches" do
        expect(weather_record.pressure_in_inches).to be_within(0.1).of(29.92)
      end
    end
  end

  describe "visibility conversions" do
    describe "#visibility_in_km" do
      it "converts visibility to kilometers" do
        expect(weather_record.visibility_in_km).to eq(10.0)
      end
    end

    describe "#visibility_in_miles" do
      it "converts visibility to miles" do
        expect(weather_record.visibility_in_miles).to be_within(0.1).of(6.21)
      end
    end
  end

  describe "#weather_icon" do
    it "returns correct icon for thunderstorm" do
      weather_record = build(:weather_record, :thunderstorm, location: location)
      expect(weather_record.weather_icon).to eq('thunderstorm')
    end

    it "returns correct icon for drizzle" do
      weather_record = build(:weather_record, weather_code: 300, location: location)
      expect(weather_record.weather_icon).to eq('drizzle')
    end

    it "returns correct icon for rain" do
      weather_record = build(:weather_record, :rainy, location: location)
      expect(weather_record.weather_icon).to eq('rain')
    end

    it "returns correct icon for snow" do
      weather_record = build(:weather_record, :snowy, location: location)
      expect(weather_record.weather_icon).to eq('snow')
    end

    it "returns correct icon for clear sky" do
      weather_record = build(:weather_record, location: location)
      expect(weather_record.weather_icon).to eq('clear')
    end

    it "returns correct icon for clouds" do
      weather_record = build(:weather_record, :cloudy, location: location)
      expect(weather_record.weather_icon).to eq('clouds')
    end
  end

  describe "#severe_weather?" do
    it "returns true for thunderstorm conditions" do
      weather_record = build(:weather_record, :thunderstorm, location: location)
      expect(weather_record.severe_weather?).to be true
    end

    it "returns true for tornado conditions" do
      weather_record = build(:weather_record, :with_severe_weather, location: location)
      expect(weather_record.severe_weather?).to be true
    end

    it "returns false for normal conditions" do
      expect(weather_record.severe_weather?).to be false
    end
  end

  describe "#precipitation?" do
    it "returns true for rain conditions" do
      weather_record = build(:weather_record, :rainy, location: location)
      expect(weather_record.precipitation?).to be true
    end

    it "returns true for snow conditions" do
      weather_record = build(:weather_record, :snowy, location: location)
      expect(weather_record.precipitation?).to be true
    end

    it "returns false for clear conditions" do
      expect(weather_record.precipitation?).to be false
    end
  end

  describe "#uv_index_category" do
    it "returns 'low' for UV index 0-2" do
      weather_record = build(:weather_record, :with_low_uv, location: location)
      expect(weather_record.uv_index_category).to eq('low')
    end

    it "returns 'moderate' for UV index 3-5" do
      expect(weather_record.uv_index_category).to eq('moderate')
    end

    it "returns 'high' for UV index 6-7" do
      weather_record = build(:weather_record, uv_index: 6, location: location)
      expect(weather_record.uv_index_category).to eq('high')
    end

    it "returns 'very high' for UV index 8-10" do
      weather_record = build(:weather_record, :with_high_uv, location: location)
      expect(weather_record.uv_index_category).to eq('very high')
    end

    it "returns 'extreme' for UV index above 10" do
      weather_record = build(:weather_record, :with_extreme_uv, location: location)
      expect(weather_record.uv_index_category).to eq('extreme')
    end

    it "returns 'low' when UV index is nil" do
      weather_record = build(:weather_record, uv_index: nil, location: location)
      expect(weather_record.uv_index_category).to eq('low')
    end
  end

  describe "#timezone" do
    it "returns the correct timezone" do
      expect(location.timezone.to_i).to eq(7200)
    end
  end
end
