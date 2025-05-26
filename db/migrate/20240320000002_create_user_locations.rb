class CreateUserLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :user_locations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.boolean :is_default, default: false
      t.string :display_name
      t.boolean :notification_enabled, default: true
      t.datetime :last_checked_at
      t.timestamps
    end

    add_index :user_locations, [ :user_id, :location_id ], unique: true
  end
end
