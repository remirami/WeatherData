class WeatherController < ApplicationController
  def results
    @city = params[:city]
    temperature = params[:temperature].to_f
    day_range = params[:day_range].to_i

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
end
