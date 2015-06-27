module MetadataLoader where

import Data.String
import Data.Function
import Data.Either
import Control.Monad.Eff
import Control.Monad.Cont.Trans
import Http

type MovieSpec = { title:: String, year:: String }

rootList :: forall eff. C eff (Either ErrorCode String)
rootList = fetch "http://192.168.0.24/MyMoviesCatalog.json"

fetchMovie :: forall eff. MovieSpec -> C eff (Either ErrorCode String)
fetchMovie movie = fetch url
  where url = "http://www.omdbapi.com/?t=" ++ (replace " " "+" (movie.title)) ++ "&y=" ++ movie.year ++ "&plot=full&type=movie&r=json"
