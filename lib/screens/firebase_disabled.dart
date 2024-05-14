import 'package:convo_connect_chat_app/animations/splash_screen_anim.dart';
import 'package:flutter/material.dart';

class FirebaseDisabled extends StatelessWidget {
  const FirebaseDisabled({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplashScreenAnimation(
          splashScreen: Text(
        'Database is OFF 🥲',
        style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: 20,
            fontWeight: FontWeight.bold),
      )),
    );
  }
}
