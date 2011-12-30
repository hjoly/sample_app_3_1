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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111127203556) do

  create_table "microposts", :force => true do |t|
    t.string   "content"
    t.integer  "user_id",         :null => false
    t.integer  "replied_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "microposts", ["created_at"], :name => "index_microposts_on_created_at"
  add_index "microposts", ["user_id"], :name => "index_microposts_on_user_id"

  create_table "relationships", :force => true do |t|
    t.integer  "follower_id", :null => false
    t.integer  "followed_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["followed_id"], :name => "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id", "followed_id"], :name => "index_relationships_on_follower_id_and_followed_id", :unique => true
  add_index "relationships", ["follower_id"], :name => "index_relationships_on_follower_id"

  create_table "users", :force => true do |t|
    t.string   "name",               :limit => 50,                     :null => false
    t.string   "email",              :limit => 70,                     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password", :limit => 50
    t.string   "salt",               :limit => 100
    t.boolean  "admin",                             :default => false, :null => false
    t.string   "username",           :limit => 15,                     :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
