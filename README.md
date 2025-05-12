# WeatherData

WeatherData is a Ruby on Rails application that allows users to search for and view current weather conditions and forecasts for cities around the world. It integrates with the OpenWeather API to provide up-to-date weather information, including temperature, humidity, wind speed, and more. Users can save favorite locations, set weather alerts, and view historical weather data.

## Features
- Search for current weather and multi-day forecasts by city
- View detailed weather information (temperature, humidity, wind, etc.)
- Save favorite locations and set default location
- Set up custom weather alerts
- View weather history for saved locations
- User authentication with Devise

## Getting Started

### Prerequisites
- Ruby (3.2+ recommended)
- Rails (8.0+)
- SQLite (default) or PostgreSQL
- Node.js and Yarn (for asset pipeline)

### Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/WeatherData.git
   cd WeatherData
   ```
2. Install dependencies:
   ```bash
   bundle install
   yarn install
   ```
3. Set up the database:
   ```bash
   bin/rails db:setup
   ```
4. Set your OpenWeather API key in your environment variables:
   ```bash
   export OPENWEATHER_API_KEY=your_api_key_here
   ```
5. Start the server:
   ```bash
   bin/dev
   ```

## Running Tests
To run the test suite:
```bash
bundle exec rspec
```

## License
MIT
