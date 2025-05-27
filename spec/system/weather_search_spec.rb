require 'rails_helper'

RSpec.describe "Weather search", type: :system do
  before do
    driven_by :selenium, using: :headless_chrome
  end

  it "displays weather results after form submission", js: true do
    visit root_path

    fill_in "city", with: "Oulu"
    fill_in "temperature", with: "5"
    fill_in "day_range", with: "3"
    click_button "Get Weather"

    expect(page).to have_css("#weather_results")
    expect(page).to have_content("Weather Forecast")
  end
end
