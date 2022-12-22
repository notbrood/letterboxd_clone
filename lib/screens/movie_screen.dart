import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:letterboxd_clone/methods/methods.dart';
import 'package:letterboxd_clone/models/movie.dart';
import 'package:letterboxd_clone/models/videos.dart';
import 'package:letterboxd_clone/utils/Firebase.dart';
import 'package:letterboxd_clone/utils/colors.dart';
import 'package:letterboxd_clone/widgets/movieCard.dart';
import 'package:oktoast/oktoast.dart';
import 'package:stretchy_header/stretchy_header.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieScreen extends StatefulWidget {
  Movie movie;
  MovieScreen({Key? key, required this.movie}) : super(key: key);
  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  late Movie movie;
  late bool _hasWatched;
  late bool _hasLiked;
  late bool _inWatchlist;
  @override
  void initState() {
    movie = widget.movie;
    _hasWatched = watchedMoviesIds.contains(movie.id);
    _hasLiked = likedMoviesIds.contains(movie.id);
    _inWatchlist = watchListIds.contains(movie.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getMoviesFromFirebase(),
      builder: (cptext, smap) {
        if (smap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: navBarColor,
            ),
          );
        } else if (smap.connectionState == ConnectionState.done) {
          if (smap.hasError) {
            return Center(
              child: Text(smap.error.toString()),
            );
          } else if (smap.hasData) {
            return FutureBuilder(
                future: getCredits(movie.id!),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          '${snapshot.error} occurred',
                          style: const TextStyle(fontSize: 18),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      final data = snapshot.data;
                      String? director;
                      for (int i = 0; i < data!.crew.length; i++) {
                        if (data.crew[i].job == "Director") {
                          director = data.crew[i].name;
                        }
                      }
                      return FutureBuilder(
                          future: getTrailer(movie.id!),
                          builder: (ctxx, snap) {
                            if (snap.connectionState == ConnectionState.done) {
                              if (snap.hasError) {
                                return Center(
                                  child: Text(
                                    '${snapshot.error} occurred',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                );
                              } else if (snap.hasData) {
                                String? trailerLink;
                                for (int i = 0;
                                    i < snap.data!.results!.length;
                                    i++) {
                                  if (snap.data!.results![i].type ==
                                          Type.TRAILER &&
                                      snap.data!.results![i].official == true) {
                                    trailerLink = (snap.data!.results![i].key);
                                  }
                                }
                                return Scaffold(
                                  backgroundColor: backgroundColor,
                                  body: Stack(
                                    children: [
                                      StretchyHeader.singleChild(
                                        displacement: 20,
                                        headerData: HeaderData(
                                          blurContent: false,
                                          headerHeight: 250,
                                          header: Container(
                                            foregroundDecoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin:
                                                    const Alignment(1.0, 1.0),
                                                colors: [
                                                  backgroundColor
                                                      .withOpacity(0.95),
                                                  backgroundColor
                                                      .withOpacity(0.05)
                                                ],
                                              ),
                                            ),
                                            child: Image.network(
                                              movie.backdropPath != null
                                                  ? "https://image.tmdb.org/t/p/w500${movie.backdropPath}"
                                                  : "https://image.tmdb.org/t/p/w500${movie.posterPath}",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 5),
                                              width: 205,
                                              child: Text(
                                                movie.title!,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                  fontSize: 21,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15),
                                              width: 205,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    movie.releaseDate!.year
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        letterSpacing: 2,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  const Text(" ∙ "),
                                                  const Text(
                                                    "DIRECTED BY",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        letterSpacing: 2,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15),
                                              width: 205,
                                              child: Text(
                                                director ?? "Not Found",
                                                style: const TextStyle(
                                                    color: textColor,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ),
                                            Container(
                                              width: 205,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 5),
                                              child: Row(
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      trailerLink != null
                                                          ? _launchURLBrowser(
                                                              trailerLink)
                                                          : const OKToast(
                                                              child: Text(
                                                                  "No Trailer!"));
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            backgroundColor:
                                                                navBarColor,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4)),
                                                    child: Row(
                                                      children: const [
                                                        Icon(Icons.play_arrow),
                                                        Text(
                                                          "TRAILER",
                                                          style: TextStyle(
                                                              letterSpacing: 2,
                                                              color: textColor),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 35,
                                                      horizontal: 15),
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        navBarColor),
                                                onPressed: () {
                                                  showModalBottomSheet(
                                                    context: context,
                                                    builder:
                                                        (BuildContext cptext) {
                                                      return SizedBox(
                                                          height: 200,
                                                          child: OKToast(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                IconButton(
                                                                  iconSize: 60,
                                                                  onPressed:
                                                                      () async {
                                                                    if (auth.currentUser ==
                                                                        null) {
                                                                      final snackBar =
                                                                          SnackBar(
                                                                        content:
                                                                            const Text('Please login first!'),
                                                                        action:
                                                                            SnackBarAction(
                                                                          label:
                                                                              '',
                                                                          onPressed:
                                                                              () {
                                                                            // Some code to undo the change.
                                                                          },
                                                                        ),
                                                                      );
                                                                      ScaffoldMessenger.of(
                                                                              cptext)
                                                                          .showSnackBar(
                                                                              snackBar);
                                                                    } else {
                                                                      if (!_hasWatched) {
                                                                        await firestore
                                                                            .collection(auth
                                                                                .currentUser!.uid)
                                                                            .doc(
                                                                                "movies")
                                                                            .update({
                                                                          'watchedMovies':
                                                                              FieldValue.arrayUnion([
                                                                            movie.id
                                                                          ])
                                                                        }).then((value) {
                                                                          watchedMoviesIds.add(movie.id!);
                                                                          Navigator.pop(context);
                                                                        });
                                                                      } else {
                                                                        await firestore
                                                                            .collection(auth
                                                                                .currentUser!.uid)
                                                                            .doc(
                                                                                "movies")
                                                                            .update({
                                                                          'watchedMovies':
                                                                              FieldValue.arrayRemove([
                                                                            movie.id
                                                                          ])
                                                                        }).then((value) =>
                                                                                Navigator.pop(context));
                                                                      }
                                                                      setState(
                                                                          () {
                                                                        _hasWatched =
                                                                            !_hasWatched;
                                                                      });
                                                                    }
                                                                  },
                                                                  icon:
                                                                      !_hasWatched
                                                                          ? const Icon(
                                                                              Icons.remove_red_eye_outlined,
                                                                              size: 60,
                                                                            )
                                                                          : const Icon(
                                                                              Icons.remove_red_eye_outlined,
                                                                              size: 60,
                                                                              color: Colors.green,
                                                                            ),
                                                                ),
                                                                IconButton(
                                                                  iconSize: 60,
                                                                  onPressed:
                                                                      () async {
                                                                    if (auth.currentUser ==
                                                                        null) {
                                                                      final snackBar =
                                                                          SnackBar(
                                                                        content:
                                                                            const Text('Please login first!'),
                                                                        action:
                                                                            SnackBarAction(
                                                                          label:
                                                                              '',
                                                                          onPressed:
                                                                              () {
                                                                            // Some code to undo the change.
                                                                          },
                                                                        ),
                                                                      );
                                                                      ScaffoldMessenger.of(
                                                                              cptext)
                                                                          .showSnackBar(
                                                                              snackBar);
                                                                    } else {
                                                                      if (!_hasLiked) {
                                                                        await firestore
                                                                            .collection(auth.currentUser!.uid)
                                                                            .doc("movies")
                                                                            .update({
                                                                          'likedMovies':
                                                                              FieldValue.arrayUnion([
                                                                            movie.id
                                                                          ])
                                                                        }).then((value) => Navigator.pop(context));
                                                                        likedMoviesIds.add(movie.id!);
                                                                      } else {
                                                                        await firestore
                                                                            .collection(auth.currentUser!.uid)
                                                                            .doc("movies")
                                                                            .update({
                                                                          'likedMovies':
                                                                              FieldValue.arrayRemove([
                                                                            movie.id
                                                                          ])
                                                                        });
                                                                      }
                                                                      setState(
                                                                          () {
                                                                        _hasLiked =
                                                                            !_hasLiked;
                                                                      });
                                                                      Navigator.pop(
                                                                          context);
                                                                    }
                                                                  },
                                                                  icon: !_hasLiked
                                                                      ? const Icon(
                                                                          Icons
                                                                              .favorite_border,
                                                                          size:
                                                                              60,
                                                                        )
                                                                      : const Icon(
                                                                          Icons
                                                                              .favorite,
                                                                          size:
                                                                              60,
                                                                          color:
                                                                              Colors.red,
                                                                        ),
                                                                ),
                                                                IconButton(
                                                                  iconSize: 60,
                                                                  onPressed:
                                                                      () async {
                                                                    if (auth.currentUser ==
                                                                        null) {
                                                                      final snackBar =
                                                                          SnackBar(
                                                                        content:
                                                                            const Text('Please login first!'),
                                                                        action:
                                                                            SnackBarAction(
                                                                          label:
                                                                              '',
                                                                          onPressed:
                                                                              () {
                                                                            // Some code to undo the change.
                                                                          },
                                                                        ),
                                                                      );
                                                                      ScaffoldMessenger.of(
                                                                              cptext)
                                                                          .showSnackBar(
                                                                              snackBar);
                                                                    } else {
                                                                      if (!_inWatchlist) {
                                                                        await firestore
                                                                            .collection(auth
                                                                                .currentUser!.uid)
                                                                            .doc(
                                                                                "movies")
                                                                            .update({
                                                                          'watchList':
                                                                              FieldValue.arrayUnion([
                                                                            movie.id
                                                                          ])
                                                                        }).then((value) => Navigator.pop(context));
                                                                        watchListIds.add(movie.id!);
                                                                      } else {
                                                                        await firestore
                                                                            .collection(auth
                                                                                .currentUser!.uid)
                                                                            .doc(
                                                                                "movies")
                                                                            .update({
                                                                          'watchList':
                                                                              FieldValue.arrayRemove([
                                                                            movie.id
                                                                          ])
                                                                        }).then((value) =>
                                                                                Navigator.pop(context));
                                                                      }
                                                                      setState(
                                                                          () {
                                                                        _inWatchlist =
                                                                            !_inWatchlist;
                                                                      });
                                                                    }
                                                                  },
                                                                  icon: !_inWatchlist
                                                                      ? const Icon(
                                                                          Icons
                                                                              .watch_later_outlined,
                                                                          size:
                                                                              60,
                                                                        )
                                                                      : const Icon(
                                                                          Icons
                                                                              .watch_later,
                                                                          size:
                                                                              60,
                                                                          color:
                                                                              Colors.orange,
                                                                        ),
                                                                ),
                                                              ],
                                                            ),
                                                          ));
                                                    },
                                                  );
                                                },
                                                child: const Text(
                                                    "Log or add to liked!"),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: 235,
                                        right: 25,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.all(0),
                                              backgroundColor:
                                                  Colors.transparent,
                                              elevation: 5.0,
                                              side: const BorderSide(
                                                  color: trailerButtonColor,
                                                  width: 1)),
                                          onPressed: () {},
                                          child: Card(
                                            margin: const EdgeInsets.all(0),
                                            elevation: 2,
                                            child: Hero(
                                              tag: "${movie.posterPath}",
                                              child: Image(
                                                height: 180,
                                                alignment: Alignment.topRight,
                                                fit: BoxFit.fitWidth,
                                                image: NetworkImage(
                                                    'https://image.tmdb.org/t/p/w500${movie.posterPath}'),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } else if (snap.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                color: Colors.purple,
                              ));
                            }
                            return const Center(child: Text("Error!"));
                          });
                    }
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return const Center(
                    child: Text("Error!"),
                  );
                });
          }
        }
        return const Center(
          child: Text("Error!"),
        );
      },
    );
  }

  _launchURLBrowser(String key) async {
    var url = Uri.parse("https://youtu.be/$key");
    await launchUrl(url);
  }
}
