WITH raw_movies  AS(
    select * from MOVIELENS.RAW.RAW_MOVIES
)
SELECT
    movieId AS movie_id,
    title,
    genres
FROM raw_movies