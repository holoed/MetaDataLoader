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

type MovieSpec = { title:: String, year:: String }

type TVShowSpec = { title:: String, year:: String }

type RootData = { movies:: [MovieSpec], tvshows:: [TVShowSpec] }

type MovieDetails = { title::String, year:: String }

rootList ::  Http RootData
rootList = (\(Right x) -> x) <$> fetch "http://192.168.0.24/MyMoviesCatalog.json"

moviesSpecs :: Http [MovieSpec]
moviesSpecs =  (\x -> x.movies) <$> rootList

fetchMoviesDetails :: Http [MovieDetails]
fetchMoviesDetails =  join ((sequence <<< (<$>) fetchMovie) <$> moviesSpecs)

fetchMovie :: MovieSpec ->  Http MovieDetails
fetchMovie movie = (\(Right x) -> x) <$> fetch url
  where url = "http://www.omdbapi.com/?t=" ++ (replace " " "+" (movie.title)) ++ "&y=" ++ movie.year ++ "&plot=full&type=movie&r=json"

fetchTVShow :: TVShowSpec ->  Http MovieDetails
fetchTVShow tvshow = (\(Right x) -> x) <$> fetch url
  where url = "http://www.omdbapi.com/?t=" ++ (replace " " "+" (tvshow.title)) ++ "&y=" ++ tvshow.year ++ "&plot=full&type=series&r=json"
