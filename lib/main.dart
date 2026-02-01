// Import Flutter Material package for Material Design widgets
import 'package:flutter/material.dart';

// Import FlashScreen
import 'pages/flash_screen.dart';

void main() {
  runApp(const MyApp());
}

// Root widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FlashScreen(), // App starts with Flash Screen
    );
  }
}
