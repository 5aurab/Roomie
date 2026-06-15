import 'package:flutter/material.dart';
//import 'screens/auth.dart';
//import '../widgets/bottom_nav_bar.dart';
import '../screens/welcome.dart';
//import '../screens/verification.dart';
//import '../screens/reset_password.dart';
//import '../screens/forgot_password.dart';
//import '../screens/create_home.dart';

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
      //home: const AuthScreen(),
      //home: const MainNavigation(),
      home: const WelcomeScreen(),
      //home: const VerificationScreen(email:'anagha'),
      //home: const ResetPasswordScreen(email: 'anagha'),
      //home: const ForgotPasswordScreen(),
      //home: const CreateHomeScreen(),
    );
  }
}
