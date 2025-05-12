class AddOpenweatherIdIndexToLocations < ActiveRecord::Migration[7.1]
  def change
    add_index :locations, :openweather_id, unique: true
  end
end 