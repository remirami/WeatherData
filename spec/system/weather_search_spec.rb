require 'rails_helper'

RSpec.describe "Weather search", type: :system do
  before do
    driven_by :selenium, using: :headless_chrome
  end

  it "displays weather results after form submission", js: true do
    visit root_path

    fill_in "City", with: "Oulu"
    fill_in "Desired Temperature:", with: "5"
    fill_in "Number of Days (1-10):", with: "3"
    click_button "Search"

    expect(page).to have_css("#weather_results")
    expect(page).to have_content("Weather Forecast")
  end
end
