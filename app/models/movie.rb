# encoding: UTF-8
# == Schema Information
#
# Table name: movies
#
#  id                  :integer          not null, primary key
#  movie_source_id     :integer
#  path                :string(255)
#  title               :string(255)
#  bytes               :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  imdb_id             :string(255)
#  tagline             :string(255)
#  plot                :text
#  runtime             :integer
#  rating              :decimal(, )
#  poster_url          :string(255)
#  release_date        :date
#  certification       :string(255)
#  thumbnail_image_raw :binary
#

require 'open-uri'
class Movie < ActiveRecord::Base

  POSTER_RATIO = (40.0 / 27.0)

  attr_accessor :imdb_movie

  def update_metadata!
    if imdb_id.blank? && (movie = find_imdb_movie).present?
      self.imdb_movie = movie
    end

    if imdb_id.blank? || imdb_id_changed?
      attributes.except("id").keys.each do |key|
        self.send("#{key}=", imdb_movie.send(key)) if imdb_movie.respond_to?(key)
      end
    end

    self.runtime          = runtime.to_i
    self.bytes            = pathname.size

    if poster_url?
      if (poster_blob = poster_image_blob).present?
        image  = Magick::Image.from_blob(poster_blob).first
        width  = 50
        height = width*POSTER_RATIO
        self.thumbnail_image_raw = image.resize_to_fit(width.to_i, height.to_i).to_blob
      end
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
    movies = find_imdb_movies
    return false unless movies.any?
    imdb.find_movie_by_id(movies.first[:imdb_id])
  end

  def find_imdb_movies
    # Fuzzy match requied on title see 311 for example
    Array(imdb.find_by_title(inferred_title))
  end

  protected

  def imdb
    @imdb = ImdbParty::Imdb.new(:anonymize => true)
  end

end
