require 'rails_helper'

RSpec.describe "Weather search", type: :system do
  before do
    driven_by :selenium, using: :headless_chrome
  end

  it "loads the root path successfully" do
    visit root_path
    expect(page).to have_content("Weather Forecast")
    expect(page).to have_field("city")
    expect(page).to have_field("temperature")
    expect(page).to have_field("day_range")
  end

  it "displays weather results after form submission", js: true do
    visit root_path

    # Add a small delay to ensure page is ready
    sleep 1

    # Debug: Print the page content
    puts "Page content:"
    puts page.html

    # Debug: List all form fields
    puts "\nForm fields:"
    page.all('input, select, textarea').each do |field|
      puts "Field: #{field[:id] || field[:name]} (Type: #{field[:type] || field.tag_name}) Disabled: #{field.disabled?}"
    end

    fill_in "city", with: "Oulu"
    fill_in "temperature", with: "5"
    fill_in "day_range", with: "3"
    click_button "Get Weather"

    # Wait for the results page to load
    expect(page).to have_content("Current Weather Conditions")
    expect(page).to have_content("Oulu")
    expect(page).to have_content("5-Day Forecast")
  end
end
