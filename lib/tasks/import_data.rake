require 'smarter_csv'
task :import_data => :environment do |t, args|
  Rails.logger = Logger.new(STDOUT)
  director_cache = {}
  actors_cache = {}
  movies_cache = {}
  # 4 queries per batch actors,directors,movies and movie_actors
  SmarterCSV.process("movies.csv", { chunk_size: 100 }) do |chunk|
    new_movies = {}
    movie_directors = {}
    movie_actors = Hash.new { |hash, key| hash[key] = [] }

    movies = chunk.group_by { |row| row[:movie] }
    movies.each do |movie_name, movie_rows|
      new_movie = Movie.new(name: movie_name,
                            description: movie_rows.first[:description],
                            year: movie_rows.first[:year],
                            filming_location: movie_rows.first[:filming_location],
                            country: movie_rows.first[:country])

      movie_directors[movie_name] = movie_rows.first[:director]
      movie_rows.each do |row|
        movie_actors[movie_name] << row[:actor]
      end

      new_movies[new_movie.name] = new_movie
    end

  # INSERT DIRECTORS
    directors = movie_directors.values.uniq.map { |name| { name: name } }
    directors_imported = Director.import directors, on_duplicate_key_ignore: true, returning: [:name]
    director_cache.merge!(cache_imports(directors_imported))
  ##############################################
  # INSERT ACTORS
    actors = movie_actors.values.flatten.uniq.map { |name| { name: name } }
    actors_imported = Actor.import actors, on_duplicate_key_ignore: true, returning: [:name]
    actors_cache.merge!(cache_imports(actors_imported))
  ##############################################
  # INSERT MOVIES
    new_movies.each do |movie_name, movie|
      movie.director_id = director_cache[movie_directors[movie_name]]
      movie.actor_ids += movie_actors[movie_name].map { |actor_name| actors_cache[actor_name] }
    end

    imported_movies = Movie.import new_movies.values, on_duplicate_key_ignore: true, returning: [:name]
    movies_cache.merge!(cache_imports(imported_movies))
  ##############################################
  # INSERT MOVIE_ACTORS
    movie_actors_to_be_imported = []
    movie_actors.each do |movie_name, actor_names|
      movie_id = movies_cache[movie_name]
      actor_ids = actor_names.map { |actor_name| actors_cache[actor_name] }
      movie_actors_to_be_imported += actor_ids.map { |actor_id| { movie_id: movie_id, actor_id: actor_id } }
    end
    MovieActor.import movie_actors_to_be_imported, on_duplicate_key_ignore: true
  end

  ##### INSERT REVIEWS #####
  users_cache = {}
  SmarterCSV.process("reviews.csv", { chunk_size: 100 }) do |chunk|
    reviews_grouped_by_user = chunk.group_by { |row| row[:user] }
    # IMPORT USERS
    imported_users = User.import reviews_grouped_by_user.keys.map{ |name| {name: name}},
                          on_duplicate_key_ignore: true, returning: [:name]
    users_cache.merge!(cache_imports(imported_users))
    reviews = []
    reviews_grouped_by_user.each do |user_name, user_reviews|
      reviews += user_reviews.map { |review| { user_id: users_cache[user_name], movie_id: movies_cache[review[:movie]], rating: review[:rating] } }
    end
    Review.import reviews
  end
end

def cache_imports(import_result)
  names,ids = import_result.results, import_result.ids
  cache = {}
  names.each_with_index do |name, index|
    cache[name] = ids[index]
  end
  cache
end
