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

ActiveRecord::Schema.define(version: 2015_05_01_105737) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "opening_balance", precision: 10, scale: 2
    t.decimal "current_balance", precision: 10, scale: 2
    t.integer "user_id"
  end

  create_table "transaction_entries", id: :serial, force: :cascade do |t|
    t.integer "tranxaction_id"
    t.integer "account_id"
    t.decimal "debit_amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "account_balance", precision: 10, scale: 2
  end

  create_table "tranxactions", id: :serial, force: :cascade do |t|
    t.date "transaction_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "login", null: false
    t.string "email", null: false
    t.string "crypted_password", null: false
    t.string "password_salt", null: false
    t.string "persistence_token", null: false
    t.string "single_access_token", null: false
    t.string "perishable_token", null: false
    t.integer "login_count", default: 0, null: false
    t.integer "failed_login_count", default: 0, null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string "current_login_ip"
    t.string "last_login_ip"
  end

end
