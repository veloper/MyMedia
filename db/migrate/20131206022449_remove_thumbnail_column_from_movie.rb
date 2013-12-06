class RemoveThumbnailColumnFromMovie < ActiveRecord::Migration
  def up
    Movie.update_all("thumbnail_image_raw='0'", '1=1')
    remove_column :movies, :thumbnail_image_raw
  end

  def down
    add_column :movies, :thumbnail_image_raw, :string
  end
end
