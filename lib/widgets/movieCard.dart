import 'package:flutter/material.dart';
import 'package:letterboxd_clone/methods/methods.dart';
import 'package:letterboxd_clone/models/movie.dart';
import 'package:letterboxd_clone/screens/movie_screen.dart';
import 'package:letterboxd_clone/utils/colors.dart';

Widget MovieCard(int movieId, BuildContext context) {
  return Container(
    margin: const EdgeInsets.all(10),
    child: FutureBuilder(future: getMovie(movieId) ,builder: (context, snap){
      if(snap.connectionState == ConnectionState.waiting){
        return const Center(child: CircularProgressIndicator(),);
      }
      else if(snap.connectionState == ConnectionState.done){
        if(snap.hasData){
          Movie? movie = snap.data;
          return ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                  backgroundColor: Colors.transparent,
                  elevation: 5.0,
                  side: const BorderSide(color: trailerButtonColor, width: 1)
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MovieScreen(movie: movie)));
              },
              child: Card(
                margin: const EdgeInsets.all(0),
                elevation: 2,
                child: Hero(
                  tag: "${movie!.posterPath}",
                  child: Image(
                    alignment: Alignment.topRight,
                    fit: BoxFit.fitWidth,
                    image: NetworkImage(
                        'https://image.tmdb.org/t/p/w500${movie.posterPath}'),
                  ),
                ),
              )
          );
        }
      }
      return const Center(child: (Text("Error!")));
    })
  );
}
