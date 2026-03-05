import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/creator_screen.dart';

void main() {
  runApp(const ModUrWallApp());
}

class ModUrWallApp extends StatelessWidget {
  const ModUrWallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ModUrWall',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Courier',
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0a0e1a),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/creator': (context) => const CreatorScreen(),
      },
    );
  }
}
