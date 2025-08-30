import 'package:flutter/material.dart';
import 'home.dart';

void main() {
  runApp(const MyApp()); // Add const here
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mind Track',
      theme: ThemeData(
        useMaterial3: true, // Enables modern Material Design
        colorSchemeSeed: Colors.blue,
      ),
      home: const HomeScreen(), // Add const if HomeScreen constructor is const
    );
  }
}