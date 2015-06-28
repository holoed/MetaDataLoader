module MetadataLoader where

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

type TVShowDetails = { title::String, year:: String, seasons:: [TVShowSeasonSpec] }

type TVShowEpisodeDetails = { title::String, season::String, episode:: String, source:: String }

type State = { movies::[MovieDetails], tvshows::[TVShowDetails] }

getState :: Url -> Http State
getState url = do myList <- getMyList url
                  mvs <- fetchMoviesDetails (myList.movies)
                  tvs <- fetchTVShowsDetails (myList.tvshows)
                  return ({ movies: mvs, tvshows: tvs })


getMyList ::  String -> Http MyList
getMyList url = (\(Right x) -> x) <$> fetch url

fetchMoviesDetails :: [MovieSpec] -> Http [MovieDetails]
fetchMoviesDetails moviesSpecs = sequence (fetchMovie <$> moviesSpecs)

fetchTVShowsDetails :: [TVShowSpec] -> Http [TVShowDetails]
fetchTVShowsDetails tvShowsSpecs = sequence (fetchTVShow <$> tvShowsSpecs)

fetchTVShowEpisodesDetails :: [TVShowEpisodeSpec] -> Http [TVShowEpisodeDetails]
fetchTVShowEpisodesDetails episodesSpecs = sequence (fetchTVShowEpisode <$> episodesSpecs)

fetchMovie :: MovieSpec ->  Http MovieDetails
fetchMovie movie = (\(Right details) -> details { source = movie.source }) <$> fetch url
  where url = "http://www.omdbapi.com/?t=" ++ (replace " " "+" (movie.title)) ++
              "&y=" ++ movie.year ++
              "&plot=full&type=movie&r=json"

fetchTVShow :: TVShowSpec ->  Http TVShowDetails
fetchTVShow tvshow = (\(Right details) -> details { seasons = tvshow.seasons }) <$> fetch url
  where url = "http://www.omdbapi.com/?t=" ++ (replace " " "+" (tvshow.title)) ++
              "&y=" ++ tvshow.year ++
              "&plot=full&type=series&r=json"

fetchTVShowEpisode :: TVShowEpisodeSpec -> Http TVShowEpisodeDetails
fetchTVShowEpisode episode = (\(Right details) -> details { source = episode.source }) <$> fetch url
  where url = "http://www.omdbapi.com/?t=" ++ (replace " " "+" (episode.series)) ++
              "&Season=" ++ episode.season ++
              "&Episode=" ++ episode.episode ++ "&plot=full&type=series&r=json"
