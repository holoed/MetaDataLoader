
var mock = require ('mock-require');
var assert = require("assert");

var testUrl = "http://192.168.0.24/MyMoviesCatalog.json";
var testMyList = {
    movies: [
    {
      source: "http://192.168.0.24/Movies/The%20Usual%20Suspects.mp4",
      title: "The Usual Suspects",
      year: "1995"
    }],
    tvshows: []
};

mock('../output/HttpClient', { fetch: function(url) {
        console.log(url);
        return function(cb) {
          if (url == testUrl)
            return cb(testMyList);
          if (url == "http://www.omdbapi.com/?t=Back+to+the+future&y=1985&plot=full&type=movie&r=json")
            return cb({
              title: "Back to the future (The Movie)",
              year: "1985",
            });
          if (url == "http://www.omdbapi.com/?t=The+Bourne+Supremacy&y=2004&plot=full&type=movie&r=json")
            return cb({
              title: "The Bourne Supremacy (The Movie)",
              year: "2004",
            });
          if (url == "http://www.omdbapi.com/?t=Columbo&y=1971&plot=full&type=series&r=json")
            return cb({
              title: 'Columbo (The Series)',
              year: '1971',
              season: []
            });
          if (url == "http://www.omdbapi.com/?t=Columbo&Season=2&Episode=3&plot=full&type=series&r=json")
            return cb({
              title: "The most cruicial game",
              released: "05 Nov 1972",
              season: "2",
              episode: "3"
            });
      }
  }
});

var loader = require ("MetadataLoader");

// loader.fetchMovie ({ title: "Back to the future", year: "1985"}) (function (x) { console.log(x); }) ()

// loader.fetchTVShow ({ title: "Columbo", year: "1971"}) (function (x) { console.log(x); }) ()



// loader.fetchMovies (function (x) { console.log(x); }) ()

// loader.fetchMoviesDetails (function (x) { console.log(x); })

// loader.fetchTVShowsDetails (function (x) { console.log(x); })

// loader.fetchTVShowEpisode ({ series:"Columbo", season:"1", episode:"1", source:"http://url/file.mp4" })  (function (x) { console.log(x); })

//loader.getState ("http://192.168.0.24/MyMoviesCatalog.json") (function (x) { console.log(x.tvshows[1].seasons[0].episodes[2]); })


describe ('MetadataLoader tests', function(){

    it ('should return my list', function(){
      var result = {};
      loader.getMyList (testUrl) (function (x) { result = x; })
      assert.deepEqual(testMyList, result);
    })

    it ('should replace space with plus', function() {
      assert.equal("Back+to+the+future", loader.replaceSpaceWithPlus("Back to the future"));
    })

    it ('should fetch movie details', function() {
      var result = {};
      loader.fetchMovie({ title: "Back to the future", year: "1985", source: "http://localhost/BackToTheFuture.mp4"})(function (x){
        result = x;
      });
      assert.deepEqual({
        title: "Back to the future (The Movie)",
        year: "1985",
        source: "http://localhost/BackToTheFuture.mp4"
      }, result);
    })

    it ('should fetch tv show', function() {
      var result = {};
      loader.fetchTVShow({ title: "Columbo", year: "1971"})(function (x){
        result = x;
      });
      assert.deepEqual({
        title: "Columbo (The Series)",
        year: "1971",
        season: []
      }, result);
    })

    it ('should fetch tv show episode', function (){
      var result = {};
      loader.fetchTVShowEpisode({
        series: "Columbo",
        season: "2",
        episode: "3",
        source: "http://localhost/Columbo/TheMostCrucialGame.mp4"
      })(function (x){ result = x; });
      assert.deepEqual({
        title: "The most cruicial game",
        released: "05 Nov 1972",
        season: "2",
        episode: "3",
        source: "http://localhost/Columbo/TheMostCrucialGame.mp4"
      }, result);
    })

    it ('should fetch movies details', function (){
      var result = {};
      loader.fetchMoviesDetails([
        { title: "Back to the future", year: "1985", source: "http://localhost/BackToTheFuture.mp4" },
        { title: "The Bourne Supremacy", year: "2004", source: "http://localhost/TheBourneSupremacy.mp4" },
      ])(function (x) { result = x; })
      assert.equal(2, result.length);
      assert.deepEqual({
        title: "Back to the future (The Movie)",
        year: "1985",
        source: "http://localhost/BackToTheFuture.mp4"
      }, result[0]);
      assert.deepEqual({
        title: "The Bourne Supremacy (The Movie)",
        year: "2004",
        source: "http://localhost/TheBourneSupremacy.mp4"
      }, result[1]);
    })

})
