import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letterboxd_clone/constants.dart';
import 'package:http/http.dart' as http;
import 'package:letterboxd_clone/models/castcrew.dart';
import 'package:letterboxd_clone/models/movie.dart';
import 'package:letterboxd_clone/models/movielist.dart';
import 'package:letterboxd_clone/models/videos.dart';
import 'package:letterboxd_clone/utils/Firebase.dart';

Future<List<Result?>> movieSearch(String x) async {
  final client = http.Client();
  final uri = Uri.parse('https://api.themoviedb.org/3/movie/$x?api_key=$API_KEY&language=en-US&page=1');
  final response = await client.get(uri);
  List<Result?> res = [];
  if(response.statusCode == 200)
    {
      res = welcomeFromJson(response.body).results;
    }
  return res;
}

Future<Movie?> getMovie(int movieId) async {
//https://api.themoviedb.org/3/movie/{movie_id}?api_key=<<api_key>>&language=en-US
  final client = http.Client();
  final uri = Uri.parse('https://api.themoviedb.org/3/movie/${movieId.toString()}?api_key=$API_KEY&language=en-US&page=1');
  final response = await client.get(uri);
  Movie res;
  res = welcomeFromJsonMovie(response.body);
  return res;
}

Future<List<Result?>> movieSearchFrThisTime(String x) async {
  final client = http.Client();
  final uri = Uri.parse('https://api.themoviedb.org/3/search/movie?api_key=$API_KEY&language=en-US&page=1&include_adult=false&query=$x');
  final response = await client.get(uri);
  List<Result?> res = [];
  if(response.statusCode == 200)
  {
    res = welcomeFromJson(response.body).results;
  }
  return res;
}

Future<WelcomeCast> getCredits(int movieId) async{
  final client = http.Client();
  final uri = Uri.parse('https://api.themoviedb.org/3/movie/$movieId/credits?api_key=$API_KEY');
  final response = await client.get(uri);
  var res;
  if(response.statusCode == 200){
    res = welcomeFromJsoncast(response.body);
  }
  return res;
}

Future<WelcomeVideos?> getTrailer(int movieId) async{
  final client = http.Client();
  final uri = Uri.parse("http://api.themoviedb.org/3/movie/$movieId/videos?api_key=$API_KEY");
  final response = await client.get(uri);
  WelcomeVideos? x;
  if(response.statusCode == 200){
    x = welcomeFromJsonVideos(response.body);
  }
  return x;
}

Future<QuerySnapshot<Object?>> getMoviesFromFirebase() async {
  CollectionReference movies = firestore.collection('movies');
  QuerySnapshot querySnapshot = await movies.get();
  return querySnapshot;
}

Future<Map<String, dynamic>> getUserMovies () async {
  var ref = firestore.collection(auth.currentUser!.uid).doc("movies");
  var docSnap = await ref.get();
  var liked = docSnap.data() as Map<String, dynamic>;
  return liked;
}