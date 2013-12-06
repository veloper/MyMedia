namespace :movies do

  task :refresh => [:sync, :update_metadata] do
  end

  desc "Read from all sources and update movies."
  task :sync => :environment do
    MovieSource.all do |movie_source|
      movie_source.add_missing_movies!
    end
  end

  desc "Update metadata for all movies."
  task :update_metadata => :environment do
    Movie.all.each(&:update_metadata!)
  end

end