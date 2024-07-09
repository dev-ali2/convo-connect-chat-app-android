import 'dart:async';
import 'dart:developer';

import 'package:convo_connect_chat_app/data/testing_api.dart';

import 'package:convo_connect_chat_app/providers/auth_form_provider.dart';
import 'package:convo_connect_chat_app/providers/auth_provider.dart';
import 'package:convo_connect_chat_app/providers/chat_provider.dart';
import 'package:convo_connect_chat_app/screens/authentication_screen.dart';
import 'package:convo_connect_chat_app/screens/chats_screen.dart';
import 'package:convo_connect_chat_app/screens/developer_info.dart';
import 'package:convo_connect_chat_app/screens/otp_verification_screen.dart';
import 'package:convo_connect_chat_app/screens/profile_page.dart';
import 'package:convo_connect_chat_app/screens/report_page.dart';
import 'package:convo_connect_chat_app/screens/settings_page.dart';
import 'package:convo_connect_chat_app/screens/splash_screen.dart';
import 'package:convo_connect_chat_app/screens/starter_screen.dart';
import 'package:convo_connect_chat_app/screens/updates_screen.dart';
import 'package:convo_connect_chat_app/screens/user_chat_screen.dart';
import 'package:convo_connect_chat_app/screens/whatsnew_screen.dart';

import 'package:convo_connect_chat_app/widgets/select_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// @pragma('vm:entry-point')
// Future<void> handleBackgroundMessage(RemoteMessage message) async {
//   await AuthProv().initFirebase();
//   log('in background message handler');
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthProv().initFirebase();
  // await ChatProv().openAppFromTerminatedState();
  // await ChatProv().openFromBackground();

  // FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

  AuthProv().getTheme().then(
    (value) {
      log('trying to run app');
    },
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // ChatProv().firebaseMessagingInit(context);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthFormProv(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProv(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatProv(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Convo Connect',
        theme: CustomThemeData().lightTheme,
        darkTheme: CustomThemeData().darkTheme,
        home: SplashScreen(),
        routes: {
          AuthenticatioScreen.routeName: (context) => AuthenticatioScreen(),
          ChatsScreen.routeName: (context) => ChatsScreen(),
          SplashScreen.routeName: (context) => SplashScreen(),
          GetStartedScreen.routeName: (context) => GetStartedScreen(),
          UpdatesScreen.routeName: (context) => UpdatesScreen(),
          UserChatScreen.routeName: (context) => UserChatScreen(),
          ProfilePage.routeName: (context) => ProfilePage(),
          settingsPage.routeName: (context) => settingsPage(),
          developerInfo.routeName: (context) => developerInfo(),
          ReportPage.routeName: (context) => ReportPage(),
          WhatNewScreen.routename: (context) => WhatNewScreen()
        },
      ),
    );
  }
}
