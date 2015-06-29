
var mock = require ('mock-require');
var assert = require("assert");

var testUrl = "http://192.168.0.24/MyMoviesCatalog.json";
var testMyList = {
    movies: [
    {
      source: "http://localhost/BackToTheFuture.mp4",
      title: "Back to the future",
      year: "1985"
    },
    {
      source: "http://localhost/TheBourneSupremacy.mp4",
      title: "The Bourne Supremacy",
      year: "2004"
    }],
    tvshows: [
      { title: "Columbo", year: "1971", seasons: [{
        season: "Season 2",
        episodes: [{
            series: "Columbo",
            season: "2",
            episode: "3",
            source: "http://localhost/Columbo/TheMostCrucialGame.mp4"
          }]
      }]},
      { title: "Star Trek The Next Generation", year: "1987", seasons: [{
        season: "Season 7",
        episodes: [{
            series: "Star Trek The Next Generation",
            season: "7",
            episode: "3",
            source: "http://localhost/STTNG/Interface.mp4"
          }]
      }]}
    ]
};

mock('../output/HttpClient', { fetch: function(url) {
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
              year: '1971'
            });
          if (url == "http://www.omdbapi.com/?t=Columbo&Season=2&Episode=3&plot=full&type=series&r=json")
            return cb({
              title: "The most crucial game",
              released: "05 Nov 1972",
              season: "2",
              episode: "3"
            });
            if (url == "http://www.omdbapi.com/?t=Star+Trek+The+Next+Generation&y=1987&plot=full&type=series&r=json")
              return cb({
                title: 'Star Trek The Next Generation (ST:TNG)',
                year: '1987'
              });
            if (url == "http://www.omdbapi.com/?t=Star+Trek+The+Next+Generation&Season=7&Episode=3&plot=full&type=series&r=json")
              return cb({
                title: "Interface",
                released: "02 Oct 1993",
                season: "7",
                episode: "3"
              });
      }
  }
});

var loader = require ("MetadataLoader");

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
        year: "1971"
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
        title: "The most crucial game",
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

    it ('should fetch tv shows seasons details', function(){
      var result = {};
      loader.fetchTVShowsSeasonsDetails({
          seasons: [{season: "Season 2", episodes: [{
              series: "Columbo",
              season: "2",
              episode: "3",
              source: "http://localhost/Columbo/TheMostCrucialGame.mp4"
            }]
          }]
        })(function (x) { result = x; })
        assert.deepEqual([
          { season: "Season 2", episodes: [{
              title: "The most crucial game",
              season: "2",
              episode: "3",
              released: "05 Nov 1972",
              source: "http://localhost/Columbo/TheMostCrucialGame.mp4"
            }]
          }
        ], result);
    })

    it ('should fetch tv shows details', function(){
      var result = {};
      loader.fetchTVShowsDetails([
        { title: "Columbo", year: "1971", seasons: [{
          season: "Season 2",
          episodes: [{
              series: "Columbo",
              season: "2",
              episode: "3",
              source: "http://localhost/Columbo/TheMostCrucialGame.mp4"
            }]
        }]},
        { title: "Star Trek The Next Generation", year: "1987", seasons: [{
          season: "Season 7",
          episodes: [{
              series: "Star Trek The Next Generation",
              season: "7",
              episode: "3",
              source: "http://localhost/STTNG/Interface.mp4"
            }]
        }]}
      ])(function(x) { result = x; })
      assert.equal(2, result.length);
      assert.deepEqual([
        {
          title:"Columbo (The Series)",
          year:"1971",
          seasons:[
            { season:"Season 2",
              episodes:[
                { title:"The most crucial game",
                 released:"05 Nov 1972",
                 season:"2",
                 episode:"3",
                 source:"http://localhost/Columbo/TheMostCrucialGame.mp4"
                }
              ]
            }
          ]
        },
        { title:"Star Trek The Next Generation (ST:TNG)",
          year:"1987",
          seasons:[
            { season:"Season 7",
              episodes:[
                { title:"Interface",
                  released:"02 Oct 1993",
                  season:"7",
                  episode:"3",
                  source:"http://localhost/STTNG/Interface.mp4"
                }
              ]
            }
          ]
        }], result);
    })

    it ('should get state', function(){
      var result = {};
      loader.getState(testUrl)(function(x){ result = x; })

      assert.deepEqual({
        movies: [
          { title:"Back to the future (The Movie)",year:"1985",source:"http://localhost/BackToTheFuture.mp4"},
          { title:"The Bourne Supremacy (The Movie)",year:"2004",source:"http://localhost/TheBourneSupremacy.mp4"}],
        tvshows:[
        { title: 'Columbo (The Series)',
          year: '1971',
          seasons: [ { season: 'Season 2',
                       episodes: [{
                         title: "The most crucial game",
                         released: "05 Nov 1972",
                         season: "2",
                         episode: "3",
                         source: "http://localhost/Columbo/TheMostCrucialGame.mp4"
                       }] }]
        },
        { title: 'Star Trek The Next Generation (ST:TNG)',
          year: '1987',
          seasons: [ { season: 'Season 7',
                       episodes: [{
                         title: "Interface",
                         released: "02 Oct 1993",
                         season: "7",
                         episode: "3",
                         source:"http://localhost/STTNG/Interface.mp4"
                       }] }]
        }]
      }, result);
    })

})
