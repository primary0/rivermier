class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :user_id
      t.string :name
      t.string :screen_name
      t.string :profile_image_url
      t.boolean :protected_user, default: false
      t.boolean :following, default: false
      t.timestamps
    end
  end
end
