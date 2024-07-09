import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convo_connect_chat_app/providers/chat_provider.dart';
import 'package:convo_connect_chat_app/screens/starter_screen.dart';
import 'package:convo_connect_chat_app/widgets/select_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthProv with ChangeNotifier {
  Future<void> setTheme(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('index', index);
  }

  Future<void> getTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int index = await prefs.getInt('index') ?? 0;

    SelectTheme().setTheme(index);
  }

  Future<void> initFirebase() async {
    log('in init firebase');
    try {
      await dotenv.load(fileName: ".env");
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: dotenv.env['API_KEY']!,
          appId: dotenv.env['APP_ID']!,
          messagingSenderId: dotenv.env['MESSAGING_SENDER_ID']!,
          projectId: dotenv.env['PROJECT_ID']!,
          storageBucket: dotenv.env['STORAGE_BUCKET']!,
        ),
      );
      // await FirebaseFirestore.instance;
      // await FirebaseAuth.instance;
      // await FirebaseFirestore.instance;
      // await ChatProv().fetchChatList();

      log('Firebase initialized');
      chkstatus();
    } catch (e) {
      log('new debug error in initializing firebase ${e.toString()}');
    }
  }

  Future<void> chkstatus() async {
    await FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        log('User is currently signed out!');
      } else {
        log('User is signed in!');
      }
    });
  }

  Future<void> signoutUser(BuildContext context) async {
    await FirebaseAuth.instance
        .signOut()
        .then((value) => Navigator.pushNamedAndRemoveUntil(
              context,
              GetStartedScreen.routeName,
              (Route<dynamic> route) => false,
            ));

    log('user signed out');
  }

  Future<void> signoutFromDatabase() async {
    await FirebaseAuth.instance.signOut();
  }
}
