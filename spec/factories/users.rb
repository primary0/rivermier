# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    user_id "MyString"
    name "MyString"
    screen_name "MyString"
    profile_image_url "MyString"
    protected_user false
    following false
  end
end
