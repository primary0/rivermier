class AddMediaIdToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :media_id, :string
  end
end
