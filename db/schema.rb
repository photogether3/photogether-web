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

ActiveRecord::Schema[8.0].define(version: 2025_04_26_073516) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
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

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "collections", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "category_id"
    t.string "type", limit: 20, default: "default", null: false
    t.string "title", limit: 50, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "favorites", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_favorites_on_category_id"
    t.index ["user_id", "category_id"], name: "index_favorites_on_user_id_and_category_id", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "policies", force: :cascade do |t|
    t.string "title", null: false
    t.string "kind", null: false
    t.text "content", null: false
    t.string "version", null: false
    t.boolean "is_active", default: true
    t.datetime "effective_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kind", "version"], name: "index_policies_on_kind_and_version", unique: true
  end

  create_table "policy_acceptances", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "policy_id", null: false
    t.datetime "accepted_at", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["policy_id"], name: "index_policy_acceptances_on_policy_id"
    t.index ["user_id", "policy_id"], name: "index_policy_acceptances_on_user_id_and_policy_id", unique: true
    t.index ["user_id"], name: "index_policy_acceptances_on_user_id"
  end

  create_table "post_metadata", force: :cascade do |t|
    t.integer "post_id", null: false
    t.integer "rank", default: 1, null: false
    t.string "content", limit: 50, null: false
    t.boolean "is_public", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_link", default: false, null: false
  end

  create_table "posts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "collection_id", null: false
    t.string "title", limit: 50, null: false
    t.string "content", limit: 100, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "refresh_tokens", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "refresh_token", null: false
    t.datetime "expiry_date", null: false
    t.datetime "last_refreshing_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["refresh_token"], name: "index_refresh_tokens_on_refresh_token", unique: true
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role_id", null: false
    t.string "nickname", limit: 20, null: false
    t.text "bio"
    t.string "otp", limit: 6
    t.datetime "otp_expiry_date"
    t.boolean "is_email_verified", default: false, null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "collections", "categories"
  add_foreign_key "collections", "users", on_delete: :cascade
  add_foreign_key "favorites", "categories"
  add_foreign_key "favorites", "users"
  add_foreign_key "policy_acceptances", "policies"
  add_foreign_key "policy_acceptances", "users"
  add_foreign_key "post_metadata", "posts", on_delete: :cascade
  add_foreign_key "posts", "collections"
  add_foreign_key "posts", "users", on_delete: :cascade
  add_foreign_key "refresh_tokens", "users", on_delete: :cascade
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "roles"
end
