module OMDBMetadataLoader where

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

type MovieSpec = { title:: String, year:: String, source:: String }

type TVShowSpec = { title:: String, year:: String, source:: String, seasons:: [TVShowSeasonSpec] }

type TVShowSeasonSpec = { season:: String, episodes:: [TVShowEpisodeSpec] }

type TVShowEpisodeSpec = { title:: String, series:: String, season:: String, episode:: String, source:: String }

type MyList = { movies:: [MovieSpec], tvshows:: [TVShowSpec] }

type MovieDetails = { title::String, year:: String, source:: String }

type TVShowDetails = { title::String, year:: String, seasons:: [TVShowSeasonDetails] }

type TVShowSeasonDetails = { season:: String, episodes:: [TVShowEpisodeDetails] }

type TVShowEpisodeDetails = { title::String, season::String, episode:: String, source:: String }

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
	               sdt <- fetchTVShowsSeasonsDetails x
	               return (dt { seasons = sdt })

fetchTVShowsSeasonsDetails :: TVShowSpec -> Http [TVShowSeasonDetails]
fetchTVShowsSeasonsDetails tvshow = sequence (f <$> (tvshow.seasons))
    where f x = (\eps -> { season : x.season, episodes : eps }) <$> fetchTVShowEpisodesDetails(x.episodes)

fetchTVShowEpisodesDetails :: [TVShowEpisodeSpec] -> Http [TVShowEpisodeDetails]
fetchTVShowEpisodesDetails episodesSpecs = sequence (fetchTVShowEpisode <$> episodesSpecs)

fetchMovie :: MovieSpec ->  Http MovieDetails
fetchMovie movie = (\details -> details { source = movie.source }) <$> fetch url
  where url = "http://www.omdbapi.com/?t=" ++ replaceSpaceWithPlus (movie.title) ++
              "&y=" ++ movie.year ++
              "&plot=full&type=movie&r=json"

fetchTVShow :: TVShowSpec ->  Http TVShowDetails
fetchTVShow tvshow = fetch url
  where url = "http://www.omdbapi.com/?t=" ++ replaceSpaceWithPlus (tvshow.title) ++
              "&y=" ++ tvshow.year ++
              "&plot=full&type=series&r=json"

fetchTVShowEpisode :: TVShowEpisodeSpec -> Http TVShowEpisodeDetails
fetchTVShowEpisode episode = (\details -> details { source = episode.source }) <$> fetch url
  where url = "http://www.omdbapi.com/?t=" ++ replaceSpaceWithPlus (episode.series) ++
              "&Season=" ++ episode.season ++
              "&Episode=" ++ episode.episode ++ "&plot=full&type=series&r=json"

replaceSpaceWithPlus :: String -> String
replaceSpaceWithPlus =  (joinWith "+") <<< (split " ") 
