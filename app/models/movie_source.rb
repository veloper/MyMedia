# == Schema Information
#
# Table name: movie_sources
#
#  id         :integer          not null, primary key
#  path       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MovieSource < ActiveRecord::Base
  attr_accessible :path
  has_many :movies


  def pathname
    Pathname.new path
  end

  def movie_files
    Pathname.glob(pathname.join('**', '*.{m4v,mp4}'))
  end

  def add_missing_movies!
    movie_files.each do |movie_file|
      movies.where(:path => movie_file.to_path).first_or_create!
    end
  end

end
