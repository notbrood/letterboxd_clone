import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:letterboxd_clone/methods/methods.dart';
import 'package:letterboxd_clone/models/movielist.dart';
import 'package:letterboxd_clone/screens/movie_screen.dart';
import 'package:letterboxd_clone/utils/Firebase.dart';
import 'package:letterboxd_clone/utils/colors.dart';
import 'package:letterboxd_clone/widgets/movieCard.dart';
import 'package:stretchy_header/stretchy_header.dart';

class HomeScreen extends StatefulWidget {
  String search;
  HomeScreen({Key? key, required this.search}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState(search: search);
}

Widget? o;
bool y = false;

class _HomeScreenState extends State<HomeScreen> {
  String search;
  _HomeScreenState({required this.search});
  @override
  void initState() {
    super.initState();
    returnX();
    search = widget.search;
  }

  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: y
          ? AppBar(
              backgroundColor: appBarColor,
              title: const Text(
                'Letterboxd',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              centerTitle: true,
              elevation: 0,
            )
          : AppBar(
              toolbarHeight: 0,
            ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.person),
                backgroundColor: navBarColor,
                label: ""),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                ),
                backgroundColor: navBarColor,
                label: ""),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.search,
                ),
                backgroundColor: navBarColor,
                label: "")
          ],
          type: BottomNavigationBarType.fixed,
          backgroundColor: navBarColor,
          currentIndex: _selectedIndex,
          selectedFontSize: 14,
          selectedItemColor: Colors.blue,
          iconSize: 30,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          unselectedItemColor: Colors.grey,
          onTap: _onNavBarTap,
          elevation: 0),
      body: _selectedIndex == 1
          ? Center(
              child: o,
            )
          : _selectedIndex == 2
              ? TypeAheadField<Result?>(
                  suggestionsCallback: getSuggestions,
                  textFieldConfiguration: TextFieldConfiguration(decoration: InputDecoration(prefixIcon: Icon(Icons.search), fillColor: textColor)),
                  itemBuilder: (context, Result? movie) {
                    return Row(
                      children: [
                        Container(height: 180, width: 138, child: MovieCard(movie!.id!, context), margin: EdgeInsets.zero, padding: EdgeInsets.zero,),
                        const SizedBox(width: 20, height: 2,),
                        Column(children: [
                          Container(width: 100, child: Text(movie.title!, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1))),

                        ],)
                      ],
                    );
                  },
                  errorBuilder: (context, error) {
                    return const Center(
                      child: Text("No movies found!"),
                    );
                  },
                  noItemsFoundBuilder: (context) {
                    return const Center(
                      child: Text("No movies found!"),
                    );
                  },
                  onSuggestionSelected: (res) async {
                    final movie = await getMovie(res!.id!);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MovieScreen(movie: movie!)));
                  },
                  hideKeyboardOnDrag: true,
                  hideSuggestionsOnKeyboardHide: false,)
              : signedInNahiHaiKya()
                  ? StretchyHeader.singleChild(
                      displacement: 20,
                      headerData: HeaderData(
                        blurContent: false,
                        headerHeight: 350,
                        header: Container(
                          foregroundDecoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: const Alignment(0.95, 0.95),
                              colors: [
                                backgroundColor.withOpacity(0.95),
                                backgroundColor.withOpacity(0.05)
                              ],
                            ),
                          ),
                          child: CarouselSlider(
                            items: [
                              Image.asset(
                                "images/slide1.jpg",
                                fit: BoxFit.cover,
                              ),
                              Image.asset("images/slide2.jpg",
                                  fit: BoxFit.cover),
                              Image.asset("images/slide3.jpg",
                                  fit: BoxFit.cover),
                              Image.asset("images/slide4.jpg",
                                  fit: BoxFit.cover),
                            ],
                            options: CarouselOptions(
                                height: 400,
                                aspectRatio: 16 / 9,
                                viewportFraction: 1,
                                initialPage: 0,
                                enableInfiniteScroll: true,
                                reverse: false,
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 3),
                                autoPlayAnimationDuration:
                                    const Duration(milliseconds: 800),
                                autoPlayCurve: Curves.fastLinearToSlowEaseIn,
                                enlargeCenterPage: true,
                                scrollDirection: Axis.horizontal),
                          ),
                        ),
                      ),
                      child: Container(
                        height: 250,
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          child: const Text("Sign in with google"),
                          onPressed: () {
                            signup(context);
                          },
                        ),
                      ))
                  : SingleChildScrollView(
                      child: FutureBuilder(
                          future: getUserMovies(),
                          builder: (context, sap) {
                            if (sap.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (sap.connectionState ==
                                ConnectionState.done) {
                              List<Widget> likedMovies = [];
                              List<Widget> watchedMovies = [];
                              List<Widget> watchList = [];
                              if (sap.hasData) {
                                {
                                  for (int i in sap.data!["watchedMovies"]) {
                                    watchedMoviesIds.add(i);
                                    watchedMovies.add((MovieCard(i, context)));
                                  }
                                  for (int i in sap.data!["watchList"]) {
                                    watchListIds.add(i);
                                    watchList.add(MovieCard(i, context));
                                  }
                                  for (int i in sap.data!["likedMovies"]) {
                                    likedMoviesIds.add(i);
                                    likedMovies.add(MovieCard(i, context));
                                  }
                                }
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    watchList.isEmpty
                                        ? const Padding(
                                          padding: EdgeInsets.all(64.0),
                                          child: Text("Watchlist empty!", style: TextStyle(fontSize: 35),),
                                        )
                                        : Column(
                                            children: [
                                              const Text("WatchList"),
                                              CarouselSlider(
                                                items: watchList,
                                                options: CarouselOptions(
                                                    height: 200,
                                                    aspectRatio: 16 / 9,
                                                    viewportFraction: 1 / 3,
                                                    initialPage: 0,
                                                    enableInfiniteScroll: true,
                                                    reverse: false,
                                                    autoPlay: true,
                                                    autoPlayInterval:
                                                        const Duration(
                                                            seconds: 3),
                                                    autoPlayAnimationDuration:
                                                        const Duration(
                                                            milliseconds: 800),
                                                    autoPlayCurve: Curves
                                                        .fastLinearToSlowEaseIn,
                                                    enlargeCenterPage: true,
                                                    scrollDirection:
                                                        Axis.horizontal),
                                              ),
                                            ],
                                          ),
                                    likedMovies.isEmpty
                                        ? const Padding(
                                          padding: EdgeInsets.all(64.0),
                                          child: Text("No liked movies", style: TextStyle(fontSize: 35),),
                                        )
                                        : Column(
                                            children: [
                                              const Text("Liked Movies"),
                                              CarouselSlider(
                                                items: likedMovies,
                                                options: CarouselOptions(
                                                    height: 200,
                                                    aspectRatio: 16 / 9,
                                                    viewportFraction: 1 / 3,
                                                    initialPage: 0,
                                                    enableInfiniteScroll: true,
                                                    reverse: false,
                                                    autoPlay: true,
                                                    autoPlayInterval:
                                                        const Duration(
                                                            seconds: 3),
                                                    autoPlayAnimationDuration:
                                                        const Duration(
                                                            milliseconds: 800),
                                                    autoPlayCurve: Curves
                                                        .fastLinearToSlowEaseIn,
                                                    enlargeCenterPage: true,
                                                    scrollDirection:
                                                        Axis.horizontal),
                                              ),
                                            ],
                                          ),
                                    watchedMovies.isEmpty
                                        ? const Padding(
                                          padding: EdgeInsets.all(64.0),
                                          child: Text("No movies added to watched movies!", style: TextStyle(fontSize: 35),),
                                        )
                                        : Column(
                                            children: [
                                              const Text("Watched Movies"),
                                              CarouselSlider(
                                                items: watchedMovies,
                                                options: CarouselOptions(
                                                    height: 200,
                                                    aspectRatio: 16 / 9,
                                                    viewportFraction: 1 / 3,
                                                    initialPage: 0,
                                                    enableInfiniteScroll: true,
                                                    reverse: false,
                                                    autoPlay: true,
                                                    autoPlayInterval:
                                                        const Duration(
                                                            seconds: 3),
                                                    autoPlayAnimationDuration:
                                                        const Duration(
                                                            milliseconds: 800),
                                                    autoPlayCurve: Curves
                                                        .fastLinearToSlowEaseIn,
                                                    enlargeCenterPage: true,
                                                    scrollDirection:
                                                        Axis.horizontal),
                                              ),
                                            ],
                                          ),
                                  ],
                                );
                              }
                            }
                            return const Text("Error!");
                          }),
                    ),
    );
  }

  void _onNavBarTap(int x) {
    if (x == 0) {
      y = false;
    } else {
      y = true;
    }
    setState(() {
      _selectedIndex = x;
    });
  }

  Future<Widget> returnX() async {
    var popularMovies = await movieSearch(search);
    List<Widget> rowList = [];
    int pp = 0;
    List<Widget> p = [];
    for (int j = 0; j < popularMovies.length; j++) {
      Result? i = popularMovies[j];
      if (pp == 3) {
        rowList.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: p,
        ));
        p = [];
        pp = 0;
      }
      p.add(Expanded(
        flex: 1,
        child: MovieCard(i!.id!, context),
      ));
      pp++;
    }
    rowList.insert(
        0,
        Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 0, 0),
          alignment: Alignment.topLeft,
          child: const Text(
            "Popular this week",
            style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 2),
          ),
        ));
    rowList.insert(
        1,
        const SizedBox(
          height: 10,
        ));
    o = SingleChildScrollView(
      child: Column(
        children: rowList,
      ),
    );
    return o!;
  }

  bool signedInNahiHaiKya() {
    if (auth.currentUser != null) return false;
    return true;
  }

  Future<void> signup(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
      UserCredential result = await auth.signInWithCredential(authCredential);
      user = result.user;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(search: "popular")));
      try {
        await firestore.collection(user!.uid).doc("movies").update({
          "likedMovies": FieldValue.arrayUnion([]),
          'watchList': FieldValue.arrayUnion([]),
          'watchedMovies': FieldValue.arrayUnion([])
        });
      } catch (e) {
        await firestore
            .collection(user!.uid)
            .doc("movies")
            .set({"likedMovies": [], 'watchList': [], 'watchedMovies': []});
      }
    }
  }

  Future<List<Result?>> getSuggestions(String query) {
    return movieSearchFrThisTime(query);
  }
}
