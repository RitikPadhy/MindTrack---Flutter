import 'package:flutter/material.dart';
import 'home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mind Track',
      theme: ThemeData(
        useMaterial3: true, // Enables modern Material Design
        colorSchemeSeed: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}