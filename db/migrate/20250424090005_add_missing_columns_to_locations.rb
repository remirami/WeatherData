class AddMissingColumnsToLocations < ActiveRecord::Migration[8.0]
  def change
    add_column :locations, :city,           :string  unless column_exists?(:locations, :city)
    add_column :locations, :country,        :string  unless column_exists?(:locations, :country)
    add_column :locations, :openweather_id, :integer unless column_exists?(:locations, :openweather_id)
    add_column :locations, :timezone,       :string  unless column_exists?(:locations, :timezone)
  end
end
