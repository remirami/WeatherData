class WeatherController < ApplicationController
  def index
    # This action is for rendering the initial form
  end

  def results
    @city = params[:city]
    temperature = params[:temperature].to_f
    day_range = params[:day_range].to_i
    rain_expected = params[:rain_expected] == "1"

    Rails.logger.debug "City param received: '#{@city}'"

    if @city.blank? || day_range <= 0 || day_range > 5
      Rails.logger.debug "Redirecting due to invalid input: City: '#{@city}', Day range: #{day_range}"

      flash[:alert] = "Please enter a valid city and day range (1-5)."
      redirect_to root_path and return
    end

    service = WeatherService.new(@city)
    forecast = service.fetch_forecast

    if forecast.is_a?(Hash) && forecast[:error]
      Rails.logger.error "Weather API Error: #{forecast[:error]}"
      flash[:alert] = "Weather data could not be retrieved. Please try again later."
      redirect_to root_path and return
    end

    # Group forecasts by date and select one per day
    daily_forecast = forecast.group_by { |day| day["date"] }.map do |date, entries|
      entries.reject { |entry| entry["temperature"].nil? } # Remove incomplete data
             .min_by { |entry| (entry["temperature"].to_f - temperature).abs }
    end.compact # Remove nil values

    # Filter for rainy days if requested
    if rain_expected
      daily_forecast = daily_forecast.select { |day| day["rain"]&.> 0 }
      if daily_forecast.empty?
        flash[:alert] = "No rainy days found in the forecast."
        redirect_to root_path and return
      end
    end

    @forecast = daily_forecast.sort_by { |day| (day["temperature"].to_f - temperature).abs }
                              .first(day_range)

    if @forecast.empty?
      flash[:alert] = "No days found matching your temperature criteria."
      redirect_to root_path and return
    end

    # Get current weather for additional details
    @current_weather = service.get_weather

    respond_to do |format|
      format.turbo_stream
      format.html { render :results }
    end
  end

  def day_details
    @city = params[:city]
    @date = params[:date]
    
    service = WeatherService.new(@city)
    @hourly_data = service.fetch_hourly_forecast(@date)
    
    if @hourly_data.is_a?(Hash) && @hourly_data[:error]
      flash[:alert] = "Weather data could not be retrieved. Please try again later."
      redirect_to root_path and return
    end
  end
end
