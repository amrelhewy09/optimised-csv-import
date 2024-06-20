class Movie < ApplicationRecord
  belongs_to :director
  has_many :reviews
  has_many :movie_actors
  has_many :actors, through: :movie_actors

  scope :sorted_by_rating, -> { left_joins(:reviews).group(:id).order('AVG(reviews.rating) DESC') }
end
