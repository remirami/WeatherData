class CreateLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :locations do |t|
      t.string :name
      t.string :city
      t.string :country
      t.float :latitude
      t.float :longitude
      t.integer :openweather_id
      t.string :timezone
      t.timestamps
    end
  end
end
