class ActorsController < ApplicationController
  def index
    # actor indexed by name so ILIKE abc% will be faster
    @pagy, @actors = pagy(Actor.search(params[:query]))
  end
end
