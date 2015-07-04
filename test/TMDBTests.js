var assert = require("assert");

var loader = require ("TMDBMetadataLoader");

var stub = require('./TMDBAPIStub.js');
var testUrl = stub.testUrl;
var testMyList = stub.testMyList;

describe ('TMDB MetadataLoader tests', function(){

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
        movieId: 105,
        title: "Back to the future (The Movie)",
        year: "1985",
        genre: "",
        popularity: 5.055294,
        genresIds: [12, 35],
        source: "http://localhost/BackToTheFuture.mp4",
        director: "Robert Zemeckis",
        writer: "Robert Zemeckis",
        actors: "Michael J. Fox",
        runtime: 124,
        release: "1985",
        rated: "PG",
        poster: "http://image.tmdb.org/t/p/w500//pTpxQB1N0waaSc3OSn0e9oc8kx9.jpg",
        plot: "Eighties teenager Marty McFly is accidentally sent back in time to 1955, inadvertently disrupting his parents' first meeting and attracting his mother's romantic interest. Marty must repair the damage to history by rekindling his parents' romance and - with the help of his eccentric inventor friend Doc Brown - return to 1985."
      }, result);
    })

     it ('should fetch movie crew', function() {
      var result = {};
      loader.fetchMovieExtraInfo(105)(function (x){
        result = x;
      });
      assert.deepEqual({
        movieId: 105,
        director: "Robert Zemeckis",
        writer: "Robert Zemeckis",
        actors: "Michael J. Fox",
        runtime:124,
        rated: "PG"
      }, result);
    })

    it ('should fetch tv show', function() {
      var result = {};
      loader.fetchTVShow({ title: "Columbo", year: "1971"})(function (x){
        result = x;
      });
      assert.deepEqual({
        seriesId: 873,
        title: "Columbo (The Series)",
        year: "1971",
        actors: "Peter Falk",
        popularity: 1.993303,
        runtime: 120,
        genre:"Crime",
        poster: "http://image.tmdb.org/t/p/w500//1tUvH4fn8ZDXUHGgYlgxCueOCXi.jpg",
        plot:"Columbo is an American detective mystery television film series, starring Peter Falk as Columbo, a homicide detective with the Los Angeles Police Department. The character and television show were created by William Link and Richard Levinson. The show popularized the inverted detective story format. Almost every episode began by showing the commission of the crime and its perpetrator. The series has no \"whodunit\" element. The plot mainly revolves around how the perpetrator, whose identity is already known to the audience, will finally be caught and exposed.\n\nThe title character is a friendly, verbose, disheveled-looking police detective who is consistently underestimated by his suspects. Most people are initially reassured and distracted by his circumstantial speech, then increasingly irritated by his pestering behavior. Despite his unprepossessing appearance and apparent absentmindedness, he shrewdly solves all of his cases and secures all evidence needed for indictment. His formidable eye for detail and meticulously dedicated approach, though apparent to the viewer, often become clear to the killer only late in the storyline.\n\nThe episodes are all movie-length, between 73 and 100 minutes long. The series was once broadcast on over 80 networks, spanning 44 countries. In 1997, \"Murder by the Book\" was ranked No. 16 on TV Guide's 100 Greatest Episodes of All Time. and in 1999, the magazine ranked Lt. Columbo No. 7 on its 50 Greatest TV Characters of All Time list. In 2012, the program was chosen as the third best cop or legal show on Best in TV: The Greatest TV Shows of Our Time. In 2013 TV Guide included it in its list of The 60 Greatest Dramas of All Time. In 2013, Writers Guild of America ranked it No. 57 in the list of 101 Best Written TV Series.",
        seasons: []
      }, result);
    })

   it ('should fetch tv show extra info', function() {
      var result = {};
      loader.fetchTVShowExtraInfo(873)(function (x){
        result = x;
      });
      assert.deepEqual({
        tvshowId: 873,
        actors: "Peter Falk",
        runtime:120,
        popularity: 1.993303,
        genre: "Crime"
      }, result);
    })

    it ('should fetch tv show episode', function (){
      var result = {};
      loader.fetchTVShowEpisode({
        series: "Columbo",
        seriesId: 873,
        season: "2",
        episode: "3",
        source: "http://localhost/Columbo/TheMostCrucialGame.mp4"
      })(function (x){ result = x; });
      assert.deepEqual({
        title: "The most crucial game",
        release: "05 Nov 1972",
        poster: "http://image.tmdb.org/t/p/w500//ulep93cZ0yOChg7bRJROpUzcQGF.jpg",
        season: "2",
        episode: "3",
        actors: "James Gregory,Dean Jagger",
        director: "Jeremy Kagan",
        writer:"",
        plot: "One member of a mystery-writing-team decides to kill his more talented partner when the better writer decides to go solo.",
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
        movieId: 105,
        title: "Back to the future (The Movie)",
        genre: "",
        genresIds: [12, 35],
        year: "1985",
        popularity: 5.055294,
        source: "http://localhost/BackToTheFuture.mp4",
        director: "Robert Zemeckis",
        writer: "Robert Zemeckis",
        actors: "Michael J. Fox",
        rated: "PG",
        runtime: 124,
        release: "1985",
        poster: "http://image.tmdb.org/t/p/w500//pTpxQB1N0waaSc3OSn0e9oc8kx9.jpg",
        plot: "Eighties teenager Marty McFly is accidentally sent back in time to 1955, inadvertently disrupting his parents' first meeting and attracting his mother's romantic interest. Marty must repair the damage to history by rekindling his parents' romance and - with the help of his eccentric inventor friend Doc Brown - return to 1985."
      }, result[0]);
      assert.deepEqual({
        movieId: 653,
        title: "The Bourne Supremacy (The Movie)",
        genre: "",
        genresIds: [12, 35],
        year: "2004",
        popularity: 5.055294,
        source: "http://localhost/TheBourneSupremacy.mp4",
        director: "Paul Greengrass",
        writer:"",
        actors: "Matt Damon",
        rated: "PG",
        runtime: 126,
        release: "2004",
        poster: "http://image.tmdb.org/t/p/w500//pTpxQB1N0waaSc3OSn0e9oc8kx9.jpg",
        plot: "The story of Jason Bourne again"
      }, result[1]);
    })

    it ('should fetch tv shows seasons details', function(){
      var result = {};
      loader.fetchTVShowsSeasonsDetails({
          seriesId: 873,
          seasons: [{ season: "Season 2", episodes: [{
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
              plot: "One member of a mystery-writing-team decides to kill his more talented partner when the better writer decides to go solo.",
              season: "2",
              episode: "3",
              actors: "James Gregory,Dean Jagger",
              director: "Jeremy Kagan",
              writer:"",
              release: "05 Nov 1972",
              poster: "http://image.tmdb.org/t/p/w500//ulep93cZ0yOChg7bRJROpUzcQGF.jpg",
              source: "http://localhost/Columbo/TheMostCrucialGame.mp4"
            }]
          }
        ], result);
    })

    it ('should fetch tv shows details', function(){
      var result = {};
      loader.fetchTVShowsDetails([
        { title: "Columbo", year: "1971", 
        seasons: [{
          season: "Season 2",
          episodes: [{
              series: "Columbo",
              season: "2",
              episode: "3",
              source: "http://localhost/Columbo/TheMostCrucialGame.mp4"
            }]
        }]},
        { title: "Star Trek The Next Generation", year: "1987", 
          seasons: [{
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
          seriesId: 873,
          title:"Columbo (The Series)",
          year:"1971",
          actors: "Peter Falk",
          popularity: 1.993303,
          runtime: 120,
          genre:"Crime",
          poster: "http://image.tmdb.org/t/p/w500//1tUvH4fn8ZDXUHGgYlgxCueOCXi.jpg",
          plot:"Columbo is an American detective mystery television film series, starring Peter Falk as Columbo, a homicide detective with the Los Angeles Police Department. The character and television show were created by William Link and Richard Levinson. The show popularized the inverted detective story format. Almost every episode began by showing the commission of the crime and its perpetrator. The series has no \"whodunit\" element. The plot mainly revolves around how the perpetrator, whose identity is already known to the audience, will finally be caught and exposed.\n\nThe title character is a friendly, verbose, disheveled-looking police detective who is consistently underestimated by his suspects. Most people are initially reassured and distracted by his circumstantial speech, then increasingly irritated by his pestering behavior. Despite his unprepossessing appearance and apparent absentmindedness, he shrewdly solves all of his cases and secures all evidence needed for indictment. His formidable eye for detail and meticulously dedicated approach, though apparent to the viewer, often become clear to the killer only late in the storyline.\n\nThe episodes are all movie-length, between 73 and 100 minutes long. The series was once broadcast on over 80 networks, spanning 44 countries. In 1997, \"Murder by the Book\" was ranked No. 16 on TV Guide's 100 Greatest Episodes of All Time. and in 1999, the magazine ranked Lt. Columbo No. 7 on its 50 Greatest TV Characters of All Time list. In 2012, the program was chosen as the third best cop or legal show on Best in TV: The Greatest TV Shows of Our Time. In 2013 TV Guide included it in its list of The 60 Greatest Dramas of All Time. In 2013, Writers Guild of America ranked it No. 57 in the list of 101 Best Written TV Series.",
          seasons:[
            { season:"Season 2",
              episodes:[
                {  title:"The most crucial game",
                   plot: "One member of a mystery-writing-team decides to kill his more talented partner when the better writer decides to go solo.",
                   release:"05 Nov 1972",
                   poster: "http://image.tmdb.org/t/p/w500//ulep93cZ0yOChg7bRJROpUzcQGF.jpg",
                   season:"2",
                   episode:"3",
                   actors: "James Gregory,Dean Jagger",
                   director: "Jeremy Kagan",
                   writer:"",
                   source:"http://localhost/Columbo/TheMostCrucialGame.mp4"
                }
              ]
            }
          ]
        },
        { 
          seriesId: 234,
          title:"Star Trek The Next Generation (ST:TNG)",
          poster: "http://image.tmdb.org/t/p/w500//1tUvH4fn8ZDXUHGgYlgxCueOCXi.jpg",
          year:"1987",
          actors: "Patrick Stewart",
          popularity: 1.992,
          runtime: 60,
          genre: "SciFi",
          plot:"",
          seasons:[
            { season:"Season 7",
              episodes:[
                { title:"Interface",
                  plot: "",
                  release:"02 Oct 1993",
                  poster: "http://image.tmdb.org/t/p/w500//ulep93cZ0yOChg7bRJROpUzcQGF.jpg",
                  season:"7",
                  episode:"3",
                  director: "",
                  writer: "",
                  actors: "",
                  source:"http://localhost/STTNG/Interface.mp4"
                }
              ]
            }
          ]
        }], result);
    })

   it ('should get genre list', function() {
      var Data_Map = require("Data.Map");
      var result = {};
      loader.fetchGenreList(function(x){ result = x; })
      assert.deepEqual(
      [
        {
          value0: 12,
          value1: "Adventure"
        },
        {
          value0: 16,
          value1: "Animation"
        },
        {
          value0: 28,
          value1: "Action"
        },
        {
          value0: 35,
          value1: "Comedy"
        },
        {
          value0: 80,
          value1: "Crime"
        }
      ], Data_Map.toList(result));
   })

   it ('should get state', function(){
      var result = {};
      loader.getState(testUrl)(function(x){ result = x; })

      assert.deepEqual({
        movies: [
          { movieId:105, 
            title:"Back to the future (The Movie)",
            year:"1985",
            genre: "Adventure, Comedy",
            genresIds: [12, 35],
            source:"http://localhost/BackToTheFuture.mp4",
            director:"Robert Zemeckis",
            writer:"Robert Zemeckis",
            actors: "Michael J. Fox",
            runtime: 124,
            release: "1985",
            rated: "PG",
            popularity: 5.055294,
            poster: "http://image.tmdb.org/t/p/w500//pTpxQB1N0waaSc3OSn0e9oc8kx9.jpg",
            plot: "Eighties teenager Marty McFly is accidentally sent back in time to 1955, inadvertently disrupting his parents' first meeting and attracting his mother's romantic interest. Marty must repair the damage to history by rekindling his parents' romance and - with the help of his eccentric inventor friend Doc Brown - return to 1985."
          },
          { movieId:653, 
            title:"The Bourne Supremacy (The Movie)",
            year:"2004",
            genre: "Adventure, Comedy",
            genresIds: [12, 35],
            source:"http://localhost/TheBourneSupremacy.mp4",
            director: "Paul Greengrass",
            writer:"",
            actors:"Matt Damon",
            runtime: 126,
            release: "2004",
            rated: "PG",
            popularity: 5.055294,
            poster: "http://image.tmdb.org/t/p/w500//pTpxQB1N0waaSc3OSn0e9oc8kx9.jpg",
            plot: "The story of Jason Bourne again"
          }],
        tvshows:[
        { seriesId: 873,
          title: 'Columbo (The Series)',
          year: '1971',
          actors: "Peter Falk",
          genre: "Crime",
          popularity: 1.993303,
          runtime: 120,
          poster: "http://image.tmdb.org/t/p/w500//1tUvH4fn8ZDXUHGgYlgxCueOCXi.jpg",
          plot:"Columbo is an American detective mystery television film series, starring Peter Falk as Columbo, a homicide detective with the Los Angeles Police Department. The character and television show were created by William Link and Richard Levinson. The show popularized the inverted detective story format. Almost every episode began by showing the commission of the crime and its perpetrator. The series has no \"whodunit\" element. The plot mainly revolves around how the perpetrator, whose identity is already known to the audience, will finally be caught and exposed.\n\nThe title character is a friendly, verbose, disheveled-looking police detective who is consistently underestimated by his suspects. Most people are initially reassured and distracted by his circumstantial speech, then increasingly irritated by his pestering behavior. Despite his unprepossessing appearance and apparent absentmindedness, he shrewdly solves all of his cases and secures all evidence needed for indictment. His formidable eye for detail and meticulously dedicated approach, though apparent to the viewer, often become clear to the killer only late in the storyline.\n\nThe episodes are all movie-length, between 73 and 100 minutes long. The series was once broadcast on over 80 networks, spanning 44 countries. In 1997, \"Murder by the Book\" was ranked No. 16 on TV Guide's 100 Greatest Episodes of All Time. and in 1999, the magazine ranked Lt. Columbo No. 7 on its 50 Greatest TV Characters of All Time list. In 2012, the program was chosen as the third best cop or legal show on Best in TV: The Greatest TV Shows of Our Time. In 2013 TV Guide included it in its list of The 60 Greatest Dramas of All Time. In 2013, Writers Guild of America ranked it No. 57 in the list of 101 Best Written TV Series.",
          seasons: [ { season: 'Season 2',
                       episodes: [{
                         title: "The most crucial game",
                         plot: "One member of a mystery-writing-team decides to kill his more talented partner when the better writer decides to go solo.",
                         release: "05 Nov 1972",
                         poster: "http://image.tmdb.org/t/p/w500//ulep93cZ0yOChg7bRJROpUzcQGF.jpg",
                         season: "2",
                         episode: "3",
                         director: "",
                         actors: "James Gregory,Dean Jagger",
                         director: "Jeremy Kagan",
                         writer:"",
                         source: "http://localhost/Columbo/TheMostCrucialGame.mp4"
                       }] }]
        },
        { seriesId: 234,
          title: 'Star Trek The Next Generation (ST:TNG)',
          year: '1987',
          poster: "http://image.tmdb.org/t/p/w500//1tUvH4fn8ZDXUHGgYlgxCueOCXi.jpg",
          actors: "Patrick Stewart",
          genre:"SciFi",
          popularity: 1.992,
          runtime: 60,
          plot:"",
          seasons: [ { season: 'Season 7',
                       episodes: [{
                         title: "Interface",
                         plot:"",
                         release: "02 Oct 1993",
                         poster: "http://image.tmdb.org/t/p/w500//ulep93cZ0yOChg7bRJROpUzcQGF.jpg",
                         season: "7",
                         episode: "3",
                         director: "",
                         writer: "",
                         actors: "",
                         source:"http://localhost/STTNG/Interface.mp4"
                       }] }]
        }]
      }, result);
    })
})