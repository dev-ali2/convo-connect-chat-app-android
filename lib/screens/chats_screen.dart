import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convo_connect_chat_app/animations/splash_screen_anim.dart';

import 'package:convo_connect_chat_app/helpers/screen_size.dart';

import 'package:convo_connect_chat_app/providers/chat_provider_logic.dart';
import 'package:convo_connect_chat_app/screens/updates_screen.dart';
import 'package:convo_connect_chat_app/widgets/app_drawer.dart';
import 'package:convo_connect_chat_app/widgets/chats_list.dart';
import 'package:convo_connect_chat_app/widgets/custom_sized_box.dart';
import 'package:convo_connect_chat_app/widgets/my_details.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:flutter/material.dart';

import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class ChatsScreen extends StatefulWidget {
  static const routeName = '/chatScreen';
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    ChatProv().getMyDetails().then((value) => myData = value);
  }

  @override
  void initState() {
    super.initState();
    ChatProv().initOneSignal();
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  String myImage = '';
  bool isProfileLoading = false;
  String regDate = '';
  String lang = '';
  Map<String, dynamic> myData = {};
  int totalMessagesCount = 0;
  int screenIndex = 0;
  List<Widget> screens = [ChatsList(), UpdatesScreen()];

  @override
  Widget build(BuildContext context) {
    double height = GetScreenSize().screenSize(context).height;
    double width = GetScreenSize().screenSize(context).width;
    PageController _pageController = PageController();
    return Scaffold(
      appBar: AppBar(
        actions: [
          Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (screenIndex == 0)
                  Container(
                    height: (height * width) * 0.00008,
                    width: (height * width) * 0.00008,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('registeredUsers')
                          .where('userId', isEqualTo: _auth.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshotData) {
                        if (snapshotData.connectionState ==
                                ConnectionState.waiting ||
                            snapshotData.connectionState ==
                                ConnectionState.done) {
                          return Container();
                        }
                        myImage = snapshotData.data!.docs.first
                            .data()['userImageUrl'];
                        return FutureBuilder(
                            future: ChatProv().getMyDetails(),
                            builder: (c, s) {
                              if (s.connectionState ==
                                  ConnectionState.waiting) {
                                return SplashScreenAnimation(
                                  splashScreen: Container(
                                    height: (height * width) * 0.00008,
                                    width: (height * width) * 0.00008,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100)),
                                  ),
                                );
                              }
                              if (s.connectionState == ConnectionState.done) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isProfileLoading = true;
                                    });
                                    Future.delayed(Duration(seconds: 0)).then(
                                        (value) => ChatProv()
                                                .getUserRegistrationDate(
                                                    s.data!['myId'])
                                                .then(
                                              (value) {
                                                regDate = value;
                                                ChatProv()
                                                    .getLanguageName(
                                                        s.data!['prefLang'])
                                                    .then((value) {
                                                  lang = value;
                                                  ChatProv()
                                                      .getMyProfilePic()
                                                      .then((value) {
                                                    // myImage = value;
                                                  }).then((value) =>
                                                          setState(() {
                                                            isProfileLoading =
                                                                false;
                                                          }));
                                                }).then((value) => showDialog(
                                                        barrierDismissible:
                                                            false,
                                                        context: context,
                                                        builder: (context) {
                                                          return MyDetails(
                                                            myData: s.data!,
                                                            lang: lang,
                                                            regDate: regDate,
                                                            myImage: myImage,
                                                          );
                                                        }));
                                              },
                                            ));
                                  },
                                  child: !isProfileLoading
                                      ? Container(
                                          height: (height * width) * 0.00008,
                                          width: (height * width) * 0.00008,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(100)),
                                          child: s.data != null
                                              ? s.data!['myImageUrl'] != '' &&
                                                      s.data!['myImageUrl'] !=
                                                          null
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      child: Image.network(
                                                        myData['myImageUrl'],
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                  : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      child: Image.asset(
                                                        'assets/images/no_user.png',
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                              : LoadingAnimationWidget
                                                  .threeRotatingDots(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  size: height * 0.04,
                                                ),
                                        )
                                      : SplashScreenAnimation(
                                          splashScreen: Container(
                                            height: (height * width) * 0.00008,
                                            width: (height * width) * 0.00008,
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(100)),
                                            child: s.data!['myImageUrl'] !=
                                                        '' &&
                                                    s.data!['myImageUrl'] !=
                                                        null
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    child: Image.network(
                                                      myData['myImageUrl'],
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    child: Image.asset(
                                                      'assets/images/no_user.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                );
                              }
                              return SplashScreenAnimation(
                                splashScreen: Container(
                                  height: (height * width) * 0.00008,
                                  width: (height * width) * 0.00008,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(100)),
                                ),
                              );
                            });
                      },
                    ),
                  ),
                CustomSizedBox(height: 0, width: 20),
              ])
        ],
        title: Text(
          'CONVO CONNECT',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(child: AppDrawer()),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          log('page index ${index}');
          setState(() {
            screenIndex = index;
          });
        },
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Theme.of(context).colorScheme.primary,
          onTap: (value) {
            setState(() {
              _pageController.animateToPage(value,
                  duration: Duration(milliseconds: 300), curve: Curves.ease);
            });
          },
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          currentIndex: screenIndex,
          elevation: 10,
          items: [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.messagesSquare),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
                icon: Icon(LucideIcons.galleryHorizontal), label: 'Updates')
          ]),
    );
  }
}
