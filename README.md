# README
This assignment is about writing a small Ruby On Rails application. Use a methodoloy that works for you or that you are used to.

1. Create a new application with Ruby on Rails

2. Study the content of movies.csv and reviews.csv

3. Define a database schema and add it to your application

4. Write an import task to import both CSV-files

5. Show an overview of all movies in your application

6. Make a search form to search for an actor

7. Sort the overview by average stars (rating) in an efficient way

**Design CSV importer/application for heavy data processing 
## Gems Used

1. activerecord-import
2. smarter-csv
3. pagy

## Schema

A very simple schema which has Actor, Movie, Director, ActorMovie, User, and Review.

## CSV Importing

- The CSV is processed in chunks and every chunk does exactly 4 insert queries.
- Queries are cached in memory and reused in different associations.
- This has pros and cons, a tradeoff between slight memory overhead and roundtrips to the database.
- Smarter CSV gem is much better than the default CSV library for processing in chunks and parsing.
- The reviews reuse the cache and are processed in chunks also.
- One other option is to use something like `parallel` gem which would fork processes and process in parallel.

## Movie Overview

- `/movies` will bring up the movies endpoint.
- Movies are sorted by their average rating by a simple left join query. Eager loading the directors and actors to prevent N+1 problem.
- Again a tradeoff between taking the overhead on reading and make writes simpler or the opposite.
- We could've had the columns cached and compute directly but would require overhead in writing when creating new reviews.
- I used the `pagy` gem because time was tight but I would've done cursor pagination which prevents the use of `OFFSET` that sequential scans.

## Actor Overview

- `/actors` will bring up the actors endpoint with a search bar to search for actors.
- The search uses `ILIKE` on the name column which is indexed.
- Queries like `ILIKE q%` would utilize the index.
- However, queries like `ILIKE %q` will not.
- Better options are to use an inverted index (GIN index in postgres) which would require an extension installation.

## Start the Server

Run the following command:

```bash
docker compose up -d
```
## Import Data
Run `docker exec -it web rake import_data`


## Questions
1. I didn't quite understand why the same movie had different filiming locations, was i supposed to concatenate them? didn't understand that part at all.

## Additional Information
- I used the postgis image because i didn't have space on my machine and had this already there incase you might wonder.
