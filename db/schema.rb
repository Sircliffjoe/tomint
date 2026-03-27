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

ActiveRecord::Schema[8.1].define(version: 2026_03_27_172500) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "areas", force: :cascade do |t|
    t.bigint "area_leader_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.bigint "state_id", null: false
    t.datetime "updated_at", null: false
    t.index ["state_id"], name: "index_areas_on_state_id"
  end

  create_table "blog_posts", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "published_at"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_blog_posts_on_author_id"
  end

  create_table "directorates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "director_user_id"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["director_user_id"], name: "index_directorates_on_director_user_id"
  end

  create_table "donations", force: :cascade do |t|
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.string "currency"
    t.string "donor_email"
    t.string "payment_reference"
    t.string "purpose"
    t.integer "status"
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency"
    t.datetime "end_time"
    t.integer "event_type"
    t.string "location"
    t.decimal "price"
    t.boolean "registration_open"
    t.datetime "start_time"
    t.bigint "state_id"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["state_id"], name: "index_events_on_state_id"
  end

  create_table "pages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "slug"
    t.string "template"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_pages_on_slug", unique: true
  end

  create_table "registrations", force: :cascade do |t|
    t.decimal "amount_paid"
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.string "payment_reference"
    t.string "qr_code_token"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["event_id"], name: "index_registrations_on_event_id"
    t.index ["user_id"], name: "index_registrations_on_user_id"
  end

  create_table "report_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "directorate_id"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["directorate_id"], name: "index_report_categories_on_directorate_id"
  end

  create_table "reports", force: :cascade do |t|
    t.datetime "approved_at"
    t.datetime "created_at", null: false
    t.jsonb "data"
    t.bigint "directorate_id", null: false
    t.bigint "report_category_id", null: false
    t.datetime "reviewed_at"
    t.bigint "state_id", null: false
    t.integer "status"
    t.datetime "submitted_at"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["directorate_id"], name: "index_reports_on_directorate_id"
    t.index ["report_category_id"], name: "index_reports_on_report_category_id"
    t.index ["state_id"], name: "index_reports_on_state_id"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "states", force: :cascade do |t|
    t.string "code"
    t.text "contact_info"
    t.string "country"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.integer "year_created"
    t.bigint "zone_id"
  end

  create_table "training_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "duration"
    t.string "media_url"
    t.string "title"
    t.bigint "training_id", null: false
    t.datetime "updated_at", null: false
    t.index ["training_id"], name: "index_training_sessions_on_training_id"
  end

  create_table "trainings", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "state_id"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["state_id"], name: "index_trainings_on_state_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "directorate_id"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role"
    t.integer "state_id"
    t.datetime "updated_at", null: false
    t.index ["directorate_id"], name: "index_users_on_directorate_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["state_id"], name: "index_users_on_state_id"
  end

  create_table "zones", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "areas", "states"
  add_foreign_key "blog_posts", "users", column: "author_id"
  add_foreign_key "events", "states"
  add_foreign_key "registrations", "events"
  add_foreign_key "registrations", "users"
  add_foreign_key "report_categories", "directorates"
  add_foreign_key "reports", "directorates"
  add_foreign_key "reports", "report_categories"
  add_foreign_key "reports", "states"
  add_foreign_key "reports", "users"
  add_foreign_key "training_sessions", "trainings"
  add_foreign_key "trainings", "states"
end
