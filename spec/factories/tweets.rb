# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tweet do
    tweet_id "MyString"
    text "MyText"
    in_reply_to_status_id "MyString"
    retweeted false
    retweet_count 1
    internal_retweet_count 1
    reply_count 1
    following_tweet false
    protected_tweet false
    community_call false
  end
end
