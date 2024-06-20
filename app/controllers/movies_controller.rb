class MoviesController < ApplicationController
  def index
    @pagy, @movies = pagy(Movie.sorted_by_rating.includes(:director, :actors).all)
  end
end
