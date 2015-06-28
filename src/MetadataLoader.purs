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

type TVShowSpec = { title:: String, year:: String, source:: String }

type TVShowEpisodeSpec = { series:: String, season:: String, episode:: String, source:: String }

type RootData = { movies:: [MovieSpec], tvshows:: [TVShowSpec] }

type MovieDetails = { title::String, year:: String, source:: String }

type TVShowDetails = { title::String, year:: String }

type TVShowEpisodeDetails = { title::String, season::String, episode:: String, source:: String }

rootList ::  Http RootData
rootList = (\(Right x) -> x) <$> fetch "http://192.168.0.24/MyMoviesCatalog.json"

moviesSpecs :: Http [MovieSpec]
moviesSpecs =  (\x -> x.movies) <$> rootList

fetchMoviesDetails :: Http [MovieDetails]
fetchMoviesDetails =  join ((sequence <<< (<$>) fetchMovie) <$> moviesSpecs)

tvShowsSpecs :: Http [TVShowSpec]
tvShowsSpecs = (\x -> x.tvshows) <$> rootList

fetchTVShowsDetails :: Http [TVShowDetails]
fetchTVShowsDetails = join ((sequence <<< (<$>) fetchTVShow) <$> tvShowsSpecs)

fetchMovie :: MovieSpec ->  Http MovieDetails
fetchMovie movie = (\(Right details) -> details { source = movie.source }) <$> fetch url
  where url = "http://www.omdbapi.com/?t=" ++ (replace " " "+" (movie.title)) ++
              "&y=" ++ movie.year ++
              "&plot=full&type=movie&r=json"

fetchTVShow :: TVShowSpec ->  Http TVShowDetails
fetchTVShow tvshow = (\(Right x) -> x) <$> fetch url
  where url = "http://www.omdbapi.com/?t=" ++ (replace " " "+" (tvshow.title)) ++
              "&y=" ++ tvshow.year ++
              "&plot=full&type=series&r=json"

fetchTVShowEpisode :: TVShowEpisodeSpec -> Http TVShowEpisodeDetails
fetchTVShowEpisode episode = (\(Right details) -> details { source = episode.source }) <$> fetch url
  where url = "http://www.omdbapi.com/?t=" ++ (replace " " "+" (episode.series)) ++
              "&Season=" ++ episode.season ++
              "&Episode=" ++ episode.episode ++ "&plot=full&type=series&r=json"
