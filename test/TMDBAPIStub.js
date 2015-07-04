var mock = require ('mock-require');

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
          if (url == "http://api.themoviedb.org/3/search/movie?api_key=1111111111111111&query=Back%20to%20the%20future&year=1985") 
            return cb({
              page:1,
              results:[
              { adult:false,
                backdrop_path:"/x4N74cycZvKu5k3KDERJay4ajR3.jpg",
                genre_ids:[12,35],
                id:105,
                original_language:"en",
                original_title:"Back to the future",
                overview:"Eighties teenager Marty McFly is accidentally sent back in time to 1955, inadvertently disrupting his parents' first meeting and attracting his mother's romantic interest. Marty must repair the damage to history by rekindling his parents' romance and - with the help of his eccentric inventor friend Doc Brown - return to 1985.",
                release_date:"1985",
                poster_path:"/pTpxQB1N0waaSc3OSn0e9oc8kx9.jpg",
                popularity:5.055294,
                title:"Back to the future (The Movie)",
                video:false,
                vote_average:7.6,
                vote_count:2337
              }], total_pages:1, total_results:2});

          if (url == "http://api.themoviedb.org/3/search/movie?api_key=1111111111111111&query=The%20Bourne%20Supremacy&year=2004") 
            return cb({
              page:1,
              results:[
              { adult:false,
                backdrop_path:"/x4N74cycZvKu5k3KDERJay4ajR3.jpg",
                genre_ids:[12,35],
                id:653,
                original_language:"en",
                original_title:"The Bourne Supremacy",
                overview:"The story of Jason Bourne again",
                release_date:"2004",
                poster_path:"/pTpxQB1N0waaSc3OSn0e9oc8kx9.jpg",
                popularity:5.055294,
                title:"The Bourne Supremacy (The Movie)",
                video:false,
                vote_average:7.6,
                vote_count:2337
              }], total_pages:1, total_results:2});

          if (url == "http://api.themoviedb.org/3/search/tv?api_key=1111111111111111&query=Columbo&year=1971")
            return cb({
              page:1,
              results:[
              { backdrop_path:"/39lDB3EStZjXJm7gZkhTkCjP2IE.jpg",
               first_air_date:"1971",
               genre_ids:[80],
               id:873,
               original_language:"en",
               original_name:"Columbo",
               overview:"Columbo is an American detective mystery television film series, starring Peter Falk as Columbo, a homicide detective with the Los Angeles Police Department. The character and television show were created by William Link and Richard Levinson. The show popularized the inverted detective story format. Almost every episode began by showing the commission of the crime and its perpetrator. The series has no \"whodunit\" element. The plot mainly revolves around how the perpetrator, whose identity is already known to the audience, will finally be caught and exposed.\n\nThe title character is a friendly, verbose, disheveled-looking police detective who is consistently underestimated by his suspects. Most people are initially reassured and distracted by his circumstantial speech, then increasingly irritated by his pestering behavior. Despite his unprepossessing appearance and apparent absentmindedness, he shrewdly solves all of his cases and secures all evidence needed for indictment. His formidable eye for detail and meticulously dedicated approach, though apparent to the viewer, often become clear to the killer only late in the storyline.\n\nThe episodes are all movie-length, between 73 and 100 minutes long. The series was once broadcast on over 80 networks, spanning 44 countries. In 1997, \"Murder by the Book\" was ranked No. 16 on TV Guide's 100 Greatest Episodes of All Time. and in 1999, the magazine ranked Lt. Columbo No. 7 on its 50 Greatest TV Characters of All Time list. In 2012, the program was chosen as the third best cop or legal show on Best in TV: The Greatest TV Shows of Our Time. In 2013 TV Guide included it in its list of The 60 Greatest Dramas of All Time. In 2013, Writers Guild of America ranked it No. 57 in the list of 101 Best Written TV Series.",
               origin_country:["US"],
               poster_path:"/1tUvH4fn8ZDXUHGgYlgxCueOCXi.jpg",
               popularity:2.239149,
               name:"Columbo (The Series)",
               vote_average:8.5,
               vote_count:13
             }],total_pages:1,total_results:3});

          if (url == "http://api.themoviedb.org/3/tv/873/season/2/episode/3?api_key=1111111111111111")
            return cb({
              air_date:"05 Nov 1972",
              crew: [{ name: "Jeremy Kagan", job: "Director" }],
              guest_stars: [{ name: "James Gregory" }, { name: "Dean Jagger" }],
              episode_number:3,
              name:"The most crucial game",
              overview:"One member of a mystery-writing-team decides to kill his more talented partner when the better writer decides to go solo.",
              id:48577,
              production_code:null,
              season_number:2,
              still_path:"/ulep93cZ0yOChg7bRJROpUzcQGF.jpg",
              vote_average:0.0,
              vote_count:0});

          if (url == "http://api.themoviedb.org/3/search/tv?api_key=1111111111111111&query=Star%20Trek%20The%20Next%20Generation&year=1987")
            return cb({
              page:1,
              results:[
              { backdrop_path:"/39lDB3EStZjXJm7gZkhTkCjP2IE.jpg",
               first_air_date:"1987",
               genre_ids:[80],
               id:234,
               original_language:"en",
               original_name:"Star Trek The Next Generation",
               overview:"",
               origin_country:["US"],
               poster_path:"/1tUvH4fn8ZDXUHGgYlgxCueOCXi.jpg",
               popularity:2.239149,
               name:"Star Trek The Next Generation (ST:TNG)",
               vote_average:8.5,
               vote_count:13
             }],total_pages:1,total_results:3});

          if (url == "http://api.themoviedb.org/3/tv/234/season/7/episode/3?api_key=1111111111111111")
            return cb({
              air_date:"02 Oct 1993",
              crew:[],
              episode_number:3,
              guest_stars:[],
              name:"Interface",
              overview:"",
              id:48577,
              production_code:null,
              season_number:7,
              still_path:"/ulep93cZ0yOChg7bRJROpUzcQGF.jpg",
              vote_average:0.0,
              vote_count:0});

          if (url == "http://api.themoviedb.org/3/movie/105?api_key=1111111111111111&append_to_response=credits,releases")
            return cb({
              id: 105,
              runtime:124,
              credits: {
                cast: [{name:"Michael J. Fox"}],
                crew: [{name:"Robert Zemeckis", job:"Director"}, {name:"Robert Zemeckis", job:"Writer"}]
              },
              releases: {
                countries: [{ certification: "PG" },{ certification: "T" }]
              }
            });

          if (url == "http://api.themoviedb.org/3/movie/653?api_key=1111111111111111&append_to_response=credits,releases")
            return cb({
              id: 653,
              runtime:126,
              credits: {
                cast: [{name:"Matt Damon"}],
                crew: [{name:"Paul Greengrass", job:"Director"}]
              },
              releases: {
                countries: [{ certification: "PG" },{ certification: "T" }]
              }
            });

          if (url == "http://api.themoviedb.org/3/genre/movie/list?api_key=1111111111111111")
            return cb({
              genres: [
                {
                  id: 28,
                  name: "Action"
                },
                {
                  id: 12,
                  name: "Adventure"
                },
                {
                  id: 16,
                  name: "Animation"
                },
                {
                  id: 35,
                  name: "Comedy"
                },
                {
                  id: 80,
                  name: "Crime"
                }]
            });

          if (url == "http://api.themoviedb.org/3/tv/873?api_key=1111111111111111&append_to_response=credits,content_ratings")
            return cb({
              id:873,
              popularity: 1.993303,
              first_air_date: "1968-02-20",
              episode_run_time: [120],
              genres: [{ id: 80, name: "Crime" }],
              credits: {
                cast: [{
                  character: "Columbo",
                  name: "Peter Falk"
                }]
              }
            });

          if (url == "http://api.themoviedb.org/3/tv/234?api_key=1111111111111111&append_to_response=credits,content_ratings")
            return cb({
              id:234,
              popularity: 1.992,
              first_air_date: "1982-02-20",
              episode_run_time: [60],
              genres: [{ id: 80, name: "SciFi" }],
              credits: {
                cast: [{
                  character: "Picard",
                  name: "Patrick Stewart"
                }]
              }
            });
      }
  }
});

module.exports = { testUrl : testUrl, testMyList: testMyList };