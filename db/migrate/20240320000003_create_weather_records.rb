class CreateWeatherRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :weather_records do |t|
      t.references :location, null: false, foreign_key: true
      t.float :temperature
      t.float :humidity
      t.float :wind_speed
      t.string :conditions
      t.datetime :recorded_at
      t.float :pressure
      t.float :visibility
      t.float :clouds
      t.integer :weather_code
      t.float :uv_index
      t.float :feels_like
      t.float :wind_direction
      t.float :precipitation_chance
      t.integer :sunrise
      t.integer :sunset
      t.timestamps
    end
  end
end 