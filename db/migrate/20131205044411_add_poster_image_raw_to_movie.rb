class AddPosterImageRawToMovie < ActiveRecord::Migration
  def change
    add_column :movies, :thumbnail_image_raw, :binary
  end
end
