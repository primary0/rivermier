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

ActiveRecord::Schema.define(:version => 20120830002114) do

  create_table "daily_digests", :force => true do |t|
    t.timestamp "created_at", :null => false
    t.timestamp "updated_at", :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer   "priority",   :default => 0
    t.integer   "attempts",   :default => 0
    t.text      "handler"
    t.text      "last_error"
    t.timestamp "run_at"
    t.timestamp "locked_at"
    t.timestamp "failed_at"
    t.string    "locked_by"
    t.string    "queue"
    t.timestamp "created_at",                :null => false
    t.timestamp "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "photos", :force => true do |t|
    t.string    "url"
    t.timestamp "created_at", :null => false
    t.timestamp "updated_at", :null => false
  end

  create_table "photos_tweets", :id => false, :force => true do |t|
    t.integer "photo_id"
    t.integer "tweet_id"
  end

  create_table "trends", :force => true do |t|
    t.string    "text"
    t.timestamp "created_at", :null => false
    t.timestamp "updated_at", :null => false
  end

  create_table "trends_tweets", :id => false, :force => true do |t|
    t.integer "trend_id"
    t.integer "tweet_id"
  end

  create_table "tweets", :force => true do |t|
    t.string    "tweet_id"
    t.text      "text"
    t.text      "tags"
    t.integer   "in_reply_to_status_id"
    t.integer   "retweet_count",         :default => 0
    t.boolean   "retweeted",             :default => false
    t.boolean   "community_call",        :default => false
    t.timestamp "created_at",                               :null => false
    t.timestamp "updated_at",                               :null => false
    t.integer   "user_id"
  end

  create_table "tweets_urls", :id => false, :force => true do |t|
    t.integer "tweet_id"
    t.integer "url_id"
  end

  create_table "tweets_videos", :id => false, :force => true do |t|
    t.integer "video_id"
    t.integer "tweet_id"
  end

  create_table "urls", :force => true do |t|
    t.string    "url"
    t.timestamp "created_at",  :null => false
    t.timestamp "updated_at",  :null => false
    t.string    "title"
    t.text      "description"
    t.string    "image"
    t.string    "site_name"
  end

  create_table "users", :force => true do |t|
    t.string    "user_id"
    t.string    "name"
    t.string    "screen_name"
    t.string    "profile_image_url"
    t.boolean   "protected_user",    :default => false
    t.boolean   "following",         :default => false
    t.timestamp "created_at",                           :null => false
    t.timestamp "updated_at",                           :null => false
  end

  create_table "videos", :force => true do |t|
    t.string    "url"
    t.timestamp "created_at", :null => false
    t.timestamp "updated_at", :null => false
    t.string    "media_id"
  end

end
