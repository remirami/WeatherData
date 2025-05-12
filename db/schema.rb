# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_04_29_081358) do
  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.string "city"
    t.string "country"
    t.float "latitude"
    t.float "longitude"
    t.integer "openweather_id"
    t.string "timezone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["openweather_id"], name: "index_locations_on_openweather_id", unique: true
  end

  create_table "user_locations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "location_id", null: false
    t.boolean "is_default", default: false
    t.string "display_name"
    t.boolean "notification_enabled", default: true
    t.datetime "last_checked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_user_locations_on_location_id"
    t.index ["user_id", "location_id"], name: "index_user_locations_on_user_id_and_location_id", unique: true
    t.index ["user_id"], name: "index_user_locations_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name"
    t.string "last_name"
    t.string "timezone"
    t.json "notification_preferences", default: {"email" => true, "push" => true, "sms" => false}
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "weather_records", force: :cascade do |t|
    t.integer "location_id", null: false
    t.float "temperature"
    t.float "humidity"
    t.float "wind_speed"
    t.string "conditions"
    t.datetime "recorded_at"
    t.float "pressure"
    t.float "visibility"
    t.float "clouds"
    t.integer "weather_code"
    t.float "uv_index"
    t.float "feels_like"
    t.float "wind_direction"
    t.float "precipitation_chance"
    t.integer "sunrise"
    t.integer "sunset"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_weather_records_on_location_id"
  end

  add_foreign_key "user_locations", "locations"
  add_foreign_key "user_locations", "users"
  add_foreign_key "weather_records", "locations"
end
