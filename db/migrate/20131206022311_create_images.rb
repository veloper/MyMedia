class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.integer :imageable_id
      t.string :imageable_type
      t.string :url
      t.binary :large_blob
      t.binary :medium_blob
      t.binary :thumbnail_blob

      t.timestamps
    end
  end
end
