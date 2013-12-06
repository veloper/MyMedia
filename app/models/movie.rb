# encoding: UTF-8
# == Schema Information
#
# Table name: movies
#
#  id              :integer          not null, primary key
#  movie_source_id :integer
#  path            :string(255)
#  title           :string(255)
#  bytes           :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  imdb_id         :string(255)
#  tagline         :string(255)
#  plot            :text
#  runtime         :integer
#  rating          :decimal(, )
#  poster_url      :string(255)
#  release_date    :date
#  certification   :string(255)
#

require 'open-uri'
require 'ostruct'
class Movie < ActiveRecord::Base

  POSTER_RATIO = (40.0 / 27.0)

  belongs_to :movie_source
  has_many :images, :as => :imageable

  attr_accessor :imdb_movie

  def self.update_all_metadata!
    includes(:images).all.each do |movie|
      movie.delay(:queue => 'movies').update_metadata!
    end
  end

  def update_metadata!
    raise "Only existing movies may have their metadata updated." unless persisted?

    movie = find_imdb_movie

    attributes.except("id").keys.each do |key|
      self.send("#{key}=", movie.send(key)) if movie.respond_to?(key)
    end

    self.runtime          = runtime.to_i
    self.bytes            = pathname.size

    if poster_url? && images.where(:url => poster_url).blank?
      images.create!{|r| r.url = poster_url}.delay(:queue => 'images').process!
    end

    save!
  end

  def poster_image_blob
    poster_url? ? open(poster_url).read : nil
  end

  def title_to_safe_filename
    translations = {
      "/"   => "_",
      "\\"  => "_",
      "³"   => " 3",
      ":"   => " -",
      "?"   => "",
      "*"   => "",
      '"'   => "",
      "·"   => "-",
      "&"   => "and",
      "|"   => "_",
      "..." => ""
    }
    translations.reduce(title) do |filename, (find, replace)|
      filename.tap { |x| x.gsub!(find, replace) }
    end
  end

  def pathname
    Pathname.new(path)
  end

  def directory
    pathname.parent
  end

  def inferred_title
    file_title = pathname.basename('.*').to_s.downcase
    dir_title  = directory.basename.to_s.downcase
    bad_titles = ["title"]
    (bad_titles.any? {|search| file_title[search] }) ? dir_title : file_title
  end

  def imdb_movie
    return false unless imdb_id?
    return @imdb_movie if (@imdb_movie.present? && @imdb_movie.imdb_id == imdb_id)
    @imdb_movie = imdb.find_movie_by_id(imdb_id)
  end

  def find_imdb_movie
    movies = find_imdb_movies.map(&OpenStruct.method(:new))
    return false unless movies.any?
    movie = FuzzyMatch.new(movies.first(2).reverse, :read => :title).find(inferred_title)
    imdb.find_movie_by_id(movie.imdb_id)
  end

  def find_imdb_movies
    Array(imdb.find_by_title(inferred_title))
  end

  protected

  def imdb
    @imdb = ImdbParty::Imdb.new(:anonymize => true)
  end

end
