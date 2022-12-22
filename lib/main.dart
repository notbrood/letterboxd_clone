import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:letterboxd_clone/firebase_options.dart';
import 'package:letterboxd_clone/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Letterboxd-clone',
      theme: ThemeData.dark().copyWith(),
      home: HomeScreen(search: "popular",),
    );
  }
}
