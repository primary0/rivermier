class AddMetaFieldsToUrls < ActiveRecord::Migration
  def change
    add_column :urls, :title, :string
    add_column :urls, :description, :text
    add_column :urls, :image, :string
    add_column :urls, :site_name, :string
  end
end
