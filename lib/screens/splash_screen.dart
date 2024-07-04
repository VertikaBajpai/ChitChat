import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AnimatedSplashScreen(
        nextScreen: const AuthService(),
        splash: 'lib\assets\images\20190806153212_icon.png',
        splashTransition: SplashTransition.scaleTransition,
      ),
    );
  }
}
