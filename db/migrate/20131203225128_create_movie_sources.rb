class CreateMovieSources < ActiveRecord::Migration
  def change
    create_table :movie_sources do |t|
      t.string :path

      t.timestamps
    end
  end
end
