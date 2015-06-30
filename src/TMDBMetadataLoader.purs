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

type MovieSpec = { title:: String, year:: String, source:: String }

type TVShowSpec = { title:: String, year:: String, source:: String, seasons:: [TVShowSeasonSpec] }

type TVShowSeasonSpec = { season:: String, episodes:: [TVShowEpisodeSpec] }

type TVShowEpisodeSpec = { seriesId:: String, title:: String, series:: String, season:: String, episode:: String, source:: String }

type MyList = { movies:: [MovieSpec], tvshows:: [TVShowSpec] }

type MovieDetails = { title::String, year:: String, source:: String }

type TVShowDetails = { title::String, year:: String, seasons:: [TVShowSeasonDetails] }

type TVShowSeasonDetails = { season:: String, episodes:: [TVShowEpisodeDetails] }

type TVShowEpisodeDetails = { title::String, season::String, episode:: String, source:: String, released:: String }

type TMDBMovieDetails = { results::[{ title::String, release_date::String }] }

type TMDBTVShowDetails = { results::[{ name::String, first_air_date::String }] }

type TMDBTVShowEpisodeDetails = { name::String, season_number::String, episode_number::String, air_date::String }

getMyList ::  String -> Http MyList
getMyList url = fetch url

fetchMovie :: MovieSpec ->  Http MovieDetails
fetchMovie movie = (\details -> { 
        title : details.title,
        year : details.release_date, 
		source : movie.source }) <$> ((\x -> head (x.results)) <$> response)
  where url = "http://api.themoviedb.org/3/search/movie?api_key=" ++ apiKey ++ query ++ year
        query = "&query=" ++ replaceSpaceWithPlus (movie.title)
        year = "&year=" ++ movie.year
        response = (fetch url) :: Http TMDBMovieDetails

fetchTVShow :: TVShowSpec ->  Http TVShowDetails
fetchTVShow tvshow = (\details -> { 
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
  where url = "http://api.themoviedb.org/3/tv/" ++ episode.seriesId ++ 
                "/season/" ++ episode.season ++
                "/episode/" ++ episode.episode ++ 
                "?api_key=" ++ apiKey
        response = (fetch url) :: Http TMDBTVShowEpisodeDetails  


replaceSpaceWithPlus :: String -> String
replaceSpaceWithPlus =  (joinWith "+") <<< (split " ") 