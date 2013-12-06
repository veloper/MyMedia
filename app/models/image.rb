# == Schema Information
#
# Table name: images
#
#  id             :integer          not null, primary key
#  imageable_id   :integer
#  imageable_type :string(255)
#  url            :string(255)
#  large_blob     :binary
#  medium_blob    :binary
#  thumbnail_blob :binary
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Image < ActiveRecord::Base
  belongs_to :imageable, :polymorphic => true

  attr_accessible :imageable_id, :imageable_type, :large_blob, :medium_blob, :thumbnail_blob, :url

  DIMENSIONS = {
    :thumbnail => [150, 150],
    :medium    => [300, 300],
    :large     => [720, 720]
  }

  scope :unprocessed, where(:thumbnail_blob => nil)

  def self.process_all!(options = {})
    unprocessed.all.each do |image|
      image.delay(:queue => 'images').process!(options)
    end
  end

  def processed?
    thumbnail_blob?
  end

  def process!(options = {})
    return true if processed? && options.fetch(:force, false) == false

    if url_blob = download_url_blob!
      full_image = Magick::Image.from_blob(url_blob).first
      DIMENSIONS.each do |size, (width, height)|
        resized_image = full_image.resize_to_fit(width, height).to_blob
        self.send("#{size}_blob=", resized_image)
      end
      save!
    end
  end

  def download_url_blob!
    return false unless url?
    require 'open-uri'
    open(url).read.presence || false
  end

end
