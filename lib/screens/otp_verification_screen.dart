import 'dart:async';

import 'package:convo_connect_chat_app/helpers/screen_size.dart';

import 'package:convo_connect_chat_app/screens/chats_screen.dart';
import 'package:convo_connect_chat_app/screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class OtpVerificationScreen extends StatefulWidget {
  String email;
  OtpVerificationScreen({required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  @override
  void initState() {
    super.initState();
    startTimer();
    resendLink();
  }

  TextEditingController _otp = TextEditingController();

  Timer? timer;

  int start = 45;
  bool isDone = false;

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (start == 0) {
        setState(() {
          timer.cancel();
          return;
        });
      }
      if (start > 0)
        setState(() {
          start--;
        });
    });
  }

  void checkVerification() async {
    var _auth = await FirebaseAuth.instance;
    await _auth.currentUser!.reload();
    if (_auth.currentUser!.emailVerified) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => ChatsScreen()),
          (route) => false);
      return;
    }
    if (!_auth.currentUser!.emailVerified) {
      setState(() {
        isDone = false;
      });
      showTopSnackBar(Overlay.of(context),
          CustomSnackBar.error(message: 'Email not verified yet!'));
      return;
    }
  }

  Future<String> resendLink() async {
    try {
      var _auth = await FirebaseAuth.instance;
      await _auth.currentUser!.sendEmailVerification().then((value) {});
      return 'New link sent';
    } catch (e) {
      return 'Error in sending new link';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = GetScreenSize().screenSize(context).height;
    final double width = GetScreenSize().screenSize(context).width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Verify your Email',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
          child: Container(
        height: height * 0.30,
        width: width * 0.9,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Theme.of(context).colorScheme.onPrimary,
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary,
            )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Open verification link sent to ',
                  style: TextStyle(fontSize: 17),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  '${widget.email}',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isDone)
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isDone = true;
                        });
                        checkVerification();
                      },
                      child: Text('Done?')),
                if (isDone)
                  CircularProgressIndicator(
                    strokeAlign: -3,
                    strokeCap: StrokeCap.round,
                    strokeWidth: 5,
                  ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: start == 0
                        ? () {
                            setState(() {
                              start = 45;
                            });

                            resendLink().then((value) {
                              startTimer();
                              showTopSnackBar(Overlay.of(context),
                                  CustomSnackBar.success(message: value));
                            });
                          }
                        : null,
                    child: Text('Resend link')),
                SizedBox(
                  width: 7,
                ),
                Text(
                  '${start}',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
            ElevatedButton.icon(
                onPressed: () async {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      SplashScreen.routeName, (route) => false);
                  return;
                },
                icon: Icon(
                  LucideIcons.logOut,
                  color: Colors.red,
                ),
                label: Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ))
          ],
        ),
      )),
    );
  }
}
