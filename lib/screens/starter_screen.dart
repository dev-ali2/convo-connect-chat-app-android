import 'dart:async';

import 'package:convo_connect_chat_app/helpers/screen_size.dart';

import 'package:convo_connect_chat_app/screens/authentication_screen.dart';

import 'package:convo_connect_chat_app/widgets/custom_sized_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';

class GetStartedScreen extends StatefulWidget {
  static const routeName = '/startScreen';
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    final height = GetScreenSize().screenSize(context).height;
    final width = GetScreenSize().screenSize(context).width;
    return Scaffold(
        body: SafeArea(
      child: Padding(
          padding: EdgeInsets.only(top: height * 0.04),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  //color: Colors.blue,
                  height: height * 0.4,
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: width * 0.4,
                        height: height * 0.17,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            image: const DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                    'assets/images/main_icon.jpeg'))),
                      ),
                      const CustomSizedBox(
                        height: 20,
                        width: 0,
                      ),
                      const Text(
                        " Convo Connect",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 35),
                      ),
                      CustomSizedBox(height: 10, width: width),
                      const Text(
                        'Chat in your favorite person\'s language ',
                        softWrap: true,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isClicked = true;
                      Timer(Duration(milliseconds: 500), () {
                        setState(() {
                          Navigator.of(context).pushReplacementNamed(
                              AuthenticatioScreen.routeName);
                        });
                      });
                    });
                  },
                  child: Container(
                      child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease,
                        height: 70,
                        width: isClicked ? 75 : 200,
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.6),
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      Positioned(
                          top: 10,
                          bottom: 10,
                          right: isClicked ? 7 : 10,
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100)),
                            child: Icon(
                              LucideIcons.arrowBigRight,
                              color: Colors.black,
                              size: 30,
                            ),
                          )),
                      if (!isClicked)
                        Positioned(
                            top: 25,
                            bottom: 25,
                            left: 20,
                            child: Text(
                              'Get Started',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 19),
                            ))
                    ],
                  )),
                )
              ])),
    ));
  }
}
