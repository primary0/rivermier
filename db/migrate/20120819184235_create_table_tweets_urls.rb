class CreateTableTweetsUrls < ActiveRecord::Migration
  def up
  	create_table :tweets_urls, id: false do |t|
  		t.integer :tweet_id
  		t.integer :url_id
  	end
  end

  def down
  	drop_table :tweets_urls
  end
end
