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

ActiveRecord::Schema.define(version: 2022_07_06_033347) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string "trackable_type"
    t.bigint "trackable_id"
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "key"
    t.text "parameters"
    t.string "recipient_type"
    t.bigint "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["owner_type", "owner_id"], name: "index_activities_on_owner_type_and_owner_id"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["recipient_type", "recipient_id"], name: "index_activities_on_recipient_type_and_recipient_id"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable_type_and_trackable_id"
  end

  create_table "announcements", force: :cascade do |t|
    t.string "title"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "scope"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "available_report_histories", force: :cascade do |t|
    t.date "date_on"
    t.string "report_id"
    t.string "report_name"
    t.string "pbi_workspace_id"
    t.string "idempotence_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date_on", "report_id", "pbi_workspace_id"], name: "available_report_history_idx"
    t.index ["idempotence_key"], name: "available_report_history_by_id_idx"
  end

  create_table "contactusmodels", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "powerbi_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "access_token"
    t.datetime "expires"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "usage_metric_histories", force: :cascade do |t|
    t.date "date_on"
    t.string "report_id"
    t.string "report_name"
    t.string "workspace_id"
    t.string "workspace_name"
    t.string "idempotence_key"
    t.integer "view_count"
    t.uuid "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["report_id", "report_name", "user_id", "date_on"], name: "usage_metric_histories_idx"
  end

  create_table "usage_metrics", force: :cascade do |t|
    t.date "date_on"
    t.json "report_views"
    t.uuid "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_workspaces", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "workspace_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "uid"
    t.string "name"
    t.string "roles"
    t.boolean "is_admin", default: false
    t.boolean "onboarded", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "last_viewed_workspace"
    t.string "last_viewed_report"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  create_table "workspaces", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "pbi_workspace_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
