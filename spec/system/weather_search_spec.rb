require 'rails_helper'

RSpec.describe "Weather search", type: :system do
  before do
    driven_by :selenium, using: :headless_chrome
  end

  it "displays weather results after form submission", js: true do
    visit root_path

    fill_in "City", with: "Oulu"
    fill_in "Temperature (°C)", with: "5"
    fill_in "Day Range (1-5)", with: "3"
    click_button "Get Weather"

    expect(page).to have_css("#weather_results")
    expect(page).to have_content("Weather Forecast")
  end
end
