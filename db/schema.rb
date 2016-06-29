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

ActiveRecord::Schema.define(version: 20160621041952) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "posts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "source_id"
    t.text    "title"
    t.text    "body"
    t.date    "date"
    t.string  "identifier"
    t.text    "meta_info"
  end

  add_index "posts", ["identifier"], name: "index_posts_on_identifier", using: :btree
  add_index "posts", ["meta_info"], name: "index_posts_on_meta_info", using: :btree
  add_index "posts", ["title"], name: "index_posts_on_title", using: :btree
  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "sources", force: :cascade do |t|
    t.string "name"
    t.string "url"
  end

  create_table "users", force: :cascade do |t|
    t.string  "username"
    t.date    "first_encountered"
    t.integer "source_id"
  end

  add_index "users", ["source_id"], name: "index_users_on_source_id", using: :btree

end
