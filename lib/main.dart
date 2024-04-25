import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'message_screen.dart';
import 'feed_screen.dart';
import 'settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Define the initial route
      initialRoute: '/',
      // Define the routes
      routes: {
        '/': (context) => LoginScreen(), // The route for the login screen
        '/profile': (context) => ProfileScreen(), // The route for the profile screen
        '/messages': (context) => MessageScreen(), // The route for the messages screen
        '/feed': (context) => FeedScreen(), // The route for the feed screen
        '/settings': (context) => SettingsScreen(), // The route for the settings screen
      },
    );
  }
}
