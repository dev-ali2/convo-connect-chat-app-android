import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convo_connect_chat_app/animations/splash_screen_anim.dart';

import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:convo_connect_chat_app/models/chat.dart';
import 'package:convo_connect_chat_app/providers/chat_provider_logic.dart';
import 'package:convo_connect_chat_app/screens/chats_screen.dart';
import 'package:convo_connect_chat_app/screens/profile_page.dart';
import 'package:convo_connect_chat_app/screens/user_chat_screen.dart';
import 'package:convo_connect_chat_app/screens/whatsnew_screen.dart';
import 'package:convo_connect_chat_app/widgets/chat_tile.dart';
import 'package:convo_connect_chat_app/widgets/custom_sized_box.dart';
import 'package:convo_connect_chat_app/widgets/search_user.dart';
import 'package:convo_connect_chat_app/widgets/whatsnew_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:internet_connectivity_checker/internet_connectivity_checker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class ChatsList extends StatefulWidget {
  @override
  State<ChatsList> createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList>
    with AutomaticKeepAliveClientMixin<ChatsList> {
  @override
  bool get wantKeepAlive => true;
  Future<void> refreshPage() async {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    // ChatProv().getUpdateNotes().then((value) {
    //   if (value.isNotEmpty && value != {}) {
    //     log('new feature setting new data');
    //     isNewUpdate = true;
    //     data = value;
    //     navigatorKey.currentState!
    //         .pushNamed(WhatNewScreen.routename, arguments: data);
    //   }
    // });

    // ChatProv().initNotificationRequest();
  }

  bool isOnline = true;
  FirebaseAuth? _auth;
  int newMessages = 0;
  List<QueryDocumentSnapshot> downloadedMessages = [];
  bool initLoad = true;
  bool isLoaded = false;
  List<String> chatList = [];
  bool isNewUpdate = false;
  Map<String, dynamic>? data;
  @override

  ////List<ChatData> chats = TempChats().Chats;
  void didChangeDependencies() async {
    await ChatProv().getUpdateNotes().then((value) {
      if (value.isNotEmpty && value != {}) {
        log('new feature setting new data');
        log('new featre testing got data ${value.toString()}');
        isNewUpdate = true;
        data = value;
        navigatorKey.currentState!
            .pushNamed(WhatNewScreen.routename, arguments: value);
      }
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    log('my user id is set ${_auth!.currentUser!.uid}');
    double height = GetScreenSize().screenSize(context).height;
    double width = GetScreenSize().screenSize(context).width;

    return Scaffold(
      body: Center(
        child: Container(
          width: width * 0.92,
          height: height * 0.84,
          // color: Colors.red,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('messages')
                          .where('senderId', isEqualTo: _auth!.currentUser!.uid)
                          .snapshots(),
                      builder: (c3, s3) {
                        if (s3.connectionState == ConnectionState.waiting) {
                          return Container(
                            margin: EdgeInsets.only(right: 10),
                            child: SplashScreenAnimation(
                              splashScreen: Icon(
                                Icons.cloud_download,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          );
                        }
                        return StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('messages')
                                .where('recieverId',
                                    isEqualTo: _auth!.currentUser!.uid)
                                .snapshots(),
                            builder: (c1, s1) {
                              log('aa running first stream builder');
                              if (s1.connectionState ==
                                  ConnectionState.active) {
                                log('aa first stream builder in active');
                                if (s1.hasData) {
                                  log('aa running first stream builder has data');
                                  ChatProv()
                                      .getAllUnreadMessages()
                                      .then((value) {
                                    if (newMessages != value) {
                                      setState(() {
                                        log('aa setting state in first stream builder newmessage');
                                        newMessages = value;
                                      });
                                    }
                                  });
                                  if (initLoad ||
                                      s1.data!.docs.length !=
                                          downloadedMessages.length) {
                                    log('aa running first stream builder downloaded messages = data');
                                    downloadedMessages = s1.data!.docs;
                                    initLoad = false;
                                    // Timer(Duration(milliseconds: 500), () {
                                    //   setState(() {

                                    //   });
                                    // });
                                  }
                                }

                                return FutureBuilder(
                                    future: ChatProv().fetchChatList(),
                                    builder: (c2, s2) {
                                      log('aa running second futurebuilder');
                                      if (s2.connectionState ==
                                          ConnectionState.waiting) {
                                        log('aa running second futurebuilder waiting');

                                        return Container(
                                          margin: EdgeInsets.only(right: 10),
                                          child: SplashScreenAnimation(
                                            splashScreen: Icon(
                                              Icons.error,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        );
                                      }
                                      if (s2.connectionState ==
                                          ConnectionState.done) {
                                        log('aa running second futurebuilder done');
                                        if (s2.hasData) {
                                          log('aa running second futurebuilder done has data');
                                          if (s2.data!.length !=
                                                  chatList.length ||
                                              isLoaded == false) {
                                            log('aa running second futurebuilder chatlength condition');
                                            Future.delayed(
                                                    Duration(milliseconds: 100))
                                                .then((value) {
                                              setState(() {
                                                log('aa setting state in future builder chatList = data is loaded true');
                                                chatList = s2.data!;
                                                isLoaded = true;
                                              });
                                            });
                                          }
                                        }
                                        return StreamBuilder(
                                          stream: ConnectivityChecker(
                                                  interval:
                                                      Duration(seconds: 5))
                                              .stream,
                                          builder: (c0, s0) {
                                            log('aa running third connectivity check builder');
                                            if (s0.connectionState ==
                                                ConnectionState.waiting) {
                                              log('aa running third connectivity check builder waiting');
                                              return Container(
                                                margin:
                                                    EdgeInsets.only(right: 10),
                                                child: Icon(
                                                  Icons.cloud_download,
                                                  size: 20,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              );
                                            }

                                            if (s0.connectionState ==
                                                ConnectionState.active) {
                                              log('aa running third connectivity check builder active');
                                              // Timer(Duration(seconds: 1), () {
                                              //   ChatProv()
                                              //       .isFirebaseOn(context);
                                              // });

                                              if ((s0.data as bool) == true &&
                                                  (s0.data as bool) != null) {
                                                log('aa running third connectivity check builder has data true');
                                                if (s0.data != isOnline) {
                                                  log('aa running third connectivity check builder saved isonline is different');
                                                  Timer(Duration(seconds: 1),
                                                      () {
                                                    setState(() {
                                                      log('aa setting state in third connectivity builder isOnline true');
                                                      isOnline = s0.data!;
                                                    });
                                                  });
                                                }
                                                return Container(
                                                  margin: EdgeInsets.only(
                                                      right: 10),
                                                  child: Icon(
                                                    Icons.cloud_done,
                                                    size: 20,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                );
                                              }
                                              if (s0.data != true ||
                                                  s0.data! == null) {
                                                if (isOnline != s0.data) {
                                                  Timer(Duration(seconds: 1),
                                                      () {
                                                    setState(() {
                                                      log('aa setting state in third stream connectivity builder is online false');
                                                      isOnline = false;
                                                    });
                                                  });
                                                }
                                              }
                                            }

                                            return Container(
                                              margin:
                                                  EdgeInsets.only(right: 10),
                                              child: Icon(
                                                  Icons.cloud_off_outlined,
                                                  size: 20,
                                                  color: Colors.red),
                                            );
                                          },
                                        );
                                      }
                                      return Container(
                                        margin: EdgeInsets.only(right: 10),
                                        child: SplashScreenAnimation(
                                          splashScreen: Icon(
                                            Icons.cloud_done,
                                            size: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                          ),
                                        ),
                                      );
                                    });
                              }
                              if (s1.connectionState ==
                                  ConnectionState.waiting) {
                                log('aa running first stream builder waiting');
                                return Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: SplashScreenAnimation(
                                    splashScreen: Icon(
                                      Icons.cloud_download,
                                      size: 20,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                );
                              }
                              return Container(
                                margin: EdgeInsets.only(right: 10),
                                child: SplashScreenAnimation(
                                  splashScreen: Icon(
                                    Icons.cloud_done,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              );
                            });
                      },
                    ),
                    if (newMessages > 0)
                      SplashScreenAnimation(
                        splashScreen: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            newMessages > 1
                                ? '${newMessages} Unread Messages'
                                : '${newMessages} Unread Message',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ),
                    if (newMessages == 0)
                      Text(
                        'Messages',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                  ],
                ),
                if (isOnline)
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    height: height * 0.77,
                    width: double.infinity,
                    child: RefreshIndicator(
                        onRefresh: refreshPage,
                        child: !isLoaded
                            ? Center(
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Center(
                                        // child: CircularProgressIndicator(
                                        //   strokeAlign: -3,
                                        //   strokeCap: StrokeCap.round,
                                        //   strokeWidth: 5,
                                        // ),
                                        child: LoadingAnimationWidget
                                            .threeRotatingDots(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          size: height * 0.04,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Organizing your Chats 👷',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
                                    ]),
                              )
                            : isLoaded && chatList.length != 0
                                ? ListView.builder(
                                    itemCount: chatList.length,
                                    itemBuilder: (context, index) =>
                                        ChatTile(userId: chatList[index]))
                                : Center(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                        Text(
                                          'Time to say your first Hi 🤩',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 23,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Start a new chat from bottom right button',
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ]))),
                  ),
                if (!isOnline)
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    height: height * 0.77,
                    width: double.infinity,
                    child: Center(
                      child: SplashScreenAnimation(
                        splashScreen: Text(
                          'Connection issue 😿',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => SearchUserBox());
        },
        child: isLoaded && chatList.length != 0
            ? Icon(LucideIcons.messageSquare)
            : SplashScreenAnimation(splashScreen: Icon(Icons.add)),
      ),
    );
  }
}
