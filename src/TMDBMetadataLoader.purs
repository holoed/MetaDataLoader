module TMDBMetadataLoader where

import Data.String
import Data.Function
import Data.Either
import Prelude
import Control.Bind
import Control.Monad.Eff
import Control.Monad.Trans
import Control.Monad.Cont.Trans
import Data.Foreign
import Data.Foreign.Class
import Data.Traversable
import Data.Foldable
import HttpClient
import Config
import Data.Array.Unsafe 
import Data.Array (filter)
import qualified Data.Map as Map 
import Data.Tuple
import Data.Maybe.Unsafe 

type MovieSpec = { title:: String, year:: String, source:: String }

type TVShowSpec = { seriesId:: Number, title:: String, year:: String, source:: String, seasons:: [TVShowSeasonSpec] }

type TVShowSeasonSpec = { season:: String, episodes:: [TVShowEpisodeSpec] }

type TVShowEpisodeSpec = { seriesId:: Number, title:: String, series:: String, season:: String, episode:: String, source:: String }

type MyList = { movies:: [MovieSpec], tvshows:: [TVShowSpec] }

type MovieDetails = { movieId:: Number, genresIds:: [Number], genre:: String, title::String, year:: String, source:: String, director:: String, actors::String, writer::String, plot:: String, poster::String, runtime::Number }

type MovieCredits = { movieId:: Number, director:: String, writer:: String, actors::String, runtime::Number }

type TVShowDetails = { seriesId::Number, title::String, year:: String, plot::String, poster:: String, seasons:: [TVShowSeasonDetails] }

type TVShowSeasonDetails = { season:: String, episodes:: [TVShowEpisodeDetails] }

type TVShowEpisodeDetails = { title::String, season::String, episode:: String, source:: String, released:: String, plot:: String, poster:: String }

type TMDBMovieDetails = { results::[{ id::Number, title::String, genre_ids::[Number], release_date::String, overview:: String, poster_path:: String }] }

type TMDBTVShowDetails = { results::[{ id::Number, name::String, first_air_date::String, overview::String, poster_path:: String }] }

type TMDBTVShowEpisodeDetails = { name::String, season_number::String, episode_number::String, air_date::String, overview::String, still_path::String }

type TMDBMovieCredits = { id::Number, runtime::Number, credits:: { cast::[{name::String}], crew::[{name::String, job::String}] } }

type TMBMovieGenres = { genres:: [{ id ::Number, name:: String }] }

type State = { movies::[MovieDetails], tvshows::[TVShowDetails] }

getState :: Url -> Http State
getState url = do myList <- getMyList url
                  genres <- fetchGenreList
                  mvs <- fetchMoviesDetails (myList.movies)
                  tvs <- fetchTVShowsDetails (myList.tvshows)
                  return ({ movies: (\m -> m { genre = joinWith ", " ((\k -> fromJust(Map.lookup k genres)) <$> m.genresIds) }) <$> mvs, 
                            tvshows: tvs })

getMyList ::  String -> Http MyList
getMyList url = fetch url

fetchGenreList :: Http (Map.Map Number String)
fetchGenreList = do x <- (fetch ("http://api.themoviedb.org/3/genre/movie/list?api_key=" ++ apiKey) :: Http TMBMovieGenres)
                    return (Map.fromList ((\y -> Tuple (y.id) (y.name)) <$> x.genres))

fetchMoviesDetails :: [MovieSpec] -> Http [MovieDetails]
fetchMoviesDetails moviesSpecs = sequence (fetchMovie <$> moviesSpecs)

fetchTVShowsDetails :: [TVShowSpec] -> Http [TVShowDetails]
fetchTVShowsDetails tvShowsSpecs = sequence (f <$> tvShowsSpecs)
	where f x = do dt <- fetchTVShow x
	               sdt <- fetchTVShowsSeasonsDetails (x { seriesId = dt.seriesId })
 	               return (dt { seasons = sdt })

