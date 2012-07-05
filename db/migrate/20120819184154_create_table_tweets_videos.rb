class CreateTableTweetsVideos < ActiveRecord::Migration
  def up
  	create_table :tweets_videos, id: false do |t|
  		t.integer :video_id
  		t.integer :tweet_id
  	end
  end

  def down
  	drop_table :tweets_videos
  end
end
