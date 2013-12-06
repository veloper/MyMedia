class RemoveTmdbFieldsFromMovie < ActiveRecord::Migration
  def up
    remove_column :movies, :tmdb_yaml
  end

  def down
    add_column :movies, :tmdb_yaml, :text
  end
end
