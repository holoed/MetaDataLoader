var loader = require ("MetadataLoader");

// loader.fetchMovie ({ title: "Back to the future", year: "1985"}) (function (x) { console.log(x); }) ()

// loader.fetchTVShow ({ title: "Columbo", year: "1971"}) (function (x) { console.log(x); }) ()

// loader.getMyList ("http://192.168.0.24/MyMoviesCatalog.json") (function (x) { console.log(x); })

// loader.fetchMovies (function (x) { console.log(x); }) ()

// loader.fetchMoviesDetails (function (x) { console.log(x); })

// loader.fetchTVShowsDetails (function (x) { console.log(x); })

// loader.fetchTVShowEpisode ({ series:"Columbo", season:"1", episode:"1", source:"http://url/file.mp4" })  (function (x) { console.log(x); })

loader.getState ("http://192.168.0.24/MyMoviesCatalog.json") (function (x) { console.log(x); })