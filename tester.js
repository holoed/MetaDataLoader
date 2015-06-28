var loader = require ("MetadataLoader");

// loader.fetchMovie ({ title: "Back to the future", year: "1985"}) (function (x) { console.log(x); }) ()

// loader.fetchTVShow ({ title: "Columbo", year: "1971"}) (function (x) { console.log(x); }) ()

// loader.rootList (function (x) { console.log(x); })

// loader.fetchMovies (function (x) { console.log(x); }) ()

// loader.fetchMoviesDetails (function (x) { console.log(x); })

// loader.fetchTVShowsDetails (function (x) { console.log(x); })

loader.fetchTVShowEpisode ({ series:"Columbo", season:"1", episode:"1" })  (function (x) { console.log(x); })