fetchTVShowsSeasonsDetails :: TVShowSpec -> Http [TVShowSeasonDetails]
fetchTVShowsSeasonsDetails tvshow = sequence (f <$> (tvshow.seasons))
    where f x = (\eps -> { season : x.season, episodes : eps }) <$> 
                fetchTVShowEpisodesDetails ((\v -> v { seriesId = tvshow.seriesId }) <$> x.episodes)

fetchTVShowEpisodesDetails :: [TVShowEpisodeSpec] -> Http [TVShowEpisodeDetails]
fetchTVShowEpisodesDetails episodesSpecs = sequence (fetchTVShowEpisode <$> episodesSpecs)

fetchMovieExtraInfo :: Number -> Http MovieCredits
fetchMovieExtraInfo movieId = (\details -> { 
		    movieId : details.id,
        director: joinWith "," ((\x -> x.name) <$> (filter (\x-> x.job == "Director") details.credits.crew)),
        writer: joinWith "," ((\x -> x.name) <$> (filter (\x-> x.job == "Writer") details.credits.crew)),
        actors: joinWith "," ((\x -> x.name) <$> details.credits.cast),
        runtime: details.runtime
       }) <$> response
  where url = "http://api.themoviedb.org/3/movie/" ++ (show movieId) ++ "?api_key=" ++ apiKey ++ "&append_to_response=credits,releases"
        response = (fetch url) :: Http TMDBMovieCredits

fetchMovie :: MovieSpec -> Http MovieDetails
fetchMovie movie = do dt <- fetchMovie' movie
                      info <- fetchMovieExtraInfo (dt.movieId)
                      return dt { director = info.director, 
                                  writer = info.writer,
                                  actors = info.actors,
                                  runtime = info.runtime }

fetchMovie' :: MovieSpec ->  Http MovieDetails
fetchMovie' movie = (\details -> { 
		movieId : details.id,
        title : details.title,
        plot: details.overview,
        poster: "http://image.tmdb.org/t/p/w500/" ++ details.poster_path,
        year : details.release_date, 
        genresIds: details.genre_ids,
        genre:"",
		    source : movie.source,
		    director: "",
        writer:"",
        actors:"",
        runtime:0 }) <$> ((\x -> head (x.results)) <$> response)
  where url = "http://api.themoviedb.org/3/search/movie?api_key=" ++ apiKey ++ query ++ year
        query = "&query=" ++ replaceSpaceWithPlus (movie.title)
        year = "&year=" ++ movie.year
        response = (fetch url) :: Http TMDBMovieDetails

fetchTVShow :: TVShowSpec ->  Http TVShowDetails
fetchTVShow tvshow = (\details -> { 
		seriesId: details.id,
        title : details.name,
        year : details.first_air_date, 
        plot: details.overview,
        poster: "http://image.tmdb.org/t/p/w500/" ++ details.poster_path,
		    seasons: [] }) <$> ((\x -> head (x.results)) <$> response)
  where url = "http://api.themoviedb.org/3/search/tv?api_key=" ++ apiKey ++ query ++ year
        query = "&query=" ++ replaceSpaceWithPlus (tvshow.title)
        year = "&year=" ++ tvshow.year
        response = (fetch url) :: Http TMDBTVShowDetails  

fetchTVShowEpisode :: TVShowEpisodeSpec -> Http TVShowEpisodeDetails
fetchTVShowEpisode episode = (\details -> { 
        title : details.name,
        season: show details.season_number,
        episode: show details.episode_number,
        plot: details.overview,
        released: details.air_date,
		    source : episode.source,
        poster: "http://image.tmdb.org/t/p/w500/" ++ details.still_path }) <$> response
  where url = "http://api.themoviedb.org/3/tv/" ++ (show episode.seriesId) ++ 
                "/season/" ++ episode.season ++
                "/episode/" ++ episode.episode ++ 
                "?api_key=" ++ apiKey
        response = (fetch url) :: Http TMDBTVShowEpisodeDetails  


replaceSpaceWithPlus :: String -> String
replaceSpaceWithPlus =  (joinWith "+") <<< (split " ") 