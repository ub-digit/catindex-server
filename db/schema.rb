# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160202092720) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_tokens", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "token"
    t.datetime "token_expire"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "cards", force: :cascade do |t|
    t.text     "card_type"
    t.text     "primary_registrator_username"
    t.text     "secondary_registrator_username"
    t.text     "classification"
    t.text     "collection"
    t.text     "lookup_field_value"
    t.text     "lookup_field_type"
    t.text     "title"
    t.integer  "year_from"
    t.integer  "year_to"
    t.boolean  "no_year",                        default: false
    t.text     "primary_registrator_problem"
    t.text     "secondary_registrator_problem"
    t.json     "primary_registrator_values"
    t.json     "secondary_registrator_values"
    t.datetime "primary_registrator_start"
    t.datetime "secondary_registrator_start"
    t.datetime "primary_registrator_end"
    t.datetime "secondary_registrator_end"
    t.text     "additional_authors",             default: [],                 array: true
    t.text     "reference_text"
    t.integer  "ipac_image_id"
    t.text     "ipac_note"
    t.text     "ipac_lookup"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.text     "tertiary_registrator_username"
    t.text     "tertiary_registrator_problem"
    t.json     "tertiary_registrator_values"
    t.datetime "tertiary_registrator_start"
    t.datetime "tertiary_registrator_end"
  end

  create_table "ipacdata", id: false, force: :cascade do |t|
    t.integer "ipac_image_id"
    t.text    "ipac_note"
    t.text    "ipac_lookup"
  end

  create_table "users", force: :cascade do |t|
    t.text     "username"
    t.text     "password"
    t.text     "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
