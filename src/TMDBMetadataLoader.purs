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

type MovieSpec = { title:: String, year:: String, source:: String }

type TVShowSpec = { seriesId:: Number, title:: String, year:: String, source:: String, seasons:: [TVShowSeasonSpec] }

type TVShowSeasonSpec = { season:: String, episodes:: [TVShowEpisodeSpec] }

type TVShowEpisodeSpec = { seriesId:: Number, title:: String, series:: String, season:: String, episode:: String, source:: String }

type MyList = { movies:: [MovieSpec], tvshows:: [TVShowSpec] }

type MovieDetails = { movieId:: Number, title::String, year:: String, source:: String, director:: String, plot:: String }

type MovieCredits = { movieId:: Number, director:: String }

type TVShowDetails = { seriesId::Number, title::String, year:: String, seasons:: [TVShowSeasonDetails] }

type TVShowSeasonDetails = { season:: String, episodes:: [TVShowEpisodeDetails] }

type TVShowEpisodeDetails = { title::String, season::String, episode:: String, source:: String, released:: String }

type TMDBMovieDetails = { results::[{ id::Number, title::String, release_date::String, overview:: String }] }

type TMDBTVShowDetails = { results::[{ id::Number, name::String, first_air_date::String }] }

type TMDBTVShowEpisodeDetails = { name::String, season_number::String, episode_number::String, air_date::String }

type TMDBMovieCredits = { id::Number, cast::[{name::String}], crew::[{name::String, job::String}] }

type State = { movies::[MovieDetails], tvshows::[TVShowDetails] }

getState :: Url -> Http State
getState url = do myList <- getMyList url
                  mvs <- fetchMoviesDetails (myList.movies)
                  tvs <- fetchTVShowsDetails (myList.tvshows)
                  return ({ movies: mvs, tvshows: tvs })

getMyList ::  String -> Http MyList
getMyList url = fetch url

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

fetchMovieCredits :: Number -> Http MovieCredits
fetchMovieCredits movieId = (\details -> { 
		movieId : details.id,
        director: head ((\x -> x.name) <$> (filter (\x-> x.job == "Director") details.crew))
       }) <$> response
  where url = "http://api.themoviedb.org/3/movie/" ++ (show movieId) ++ "/credits?api_key=" ++ apiKey
        response = (fetch url) :: Http TMDBMovieCredits

fetchMovie :: MovieSpec -> Http MovieDetails
fetchMovie movie = do dt <- fetchMovie' movie
                      cr <- fetchMovieCredits (dt.movieId)
                      return dt { director = cr.director }

fetchMovie' :: MovieSpec ->  Http MovieDetails
fetchMovie' movie = (\details -> { 
		movieId : details.id,
        title : details.title,
        plot: details.overview,
        year : details.release_date, 
		source : movie.source,
		director: "" }) <$> ((\x -> head (x.results)) <$> response)
  where url = "http://api.themoviedb.org/3/search/movie?api_key=" ++ apiKey ++ query ++ year
        query = "&query=" ++ replaceSpaceWithPlus (movie.title)
        year = "&year=" ++ movie.year
        response = (fetch url) :: Http TMDBMovieDetails

fetchTVShow :: TVShowSpec ->  Http TVShowDetails
fetchTVShow tvshow = (\details -> { 
		seriesId: details.id,
        title : details.name,
        year : details.first_air_date, 
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
        released: details.air_date,
		source : episode.source }) <$> response
  where url = "http://api.themoviedb.org/3/tv/" ++ (show episode.seriesId) ++ 
                "/season/" ++ episode.season ++
                "/episode/" ++ episode.episode ++ 
                "?api_key=" ++ apiKey
        response = (fetch url) :: Http TMDBTVShowEpisodeDetails  


replaceSpaceWithPlus :: String -> String
replaceSpaceWithPlus =  (joinWith "+") <<< (split " ") 