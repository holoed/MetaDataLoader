module TMDBTypes where

type MovieSpec = { title:: String, year:: String, source:: String }

type TVShowSpec = { seriesId:: Number, title:: String, year:: String, source:: String, seasons:: [TVShowSeasonSpec] }

type TVShowSeasonSpec = { season:: String, episodes:: [TVShowEpisodeSpec] }

type TVShowEpisodeSpec = { seriesId:: Number, title:: String, series:: String, season:: String, episode:: String, source:: String }

type MyList = { movies:: [MovieSpec], tvshows:: [TVShowSpec] }

type MovieDetails = { movieId:: Number, genresIds:: [Number], genre:: String, release::String, title::String, year:: String, source:: String, director:: String, actors::String, writer::String, plot:: String, poster::String, runtime::Number, popularity::String }

type MovieCredits = { movieId:: Number, director:: String, writer:: String, actors::String, runtime::Number }

type TVShowDetails = { seriesId::Number, title::String, year:: String, plot::String, poster:: String, seasons:: [TVShowSeasonDetails] }

type TVShowSeasonDetails = { season:: String, episodes:: [TVShowEpisodeDetails] }

type TVShowEpisodeDetails = { title::String, season::String, episode:: String, source:: String, released:: String, plot:: String, poster:: String }

type TMDBMovieDetails = { results::[{ id::Number, title::String, genre_ids::[Number], release_date::String, overview:: String, poster_path:: String, popularity::String }] }

type TMDBTVShowDetails = { results::[{ id::Number, name::String, first_air_date::String, overview::String, poster_path:: String }] }

type TMDBTVShowEpisodeDetails = { name::String, season_number::String, episode_number::String, air_date::String, overview::String, still_path::String }

type TMDBMovieCredits = { id::Number, runtime::Number, credits:: { cast::[{name::String}], crew::[{name::String, job::String}] } }

type TMBMovieGenres = { genres:: [{ id ::Number, name:: String }] }

type State = { movies::[MovieDetails], tvshows::[TVShowDetails] }