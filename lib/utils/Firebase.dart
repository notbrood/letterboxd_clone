import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firestore = FirebaseFirestore.instance;

FirebaseAuth auth = FirebaseAuth.instance;
User? user;

List<int> likedMoviesIds = [];
List<int> watchedMoviesIds = [];
List<int> watchListIds = [];
