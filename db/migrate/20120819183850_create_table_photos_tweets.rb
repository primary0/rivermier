class CreateTablePhotosTweets < ActiveRecord::Migration
  def up
  	create_table :photos_tweets, id: false do |t|
  		t.integer :photo_id
  		t.integer :tweet_id
  	end
  end

  def down
  	drop_table :photos_tweets
  end
end
