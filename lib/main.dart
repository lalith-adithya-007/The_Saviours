import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// 1. Correct Import for Firebase Options
import 'backend/firebase_options.dart'; 

// 2. Correct Imports for your Pages
import 'pages/flash_screen.dart';
import 'pages/sign_up.dart';
import 'pages/login.dart'; 

void main() async {
  // Ensure Flutter bindings are initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the options from your backend folder
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Saviour App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      
      // Starting Screen
      home: const FlashScreen(),

      // 3. Updated Routes with required arguments
      routes: {
        // Fix: Pass 'User' as the default role to clear the error under SignUpPage()
        '/signup': (context) => const SignUpPage(role: 'User'),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}