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

ActiveRecord::Schema.define(version: 2022_02_05_094716) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "common_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "caption"
    t.string "img_uri"
    t.string "default_hn_chat_message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "devices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.string "apns_device_token"
    t.string "fcm_token"
    t.string "device_id"
    t.string "name"
    t.string "model"
    t.string "platform"
    t.string "operating_system"
    t.string "os_version"
    t.string "manufacturer"
    t.string "is_virtual"
    t.string "mem_used"
    t.string "disk_free"
    t.string "disk_total"
    t.string "real_disk_free"
    t.string "real_disk_total"
    t.string "web_view_version"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["device_id"], name: "index_devices_on_device_id", unique: true
    t.index ["user_id"], name: "index_devices_on_user_id"
  end

  create_table "home_care_tips", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "label", null: false
    t.string "description"
    t.boolean "show_button", default: true, null: false
    t.string "default_hn_chat_message", default: ""
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["label"], name: "index_home_care_tips_on_label"
  end

  create_table "payment_methods", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.uuid "user_id", null: false
    t.string "stripe_token"
    t.string "brand"
    t.string "country"
    t.string "cvv"
    t.string "exp_month"
    t.string "exp_year"
    t.string "card_number"
    t.string "zipcode"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "last_four"
    t.index ["stripe_token"], name: "index_payment_methods_on_stripe_token", unique: true
    t.index ["user_id"], name: "index_payment_methods_on_user_id"
  end

  create_table "properties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.float "lot_size"
    t.float "home_size"
    t.float "garage_size"
    t.integer "year_built"
    t.string "estimated_value"
    t.float "bedrooms"
    t.float "bathrooms"
    t.float "pools"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "service_area_id"
    t.boolean "default"
    t.boolean "selected"
    t.string "street_address1"
    t.string "street_address2"
    t.string "city"
    t.string "zipcode"
    t.string "state"
    t.index ["city"], name: "index_properties_on_city"
    t.index ["service_area_id"], name: "index_properties_on_service_area_id"
    t.index ["state"], name: "index_properties_on_state"
    t.index ["user_id", "default"], name: "index_properties_on_user_id_and_default", unique: true
    t.index ["user_id", "selected"], name: "index_properties_on_user_id_and_selected"
    t.index ["user_id"], name: "index_properties_on_user_id"
    t.index ["zipcode"], name: "index_properties_on_zipcode"
  end

  create_table "service_areas", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "zipcodes", default: [], null: false, array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "calendar_url"
    t.index ["name"], name: "index_service_areas_on_name"
    t.index ["zipcodes"], name: "index_service_areas_on_zipcodes", using: :gin
  end

  create_table "subscription_plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "slug", null: false
    t.string "name", null: false
    t.string "price", null: false
    t.string "interval", null: false
    t.string "perk", default: ""
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "stripe_price_id"
    t.index ["interval"], name: "index_subscription_plans_on_interval"
    t.index ["slug"], name: "index_subscription_plans_on_slug"
    t.index ["stripe_price_id"], name: "index_subscription_plans_on_stripe_price_id", unique: true
  end

  create_table "subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "payment_method_id", null: false
    t.uuid "subscription_plan_id", null: false
    t.uuid "user_id", null: false
    t.string "stripe_subscription_id"
    t.string "status"
    t.datetime "canceled_at", precision: 6
    t.datetime "trial_start", precision: 6
    t.datetime "trial_end", precision: 6
    t.datetime "current_period_start", precision: 6
    t.datetime "current_period_end", precision: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payment_method_id"], name: "index_subscriptions_on_payment_method_id"
    t.index ["stripe_subscription_id"], name: "index_subscriptions_on_stripe_subscription_id"
    t.index ["subscription_plan_id"], name: "index_subscriptions_on_subscription_plan_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name", null: false, comment: "First Name"
    t.string "last_name", null: false, comment: "Last Name"
    t.string "email", default: "", null: false, comment: "Email Address"
    t.string "phone_number", null: false, comment: "Phone Number (+15555555555)"
    t.string "gender", default: "other", null: false, comment: "Gender"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "requested_zipcode"
    t.boolean "auth_zero_user_created", default: false
    t.string "stripe_customer_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["gender"], name: "index_users_on_gender"
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
    t.index ["stripe_customer_id"], name: "index_users_on_stripe_customer_id", unique: true
  end

  create_table "webhook_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "webhookable_type"
    t.bigint "webhookable_id"
    t.string "service", default: "", null: false
    t.json "payload"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["service"], name: "index_webhook_events_on_service"
    t.index ["webhookable_type", "webhookable_id"], name: "index_webhook_events_on_webhookable"
  end

  create_table "work_orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "property_id", null: false
    t.string "status"
    t.string "description"
    t.string "vendor"
    t.string "scheduled_date"
    t.string "scheduled_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["property_id"], name: "index_work_orders_on_property_id"
  end

  add_foreign_key "devices", "users"
  add_foreign_key "payment_methods", "users"
  add_foreign_key "properties", "users"
  add_foreign_key "subscriptions", "payment_methods"
  add_foreign_key "subscriptions", "subscription_plans"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "work_orders", "properties"
end
