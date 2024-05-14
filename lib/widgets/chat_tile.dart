import 'dart:async';
import 'dart:developer';

import 'package:convo_connect_chat_app/animations/blinking_anim.dart';
import 'package:convo_connect_chat_app/animations/splash_screen_anim.dart';
import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:convo_connect_chat_app/providers/chat_provider.dart';
import 'package:convo_connect_chat_app/screens/user_chat_screen.dart';
import 'package:convo_connect_chat_app/widgets/empty_chat_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class ChatTile extends StatefulWidget {
  String userId;
  ChatTile({required this.userId});

  @override
  State<ChatTile> createState() => _ChatTileState();
}

var _auth;

class _ChatTileState extends State<ChatTile> {
  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
  }

  bool checkIsMe(Map<String, dynamic> doc) {
    if (doc['senderId'] == _auth) {
      return true;
    }
    return false;
  }

  bool isInitialDataLoaded = false;
  @override
  Widget build(BuildContext context) {
    double width = GetScreenSize().screenSize(context).width;
    Map<String, String> userDetails = {};
    String userLang = '';
    int unreadCount = 0;
    void setUserDetails(String userName, String userEmail, String userId,
        String userImageUrl, String prefLang) {
      if (prefLang != '') {
        userDetails = {
          'userName': userName,
          'userEmail': userEmail,
          'userId': userId,
          'userImageUrl': userImageUrl,
          'prefLang': prefLang
        };
      }
      if (prefLang == '') {
        userDetails = {
          'userName': userName,
          'userEmail': userEmail,
          'userId': userId,
          'userImageUrl': userImageUrl,
          'prefLang': 'en'
        };
      }
    }

    log('Chats with : ${widget.userId}');

    return FutureBuilder(
        future: ChatProv()
            .userUnreadMessages(widget.userId)
            .then((value) => unreadCount = value),
        builder: (context, sna) {
          if (sna.connectionState == ConnectionState.waiting) {
            if (isInitialDataLoaded) return EmptyChatTile();
          }
          return FutureBuilder(
            future: ChatProv().getUserLanguage(widget.userId).then((value) {
              userLang = value;
            }),
            builder: (context, sn) {
              if (sn.connectionState == ConnectionState.waiting) {
                return EmptyChatTile();
              }

              return FutureBuilder(
                  future: Provider.of<ChatProv>(context)
                      .getUserFromDatabase(widget.userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return EmptyChatTile();
                    if (snapshot.connectionState == ConnectionState.done) {
                      Timer(Duration(seconds: 2), () {
                        ChatProv().amIblocked(
                            FirebaseAuth.instance.currentUser!.uid, context);
                      });
                      Timer(Duration(seconds: 2), () {
                        ChatProv().isFirebaseOn(context);
                      });

                      if (snapshot.hasData) {
                        ChatProv().getUserLanguage(widget.userId).then(
                          (value) {
                            userLang = value;
                          },
                        );
                        return Container(
                          margin: EdgeInsets.only(bottom: 15),
                          child: Material(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              splashColor:
                                  Theme.of(context).colorScheme.primary,
                              onTap: () {
                                setUserDetails(
                                    snapshot.data!['userName']!,
                                    snapshot.data!['userEmail']!,
                                    snapshot.data!['userId']!,
                                    snapshot.data!['userImageUrl']!,
                                    snapshot.data!['prefLang']!);
                                ChatProv().markAsRead(widget.userId).then(
                                    (value) => Navigator.of(context).pushNamed(
                                        UserChatScreen.routeName,
                                        arguments: userDetails));
                              },
                              child: ListTile(
                                title: Text(
                                  snapshot.data!['userName']!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19),
                                ),
                                subtitle: Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: FutureBuilder(
                                      future: ChatProv()
                                          .getLatestMessage(widget.userId),
                                      builder: (c0, s0) {
                                        if (s0.connectionState ==
                                            ConnectionState.done) {
                                          String newTemp = '';
                                          if (s0.data != 'Photo' &&
                                              s0.data!.length > 20) {
                                            newTemp = s0.data!.substring(0, 20);
                                            newTemp = newTemp + '...';
                                          }
                                          if (s0.data! == 'Photo' ||
                                              s0.data!.length < 20) {
                                            newTemp = s0.data!;
                                          }
                                          return Container(
                                              child: Row(
                                            children: [
                                              if (s0.data == 'Photo')
                                                Icon(
                                                  LucideIcons.image,
                                                  size: 17,
                                                ),
                                              if (s0.data == 'Photo')
                                                SizedBox(
                                                  width: 5,
                                                ),
                                              Text(
                                                newTemp ?? '',
                                                softWrap: true,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary),
                                              )
                                            ],
                                          ));
                                        }
                                        return BlinkingAnim(
                                          widget: Text(
                                            'Loading...',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                          ),
                                        );
                                      }),
                                ),
                                leading: Container(
                                  height: 60,
                                  width: 60,
                                  margin: EdgeInsets.only(left: 2),
                                  child: CircleAvatar(
                                    backgroundImage: snapshot
                                                    .data!['userImageUrl'] !=
                                                '' &&
                                            snapshot.data!['userImageUrl'] !=
                                                null
                                        ? NetworkImage(
                                                snapshot.data!['userImageUrl']!)
                                            as ImageProvider
                                        : AssetImage(
                                            'assets/images/no_user.png'),
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(7),
                                horizontalTitleGap: 30,
                                trailing: unreadCount != 0
                                    ? Container(
                                        width: 40,
                                        height: 25,
                                        margin: EdgeInsets.only(right: 15),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                        child: Center(
                                          child: Text(
                                            unreadCount.toString(),
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ))
                                    : null,
                              ),
                            ),
                          ),
                        );
                      }
                    }

                    return Center(
                      child: LoadingAnimationWidget.threeRotatingDots(
                        color: Theme.of(context).colorScheme.primary,
                        size: 50,
                      ),
                    );
                  });
            },
          );
        });
  }
}
