import 'package:flutter/material.dart';
import 'screens/auth.dart';
//import '../widgets/bottom_nav_bar.dart';
//import '../screens/welcome_screen.dart';
//import '../screens/verification_screen.dart';
//import '../screens/reset_password_screen.dart';
//import '../screens/forgot_password_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roomie',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthScreen(),
      //home: const MainNavigation(),
      //home: const WelcomeScreen(),
      //home: const VerificationScreen(email:'anagha'),
      //home: const ResetPasswordScreen(email: 'anagha'),
      //home: const ForgotPasswordScreen(),
    );
  }
}
