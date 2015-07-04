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
import qualified Data.Array as Array 
import qualified Data.Map as Map 
import Data.Tuple
import Data.Maybe.Unsafe 
import TMDBTypes

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

fetchMovieExtraInfo :: Number -> Http MovieExtraInfo
fetchMovieExtraInfo movieId = (\details -> { 
		    movieId : details.id,
        director: joinWith ", " ((\x -> x.name) <$> (Array.filter (\x-> x.job == "Director") details.credits.crew)),
        writer: joinWith ", " ((\x -> x.name) <$> (Array.filter (\x-> x.job == "Writer" || x.job == "Screenplay") details.credits.crew)),
        actors: joinWith ", " (Array.take 5 ((\x -> x.name) <$> details.credits.cast)),
        rated: (head (details.releases.countries)).certification,
        runtime: details.runtime
       }) <$> response
  where url = "http://api.themoviedb.org/3/movie/" ++ (show movieId) ++ "?api_key=" ++ apiKey ++ "&append_to_response=credits,releases"
        response = (fetch url) :: Http TMDBMovieExtraInfo

fetchMovie :: MovieSpec -> Http MovieDetails
fetchMovie movie = do dt <- fetchMovie' movie
                      info <- fetchMovieExtraInfo (dt.movieId)
                      return dt { director = info.director, 
                                  writer = info.writer,
                                  actors = info.actors,
                                  runtime = info.runtime,
                                  rated = info.rated }

fetchMovie' :: MovieSpec ->  Http MovieDetails
fetchMovie' movie = (\details -> { 
		movieId : details.id,
        title : details.title,
        plot: details.overview,
        poster: "http://image.tmdb.org/t/p/w500/" ++ details.poster_path,
        year : movie.year,
        release: details.release_date, 
        genresIds: details.genre_ids,
        genre:"",
		    source : movie.source,
		    director: "",
        writer:"",
        actors:"",
        runtime:0,
        popularity: details.popularity,
        rated:"" }) <$> ((\x -> head (x.results)) <$> response)
  where url = "http://api.themoviedb.org/3/search/movie?api_key=" ++ apiKey ++ query ++ year
        query = "&query=" ++ replaceSpaceWithPlus (movie.title)
        year = "&year=" ++ movie.year
        response = (fetch url) :: Http TMDBMovieDetails

fetchTVShow :: TVShowSpec -> Http TVShowDetails
fetchTVShow tvshow = do dt <- fetchTVShow' tvshow
                        info <- fetchTVShowExtraInfo (dt.seriesId)
                        return dt { actors = info.actors,
                                    runtime = info.runtime,
                                    popularity = info.popularity,
                                    genre = info.genre,
                                    rating = info.rating }

fetchTVShow' :: TVShowSpec ->  Http TVShowDetails
fetchTVShow' tvshow = (\details -> { 
		    seriesId: details.id,
        title : details.name,
        year : details.first_air_date, 
        plot: details.overview,
        poster: "http://image.tmdb.org/t/p/w500/" ++ details.poster_path,
		    seasons: [],
        actors:"",
        runtime:0,
        popularity: 0,
        rating:"",
        genre:"" }) <$> ((\x -> head (x.results)) <$> response)
  where url = "http://api.themoviedb.org/3/search/tv?api_key=" ++ apiKey ++ query ++ year
        query = "&query=" ++ replaceSpaceWithPlus (tvshow.title)
        year = "&year=" ++ tvshow.year
        response = (fetch url) :: Http TMDBTVShowDetails  

fetchTVShowExtraInfo :: Number -> Http TVShowExtraInfo
fetchTVShowExtraInfo tvshowId = (\details -> { 
        tvshowId : details.id,
        actors: joinWith ", " (Array.take 5 ((\x -> x.name) <$> details.credits.cast)),
        runtime: head details.episode_run_time,
        popularity: details.popularity,
        genre: joinWith ", " (Array.take 5 ((\x -> x.name) <$> details.genres)),
        rating: joinWith " " (Array.take 1 ((\x -> x.rating) <$> details.content_ratings.results))
       }) <$> response
  where url = "http://api.themoviedb.org/3/tv/" ++ (show tvshowId) ++ "?api_key=" ++ apiKey ++ "&append_to_response=credits,content_ratings"
        response = (fetch url) :: Http TMDBTVShowExtraInfo

fetchTVShowEpisode :: TVShowEpisodeSpec -> Http TVShowEpisodeDetails
fetchTVShowEpisode episode = (\details -> { 
        title : details.name,
        season: show details.season_number,
        episode: show details.episode_number,
        plot: details.overview,
        release: details.air_date,
		    source : episode.source,
        director: joinWith "," ((\x -> x.name) <$> (Array.filter (\x-> x.job == "Director") details.crew)),
        writer: joinWith "," ((\x -> x.name) <$> (Array.filter (\x-> x.job == "Writer" || x.job == "Screenplay") details.crew)),
        actors: joinWith "," (Array.take 5 ((\x -> x.name) <$> details.guest_stars)),
        poster: "http://image.tmdb.org/t/p/w500/" ++ details.still_path }) <$> response
  where url = "http://api.themoviedb.org/3/tv/" ++ (show episode.seriesId) ++ 
                "/season/" ++ episode.season ++
                "/episode/" ++ episode.episode ++ 
                "?api_key=" ++ apiKey
        response = (fetch url) :: Http TMDBTVShowEpisodeDetails  

foreign import encodeURI :: String -> String

replaceSpaceWithPlus :: String -> String
replaceSpaceWithPlus =  encodeURI