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

ActiveRecord::Schema[7.0].define(version: 2022_12_17_095941) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "common_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "caption"
    t.string "img_uri"
    t.string "default_hn_chat_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order_index"
    t.index ["order_index"], name: "index_common_requests_on_order_index", unique: true
  end

  create_table "deep_links", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "linkable_type"
    t.uuid "linkable_id"
    t.string "url"
    t.string "feature"
    t.string "campaign"
    t.string "stage"
    t.string "tags", default: [], array: true
    t.jsonb "data"
    t.string "canonical_url"
    t.string "path"
    t.datetime "expired_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "deeplink_path"
    t.index ["linkable_type", "linkable_id"], name: "index_deep_links_on_linkable"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_devices_on_device_id", unique: true
    t.index ["user_id"], name: "index_devices_on_user_id"
  end

  create_table "document_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_document_groups_on_user_id"
  end

  create_table "documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "invoice_id"
    t.uuid "property_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "document_group_id"
    t.string "name"
    t.string "description"
    t.text "tags", default: [], null: false, array: true
    t.uuid "payment_id"
    t.index ["document_group_id"], name: "index_documents_on_document_group_id"
    t.index ["invoice_id"], name: "index_documents_on_invoice_id"
    t.index ["payment_id"], name: "index_documents_on_payment_id"
    t.index ["property_id"], name: "index_documents_on_property_id"
    t.index ["tags"], name: "index_documents_on_tags", using: :gin
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "estimates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "work_order_id", null: false
    t.string "homeowner_amount"
    t.string "homeowner_amount_actual"
    t.string "vendor_amount"
    t.text "description"
    t.string "vendor_name"
    t.string "vendor_category"
    t.datetime "scheduled_at"
    t.datetime "scheduled_window_start"
    t.datetime "scheduled_window_end"
    t.datetime "shared_at"
    t.datetime "approved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "second_vendor_amount"
    t.string "access_token"
    t.datetime "declined_at"
    t.index ["approved_at"], name: "index_estimates_on_approved_at"
    t.index ["shared_at"], name: "index_estimates_on_shared_at"
    t.index ["work_order_id"], name: "index_estimates_on_work_order_id"
  end

  create_table "home_care_tips", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "label", null: false
    t.string "description"
    t.boolean "show_button", default: true, null: false
    t.string "default_hn_chat_message", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "week"
    t.string "time_of_year"
    t.string "service_provider"
    t.string "other_provider"
    t.index ["label"], name: "index_home_care_tips_on_label"
    t.index ["week"], name: "index_home_care_tips_on_week"
  end

  create_table "invoices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "promo_code_id"
    t.uuid "subscription_id"
    t.uuid "user_id"
    t.string "description"
    t.string "status"
    t.string "total"
    t.datetime "period_start"
    t.datetime "period_end"
    t.string "stripe_id"
    t.jsonb "stripe_object"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "finalized_at", precision: nil
    t.datetime "payment_attempted_at", precision: nil
    t.uuid "work_order_id"
    t.string "access_token"
    t.date "paid_at"
    t.index ["access_token"], name: "index_invoices_on_access_token", unique: true
    t.index ["promo_code_id"], name: "index_invoices_on_promo_code_id"
    t.index ["status"], name: "index_invoices_on_status"
    t.index ["stripe_id"], name: "index_invoices_on_stripe_id", unique: true
    t.index ["subscription_id"], name: "index_invoices_on_subscription_id"
    t.index ["user_id"], name: "index_invoices_on_user_id"
    t.index ["work_order_id"], name: "index_invoices_on_work_order_id"
  end

  create_table "line_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "invoice_id"
    t.string "amount", default: "0", null: false
    t.string "description"
    t.string "hubspot_id"
    t.string "stripe_id"
    t.jsonb "stripe_object"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.integer "quantity"
    t.index ["hubspot_id"], name: "index_line_items_on_hubspot_id"
    t.index ["invoice_id"], name: "index_line_items_on_invoice_id"
    t.index ["stripe_id"], name: "index_line_items_on_stripe_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "last_four"
    t.datetime "deleted_at"
    t.index ["stripe_token"], name: "index_payment_methods_on_stripe_token", unique: true
    t.index ["user_id"], name: "index_payment_methods_on_user_id"
  end

  create_table "payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "invoice_id"
    t.uuid "user_id"
    t.uuid "payment_method_id"
    t.string "amount"
    t.string "description"
    t.string "statement_descriptor"
    t.string "status"
    t.boolean "refunded", default: false, null: false
    t.boolean "paid", default: false, null: false
    t.string "stripe_id"
    t.jsonb "stripe_object"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "originator"
    t.string "purpose"
    t.index ["invoice_id"], name: "index_payments_on_invoice_id"
    t.index ["payment_method_id"], name: "index_payments_on_payment_method_id"
    t.index ["status"], name: "index_payments_on_status"
    t.index ["stripe_id"], name: "index_payments_on_stripe_id", unique: true
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "promo_codes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: false, null: false
    t.string "code", null: false
    t.string "name"
    t.string "percent_off"
    t.string "stripe_id"
    t.jsonb "stripe_object"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "amount_off"
    t.string "coupon_id"
    t.string "duration"
    t.integer "duration_in_months"
    t.index ["code"], name: "index_promo_codes_on_code", unique: true
    t.index ["coupon_id"], name: "index_promo_codes_on_coupon_id"
    t.index ["stripe_id"], name: "index_promo_codes_on_stripe_id", unique: true
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "push_notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "device_id", null: false
    t.string "fcm_message_id"
    t.string "fcm_project_id"
    t.string "fcm_token"
    t.string "priority_id", default: "default", null: false
    t.string "visibility_id", default: "private", null: false
    t.string "topic"
    t.string "analytics_label"
    t.string "title", null: false
    t.string "body"
    t.string "image_url"
    t.jsonb "data", default: {}, null: false
    t.jsonb "response"
    t.jsonb "options", default: {}, null: false
    t.datetime "sent_at"
    t.datetime "delivered_at"
    t.datetime "opened_at"
    t.string "error_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_push_notifications_on_device_id"
    t.index ["fcm_message_id"], name: "index_push_notifications_on_fcm_message_id", unique: true
  end

  create_table "service_areas", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "zipcodes", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_price_id"
    t.boolean "active", default: false, null: false
    t.index ["active"], name: "index_subscription_plans_on_active"
    t.index ["interval"], name: "index_subscription_plans_on_interval"
    t.index ["slug"], name: "index_subscription_plans_on_slug"
    t.index ["stripe_price_id"], name: "index_subscription_plans_on_stripe_price_id", unique: true
  end

  create_table "subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "payment_method_id", null: false
    t.uuid "subscription_plan_id", null: false
    t.uuid "user_id", null: false
    t.string "stripe_id"
    t.string "status"
    t.datetime "canceled_at"
    t.datetime "trial_start"
    t.datetime "trial_end"
    t.datetime "current_period_start"
    t.datetime "current_period_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "stripe_object"
    t.uuid "promo_code_id"
    t.index ["payment_method_id"], name: "index_subscriptions_on_payment_method_id"
    t.index ["promo_code_id"], name: "index_subscriptions_on_promo_code_id"
    t.index ["stripe_id"], name: "index_subscriptions_on_stripe_id", unique: true
    t.index ["subscription_plan_id"], name: "index_subscriptions_on_subscription_plan_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name", null: false, comment: "First Name"
    t.string "last_name", null: false, comment: "Last Name"
    t.string "email", default: "", null: false, comment: "Email Address"
    t.string "phone_number", null: false, comment: "Phone Number (+15555555555)"
    t.string "gender", default: "other", null: false, comment: "Gender"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "requested_zipcode"
    t.boolean "auth_zero_user_created", default: false
    t.string "stripe_id"
    t.string "hubspot_id"
    t.jsonb "hubspot_contact_object"
    t.uuid "promo_code_id"
    t.string "contact_type", default: "Customer"
    t.string "onboarding_step"
    t.string "onboarding_code"
    t.string "onboarding_link"
    t.string "arrivy_id"
    t.string "how_did_you_hear_about_us"
    t.string "intercom_id"
    t.datetime "delete_requested_at", precision: nil
    t.boolean "test_account", default: false
    t.boolean "first_walkthrough_performed", default: false, null: false
    t.datetime "deleted_at"
    t.index ["arrivy_id"], name: "index_users_on_arrivy_id", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["gender"], name: "index_users_on_gender"
    t.index ["hubspot_id"], name: "index_users_on_hubspot_id", unique: true
    t.index ["intercom_id"], name: "index_users_on_intercom_id", unique: true
    t.index ["onboarding_code"], name: "index_users_on_onboarding_code", unique: true
    t.index ["phone_number"], name: "index_users_on_phone_number"
    t.index ["promo_code_id"], name: "index_users_on_promo_code_id"
    t.index ["stripe_id"], name: "index_users_on_stripe_id", unique: true
  end

  create_table "webhook_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "webhookable_type"
    t.bigint "webhookable_id"
    t.string "service", default: "", null: false
    t.json "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "processed_at", precision: nil
    t.index ["service"], name: "index_webhook_events_on_service"
    t.index ["webhookable_type", "webhookable_id"], name: "index_webhook_events_on_webhookable"
  end

  create_table "work_order_statuses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "slug", null: false
    t.string "name"
    t.string "hubspot_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hubspot_pipeline_id"
    t.index ["hubspot_id"], name: "index_work_order_statuses_on_hubspot_id", unique: true
    t.index ["slug"], name: "index_work_order_statuses_on_slug", unique: true
  end

  create_table "work_orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "property_id"
    t.string "status"
    t.string "description"
    t.string "vendor"
    t.string "scheduled_date"
    t.string "scheduled_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hubspot_id"
    t.jsonb "hubspot_object"
    t.string "homeowner_amount"
    t.string "vendor_amount"
    t.datetime "scheduled_window_start"
    t.datetime "scheduled_window_end"
    t.string "homeowner_amount_actual"
    t.boolean "customer_approved_work"
    t.datetime "walkthrough_date"
    t.string "walkthrough_time"
    t.datetime "completed_at"
    t.string "refund_amount"
    t.string "refund_reason"
    t.string "arrivy_id"
    t.text "invoice_notes"
    t.datetime "deleted_at"
    t.datetime "requested_at"
    t.index ["arrivy_id"], name: "index_work_orders_on_arrivy_id", unique: true
    t.index ["deleted_at"], name: "index_work_orders_on_deleted_at"
    t.index ["hubspot_id"], name: "index_work_orders_on_hubspot_id", unique: true
    t.index ["property_id"], name: "index_work_orders_on_property_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "devices", "users"
  add_foreign_key "document_groups", "users"
  add_foreign_key "documents", "invoices"
  add_foreign_key "documents", "properties"
  add_foreign_key "documents", "users"
  add_foreign_key "estimates", "work_orders"
  add_foreign_key "invoices", "promo_codes"
  add_foreign_key "invoices", "subscriptions"
  add_foreign_key "invoices", "users"
  add_foreign_key "invoices", "work_orders", on_delete: :cascade
  add_foreign_key "line_items", "invoices"
  add_foreign_key "payment_methods", "users"
  add_foreign_key "payments", "invoices"
  add_foreign_key "payments", "payment_methods"
  add_foreign_key "payments", "users"
  add_foreign_key "properties", "users"
  add_foreign_key "push_notifications", "devices"
  add_foreign_key "subscriptions", "payment_methods"
  add_foreign_key "subscriptions", "promo_codes"
  add_foreign_key "subscriptions", "subscription_plans"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "work_orders", "properties"
end
