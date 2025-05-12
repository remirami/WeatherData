class AddOpenweatherIdToLocations < ActiveRecord::Migration[8.0]
  def change
    add_index :locations, :openweather_id, unique: true unless index_exists?(:locations, :openweather_id)
  end
end