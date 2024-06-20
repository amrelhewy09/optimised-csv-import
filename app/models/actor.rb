class Actor < ApplicationRecord
  has_many :movie_actors
  has_many :movies, through: :movie_actors


  class << self
    def search(query)
      if query.blank?
        all
      else
        where("name ILIKE ?", "#{query}%")
      end
    end
  end
end
