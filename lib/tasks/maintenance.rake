namespace :maintenance do
	task :database_cleanup => :environment do
		Tweet.where("retweeted = ? AND created_at < ?", false, 7.days.ago).all.each do |tweet|
			tweet.destroy
		end
	end

	task :collect_users => :environment do
		user_ids = Twitter.friend_ids.collection
		user_ids = user_ids.map{|x|x.to_s}
		user_ids.each do |user_id|
		  user = User.where(:user_id => user_id).first  
		  unless user
		    User.create(user_id: user_id.to_s, following: true)
		  else
		    if user.following == false
		      user.update_attribute(:following, true)
		    end
		  end
		end     
		users = User.all
		users.each do |user|
		  if !user_ids.include?(user.user_id) && user.following == true
		    user.update_attribute(:following, false)
		  end
		end	
	end	

	task :start_consumer => :environment do	
		Delayed::Job.where(queue: 'consumer').destroy_all	
		Delayed::Job.enqueue(ConsumerJob.new, queue: "consumer")
	end	
end