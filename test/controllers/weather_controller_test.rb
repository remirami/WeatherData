require "test_helper"

class WeatherControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get weather_url
    assert_response :success
  end

  test "should get results" do
    get weather_results_url, params: { city: "London", temperature: 20, day_range: 3 }
    assert_response :success
  end
end
