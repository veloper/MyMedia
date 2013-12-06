class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.integer :movie_source_id
      t.string :path
      t.string :title
      t.integer :bytes
      t.text :tmdb_yaml

      t.timestamps
    end
  end
end
