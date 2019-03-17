# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_02_25_064050) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "archives", force: :cascade do |t|
    t.string "index_name"
    t.string "language"
    t.text "data_sources", array: true
    t.string "human_readable_name"
    t.text "description"
    t.hstore "topbar_links"
    t.hstore "info_dropdown_links"
    t.string "logo"
    t.string "favicon"
    t.string "theme"
    t.string "lookingglass_instance"
    t.string "uploadform_instance"
    t.string "docmanager_instance"
    t.string "catalyst_instance"
    t.string "ocr_in_path"
    t.string "ocr_out_path"
    t.string "archive_key"
    t.text "admin_users", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "archives_users", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "archive_id", null: false
    t.index ["archive_id", "user_id"], name: "index_archives_users_on_archive_id_and_user_id"
    t.index ["user_id", "archive_id"], name: "index_archives_users_on_user_id_and_archive_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "archive_auth_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
