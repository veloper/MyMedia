class AddMetaFieldsToMovie < ActiveRecord::Migration
  def change
    add_column :movies, :imdb_id, :string
    add_column :movies, :tagline, :string
    add_column :movies, :plot, :text
    add_column :movies, :runtime, :string
    add_column :movies, :rating, :decimal
    add_column :movies, :poster_url, :string
    add_column :movies, :release_date, :date
    add_column :movies, :certification, :string
  end
end
