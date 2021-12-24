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

ActiveRecord::Schema.define(version: 2021_12_24_054111) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "addressible_type"
    t.uuid "addressible_id"
    t.string "street1"
    t.string "street2"
    t.string "city"
    t.string "zipcode"
    t.string "state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["addressible_type", "addressible_id"], name: "index_addresses_on_addressible"
    t.index ["city"], name: "index_addresses_on_city"
    t.index ["state"], name: "index_addresses_on_state"
    t.index ["zipcode"], name: "index_addresses_on_zipcode"
  end

  create_table "properties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.integer "lot_size"
    t.integer "home_size"
    t.integer "garage_size"
    t.integer "home_age"
    t.string "estimated_value"
    t.integer "bedrooms"
    t.integer "bathrooms"
    t.integer "pools"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_properties_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name", null: false, comment: "First Name"
    t.string "last_name", null: false, comment: "Last Name"
    t.string "email", default: "", null: false, comment: "Email Address"
    t.string "phone_number", null: false, comment: "Phone Number (+15555555555)"
    t.string "gender", default: "other", null: false, comment: "Gender"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["gender"], name: "index_users_on_gender"
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
  end

  add_foreign_key "properties", "users"
end
