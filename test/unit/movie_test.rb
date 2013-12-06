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

require 'test_helper'

class MovieTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
