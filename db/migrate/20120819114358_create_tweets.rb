class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :tweet_id
      t.text :text
      t.text :tags
      t.integer :in_reply_to_status_id
      t.integer :retweet_count, default: 0
      t.boolean :retweeted, default: false
      t.boolean :community_call, default: false
      t.timestamps
    end
  end
end
