module TMDBTypes where

type MovieSpec = { title:: String, year:: String, source:: String, poster:: String }

type TVShowSpec = { seriesId:: Number, title:: String, year:: String, source:: String, seasons:: [TVShowSeasonSpec] }

type TVShowSeasonSpec = { season:: String, episodes:: [TVShowEpisodeSpec] }

type TVShowEpisodeSpec = { seriesId:: Number, title:: String, series:: String, season:: String, episode:: String, source:: String }

type MyList = { movies:: [MovieSpec], tvshows:: [TVShowSpec] }

type MovieDetails = { movieId:: Number, genresIds:: [Number], genre:: String, release::String, title::String, year:: String, source:: String, director:: String, actors::String, writer::String, plot:: String, poster::String, runtime::Number, popularity::String, rated::String }

type MovieExtraInfo = { movieId:: Number, director:: String, writer:: String, actors::String, runtime::Number, rated::String }

type TVShowDetails = { seriesId::Number, title::String, year:: String, plot::String, poster:: String, seasons:: [TVShowSeasonDetails], actors::String, runtime::Number, popularity::Number, genre::String, rating::String }

type TVShowExtraInfo = { tvshowId:: Number, actors::String, runtime::Number, popularity::Number, genre::String, rating::String }

type TVShowSeasonDetails = { season:: String, episodes:: [TVShowEpisodeDetails] }

type TVShowEpisodeDetails = { title::String, season::String, episode:: String, source:: String, release:: String, plot:: String, poster:: String, director:: String, actors::String, writer::String }

type TMDBMovieDetails = { results::[{ id::Number, title::String, genre_ids::[Number], release_date::String, overview:: String, poster_path:: String, popularity::String }] }

type TMDBTVShowDetails = { results::[{ id::Number, name::String, first_air_date::String, overview::String, poster_path:: String }] }

type TMDBTVShowEpisodeDetails = { name::String, season_number::String, episode_number::String, air_date::String, overview::String, still_path::String, crew::[{name::String, job::String}], guest_stars::[{name::String}] }

type TMDBMovieExtraInfo = {
	id::Number,
	runtime::Number,
	credits:: { cast::[{name::String}], crew::[{name::String, job::String}] },
	releases:: { countries::[{ certification::String }] }
}

type TMDBTVShowExtraInfo = {
	id::Number,
	episode_run_time::[Number],
	credits:: { cast::[{name::String}], crew::[{name::String, job::String}] },
	first_air_date:: String,
	genres::[{id::String, name::String}],
	popularity:: Number,
	content_ratings::{ results:: [{ rating::String }] }

}

type TMBMovieGenres = { genres:: [{ id ::Number, name:: String }] }

type State = { movies::[MovieDetails], tvshows::[TVShowDetails] }

emptyMovie :: MovieDetails
emptyMovie = {
		    movieId : -1,
        title : "",
        plot: "",
        poster: "",
        year : "",
        release: "",
        genresIds: [],
        genre:"",
		    source : "",
		    director: "",
        writer:"",
        actors:"",
        runtime:0,
        popularity: "",
        rated:""
			}

emptyExtraInfo :: MovieExtraInfo
emptyExtraInfo = {
	     movieId: -1,
			 director: "",
			 writer: "",
			 actors: "",
			 runtime: 0,
			 rated: ""
		 }
