import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:convo_connect_chat_app/providers/chat_provider_logic.dart';

import 'package:convo_connect_chat_app/providers/auth_provider_logic.dart';
import 'package:convo_connect_chat_app/screens/chats_screen.dart';
import 'package:convo_connect_chat_app/screens/otp_verification_screen.dart';
import 'package:convo_connect_chat_app/screens/starter_screen.dart';
import 'package:convo_connect_chat_app/widgets/splash_screen_components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:internet_connectivity_checker/internet_connectivity_checker.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splashScreen';
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // ChatProv()
    //     .initNotificationRequest()
    //     .then((value) => ChatProv().listenToTokenChanges());
    super.initState();
    log('inSplashScreen');
    // oneSignalID = dotenv.env['ONESIGNALID'];
    // OneSignal.initialize(oneSignalID!);
    // // OneSignal.Notifications.requestPermission(true);
    // OneSignal.User.getOnesignalId()
    //     .then((value) => log('One signal id ${value}'));
    // log('One signal subscription id ${OneSignal.User.pushSubscription.id}');
    ChatProv().initOneSignal();
  }

  var currentUser = FirebaseAuth.instance.currentUser;
  String? oneSignalID;
  bool emailValidity = false;
  Future<bool> checkUser() async {
    String auth = await FirebaseAuth.instance.currentUser!.uid;
    if (auth != '' || auth != null) {
      return true;
    }
    return false;
  }

  bool isFirebaseLoaded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ConnectivityBuilder(
      interval: Duration(days: 100),
      builder: (status) {
        if (status == ConnectivityStatus.online) {
          return FutureBuilder(
              future: AuthProv().initFirebase(),
              builder: (c1, s1) {
                if (s1.connectionState == ConnectionState.waiting) {
                  return SplashScreenComponents(
                    status: 'Loading Database 🏋️',
                    needProgressIndicator: true,
                  );
                }
                if (s1.connectionState == ConnectionState.done) {
                  return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('disableFirebase')
                          .snapshots(),
                      builder: (c2, s2) {
                        if (s2.connectionState == ConnectionState.waiting) {
                          return SplashScreenComponents(
                            status: 'Checking Database status 🧐',
                            needProgressIndicator: true,
                          );
                        }
                        if (s2.connectionState == ConnectionState.active) {
                          log('Firebase builder Active builder active');
                          log('is firebase on ${s2.data!.docs.first.data()['isFirebaseON']}');
                          if ((s2.data!.docs.first.data()['isFirebaseON']
                                      as bool) !=
                                  false &&
                              s2.data!.docs.first.data()['isFirebaseON'] !=
                                  null) {
                            return StreamBuilder(
                                stream:
                                    FirebaseAuth.instance.authStateChanges(),
                                builder: (c3, s3) {
                                  if (s3.connectionState ==
                                      ConnectionState.waiting) {
                                    return SplashScreenComponents(
                                      status: 'Checking Login Status 🧐',
                                      needProgressIndicator: true,
                                    );
                                  }
                                  if (s3.connectionState ==
                                      ConnectionState.active) {
                                    return FutureBuilder(
                                      future: checkUser(),
                                      builder: (c4, s4) {
                                        if (s4.connectionState ==
                                            ConnectionState.waiting) {
                                          return SplashScreenComponents(
                                              status: 'Validating User 🧐',
                                              needProgressIndicator: true);
                                        }
                                        if (s4.connectionState ==
                                            ConnectionState.done) {
                                          if (s4.data != null &&
                                              s4.data != false) {
                                            if (!currentUser!.emailVerified) {
                                              return OtpVerificationScreen(
                                                  email: currentUser!.email!);
                                            }
                                            return ChatsScreen();
                                          }
                                          return GetStartedScreen();
                                        }
                                        return GetStartedScreen();
                                      },
                                    );
                                  }
                                  return GetStartedScreen();
                                });
                          }
                          if ((s2.data!.docs.first.data()['isFirebaseON']
                                      as bool) ==
                                  false ||
                              s2.data!.docs.first.data()['isFirebaseON'] ==
                                  null) {
                            AuthProv().signoutFromDatabase();
                            return SplashScreenComponents(
                              status: 'Database is temporarily OFF 😵‍💫',
                              needProgressIndicator: false,
                            );
                          }
                        }

                        return GetStartedScreen();
                      });
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SplashScreenComponents(
                      status: 'Error loading Database 🥲',
                      needProgressIndicator: false,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton.icon(
                        onPressed: () {
                          setState(() {});
                        },
                        icon: Icon(Icons.replay_outlined),
                        label: Text('Retry 🤔'))
                  ],
                );
              });
        }
        if (status == ConnectivityStatus.offline) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SplashScreenComponents(
                status: 'No Internet 😿',
                needProgressIndicator: false,
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton.icon(
                  onPressed: () {
                    setState(() {});
                  },
                  icon: Icon(Icons.replay_outlined),
                  label: Text('Retry 🤔'))
            ],
          );
        }
        return SplashScreenComponents(
          status: 'Checking Internet Status 🧐',
          needProgressIndicator: true,
        );
      },
    ));
  }
}
