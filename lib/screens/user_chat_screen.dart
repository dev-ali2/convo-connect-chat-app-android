import 'dart:async';

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convo_connect_chat_app/animations/splash_screen_anim.dart';
import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:convo_connect_chat_app/providers/chat_provider_logic.dart';
import 'package:convo_connect_chat_app/screens/chat_user_details_screen.dart';
import 'package:convo_connect_chat_app/widgets/chat_bubble.dart';

import 'package:convo_connect_chat_app/widgets/custom_sized_box.dart';
import 'package:convo_connect_chat_app/widgets/send_image_dialog.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:internet_connectivity_checker/internet_connectivity_checker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

import 'package:top_snackbar_flutter/top_snack_bar.dart';

class UserChatScreen extends StatefulWidget {
  static const routeName = '/userChatScreen';

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  String userLang = '';
  String myLang = '';

  double width = 0;
  double height = 0;
  String _auth = '';
  String myavatar = '';
  String memberSince = '';

  @override
  void initState() {
    _auth = FirebaseAuth.instance.currentUser!.uid;
    ChatProv().setMyDetails().then((value) {
      myavatar = ChatProv().myData['myImageUrl']!;
    });

    super.initState();
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.preventDefault();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    height = GetScreenSize().screenSize(context).height;
    width = GetScreenSize().screenSize(context).width;
  }

  Map<String, dynamic> userDetails = {};
  int noOfTries = 0;
  bool canUseAPI = false;
  bool initialDataLoaded = false;
  bool loadingUserDetails = false;
  bool recieveInNative = false;
  bool openingSheet = false;
  bool sendInNative = false;
  bool isSending = false;
  bool isOnline = true;
  String myLanguage = '';
  List<QueryDocumentSnapshot<Map<String, dynamic>>> chatList = [];

  TextEditingController _message = TextEditingController();
  @override
  Widget build(BuildContext context) {
    bool checkIsMe(Map<String, dynamic> doc) {
      if (doc['senderId'] == _auth) {
        return true;
      }
      return false;
    }

    userDetails =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    log('Got user details from search : ${userDetails.toString()}');
    return Scaffold(
        // backgroundColor: Theme.of(context).colorScheme.onPrimary,
        appBar: AppBar(
          // backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  width: width * 0.65,
                  child: GestureDetector(
                    onTap: () {
                      if (isOnline) {
                        setState(() {
                          loadingUserDetails = true;
                        });
                        Provider.of<ChatProv>(context, listen: false)
                            .getLanguageName(userDetails['prefLang'])
                            .then((value) {
                          userLang = value;
                        }).then((value) => ChatProv()
                                .getUserRegistrationDate(userDetails['userId'])
                                .then((value) => memberSince = value)
                                .then((value) => setState(() {
                                      loadingUserDetails = false;
                                    }))
                                .then((value) => showModalBottomSheet(
                                      isScrollControlled: true,
                                      // showDragHandle: true,
                                      useSafeArea: true,
                                      context: context,
                                      builder: (context) {
                                        return ChatUserDetailScreen(
                                          userDetails: userDetails,
                                          userLang: userLang,
                                          memberSince: memberSince,
                                        );
                                      },
                                    )));
                      }
                    },
                    child: !loadingUserDetails
                        ? Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.5),
                                backgroundImage: userDetails['userImageUrl'] !=
                                        ''
                                    ? NetworkImage(userDetails['userImageUrl']!)
                                        as ImageProvider
                                    : AssetImage('assets/images/no_user.png'),
                                radius: height * 0.025,
                              ),
                              CustomSizedBox(height: 0, width: width * 0.020),
                              Container(
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.only(top: 5),
                                child: Container(
                                  width: width * 0.37,
                                  child: Text(
                                    userDetails['userName']!,
                                    softWrap: true,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: width * 0.005,
                              ),
                            ],
                          )
                        : SplashScreenAnimation(
                            splashScreen: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: userDetails['userImageUrl'] !=
                                        ''
                                    ? NetworkImage(userDetails['userImageUrl']!)
                                        as ImageProvider
                                    : AssetImage('assets/images/no_user.png'),
                                radius: height * 0.025,
                              ),
                              CustomSizedBox(height: 0, width: width * 0.020),
                              Container(
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.only(top: 5),
                                child: Container(
                                  width: width * 0.37,
                                  child: Text(
                                    userDetails['userName']!,
                                    softWrap: true,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: width * 0.005,
                              ),
                            ],
                          )),
                  ),
                ),
                Container(
                  width: width * 0.005,
                  height: height * 0.005,
                  margin: EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: StreamBuilder(
                      stream:
                          ConnectivityChecker(interval: Duration(seconds: 5))
                              .stream,
                      builder: (c, s) {
                        Timer(Duration(seconds: 30), () {
                          ChatProv().amIblocked(_auth, context);
                        });
                        Timer(Duration(seconds: 30), () {
                          ChatProv().isFirebaseOn(context);
                        });

                        if (s.hasData && (s.data as bool) == true) {
                          if (isOnline == false) {
                            Timer(Duration(milliseconds: 100), () {
                              setState(() {
                                isOnline = true;
                                isSending = false;
                                openingSheet = false;
                              });
                            });
                          }
                          return StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('messages')
                                .orderBy('time', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Icon(
                                  Icons.cloud_sync_sharp,
                                  color: Colors.yellow,
                                  size: 15,
                                );
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.active) {
                                var filteredChats =
                                    snapshot.data!.docs.where((doc) {
                                  Map<String, dynamic> data =
                                      doc.data() as Map<String, dynamic>;
                                  return (data['senderId'] ==
                                              userDetails['userId'] &&
                                          data['recieverId'] == _auth) ||
                                      (data['recieverId'] ==
                                              userDetails['userId'] &&
                                          data['senderId'] == _auth);
                                }).toList();
                                log('chat list length is : ${chatList.length.toString()}');
                                if (!initialDataLoaded ||
                                    filteredChats.length != chatList.length ||
                                    filteredChats.first.data()['isRead'] !=
                                        chatList.first.data()['isRead'] ||
                                    filteredChats.last.data()['isRead'] !=
                                        chatList.last.data()['isRead']) {
                                  chatList = filteredChats;
                                  ChatProv().markAsRead(userDetails['userId']);
                                  Timer(Duration(milliseconds: 500), () {
                                    setState(() {
                                      initialDataLoaded = true;
                                    });
                                  });
                                }
                                if (chatList.length != filteredChats.length) {
                                  log('chat length not same');
                                }
                                if (chatList.length == filteredChats.length) {
                                  log('chat length is same');
                                }

                                return Icon(
                                  Icons.cloud_done_rounded,
                                  color: Colors.green,
                                  size: 15,
                                );
                              }
                              return Icon(
                                Icons.cloud_sync_sharp,
                                color: Colors.yellow,
                                size: 15,
                              );
                            },
                          );
                        }
                        if (s.connectionState == ConnectionState.waiting) {
                          return Icon(
                            Icons.cloud_off,
                            color: Colors.red,
                            size: 15,
                          );
                        }
                        if (isOnline == true) {
                          Timer(Duration(seconds: 10), () {
                            if (isOnline == true && s.data != false)
                              setState(() {
                                isOnline = false;
                              });
                          });
                        }

                        return Icon(
                          Icons.cloud_off,
                          color: Colors.red,
                          size: 15,
                        );
                      }),
                ),
              ]),
              Row(children: [
                GestureDetector(
                  onTap: () {
                    if (isOnline) {
                      setState(() {
                        openingSheet = true;
                      });

                      Provider.of<ChatProv>(context, listen: false)
                          .getLanguageName(userDetails['prefLang']!)
                          .then((value) {
                        userLang = value;
                      }).then((value) {
                        ChatProv().amIUsingNative(userDetails['userId']!).then(
                          (value) {
                            recieveInNative = value;
                            ChatProv().getMyLanguage().then((value) {
                              myLanguage = value;
                            }).then(
                                (value) => ChatProv()
                                        .checkAPIpermissions()
                                        .then((value) {
                                      canUseAPI = value;
                                      ChatProv()
                                          .getNoOFTranslations()
                                          .then((value) {
                                        if (value == null || value == 0) {
                                          noOfTries = 0;
                                        }
                                        noOfTries = value;
                                        setState(() {
                                          openingSheet = false;
                                        });
                                        showModalBottomSheet(
                                            isScrollControlled: true,
                                            backgroundColor:
                                                Colors.black.withOpacity(0),
                                            context: context,
                                            builder: (context) => Container(
                                                  height: height * 0.25,
                                                  child: StatefulBuilder(
                                                    builder:
                                                        (BuildContext context,
                                                                StateSetter
                                                                    setState) =>
                                                            ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(30),
                                                              topLeft: Radius
                                                                  .circular(
                                                                      30)),
                                                      child: Scaffold(
                                                        // backgroundColor: Theme.of(context)
                                                        //     .colorScheme
                                                        //     .onPrimary
                                                        //     .withOpacity(1),
                                                        body: Container(
                                                          width: width,
                                                          height: height * 0.5,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 20,
                                                                  left: 15,
                                                                  right: 15),
                                                          //color: Colors.red,
                                                          child: Column(
                                                            children: [
                                                              Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          'Send messages in their language ',
                                                                          style: TextStyle(
                                                                              color: Theme.of(context).colorScheme.primary,
                                                                              fontSize: 16),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              height * 0.005,
                                                                        ),
                                                                        Container(
                                                                            // width:
                                                                            //     width * 0.4,
                                                                            // child:
                                                                            //     Text(
                                                                            //   '${userLang}',
                                                                            //   softWrap:
                                                                            //       true,
                                                                            //   style: TextStyle(
                                                                            //       color: Theme.of(context).colorScheme.primary,
                                                                            //       fontWeight: FontWeight.w900,
                                                                            //       fontSize: 20),
                                                                            // ),
                                                                            ),
                                                                      ],
                                                                    ),
                                                                    if (canUseAPI)
                                                                      Switch(
                                                                          value:
                                                                              sendInNative,
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              sendInNative = value;
                                                                              log(sendInNative.toString());
                                                                            });
                                                                          }),
                                                                    if (!canUseAPI)
                                                                      Switch(
                                                                          value:
                                                                              false,
                                                                          onChanged:
                                                                              null)
                                                                  ]),
                                                              Divider(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary,
                                                              ),
                                                              Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          'Recieve messages in your language ',
                                                                          style: TextStyle(
                                                                              color: Theme.of(context).colorScheme.primary,
                                                                              fontSize: 16),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              height * 0.005,
                                                                        ),
                                                                        Container(
                                                                            // width:
                                                                            //     width * 0.4,
                                                                            // child:
                                                                            //     Text(
                                                                            //   softWrap:
                                                                            //       true,
                                                                            //   '${myLanguage}',
                                                                            //   style: TextStyle(
                                                                            //       color: Theme.of(context).colorScheme.primary,
                                                                            //       fontWeight: FontWeight.w900,
                                                                            //       fontSize: 20),
                                                                            // ),
                                                                            ),
                                                                      ],
                                                                    ),
                                                                    if (canUseAPI)
                                                                      Switch(
                                                                          value:
                                                                              recieveInNative,
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              recieveInNative = value;
                                                                              log(recieveInNative.toString());
                                                                              ChatProv().setMyNativeLanguage(recieveInNative, userDetails['userId']!);
                                                                            });
                                                                          }),
                                                                    if (!canUseAPI)
                                                                      Switch(
                                                                          value:
                                                                              false,
                                                                          onChanged:
                                                                              null)
                                                                  ]),
                                                              Divider(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary,
                                                              ),
                                                              if (!canUseAPI)
                                                                IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      showDialog(
                                                                          context:
                                                                              context,
                                                                          builder: (context) =>
                                                                              Dialog(
                                                                                child: Container(
                                                                                  height: height * 0.3,
                                                                                  width: width,
                                                                                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.onPrimary, borderRadius: BorderRadius.circular(30)),
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Center(
                                                                                        child: Text(
                                                                                          'Sorry 😕',
                                                                                          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 23),
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        height: height * 0.005,
                                                                                      ),
                                                                                      Container(
                                                                                        margin: EdgeInsets.only(left: 15, right: 15),
                                                                                        child: Text(
                                                                                          'Your account do not have permissions to use this feature',
                                                                                          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18),
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        height: 5,
                                                                                      ),
                                                                                      Container(
                                                                                        margin: EdgeInsets.only(left: 15, right: 15),
                                                                                        child: Text(
                                                                                          'Please contact developer in this regard ',
                                                                                          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 15),
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        height: height * 0.015,
                                                                                      ),
                                                                                      ElevatedButton(
                                                                                          onPressed: () {
                                                                                            Navigator.of(context).pop();
                                                                                          },
                                                                                          child: Text(
                                                                                            'OK',
                                                                                            style: TextStyle(fontSize: 18),
                                                                                          ))
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ));
                                                                    },
                                                                    icon: Icon(
                                                                      LucideIcons
                                                                          .info,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .error,
                                                                    )),
                                                              if (canUseAPI)
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          top:
                                                                              5),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .info,
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .primary,
                                                                      ),
                                                                      SizedBox(
                                                                        width: width *
                                                                            0.005,
                                                                      ),
                                                                      Text(
                                                                        softWrap:
                                                                            true,
                                                                        'Translations left : ${noOfTries}',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Theme.of(context).colorScheme.primary),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ));
                                      });
                                    }));
                          },
                        );
                      });
                    }
                  },
                  child: openingSheet
                      ? Center(
                          child: LoadingAnimationWidget.beat(
                          color: Theme.of(context).colorScheme.primary,
                          size: height * 0.03,
                        ))
                      : isOnline
                          ? Icon(
                              LucideIcons.menu,
                              color: Theme.of(context).colorScheme.primary,
                              size: 25,
                            )
                          : Icon(
                              Icons.error,
                              color: Theme.of(context).colorScheme.error,
                              size: 25,
                            ),
                ),
                CustomSizedBox(height: 0, width: width * 0.005)
              ]),
            ],
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    height: height * 0.79,
                    width: double.infinity,
                    child: initialDataLoaded && chatList.length != 0
                        ? ListView.builder(
                            reverse: true,
                            itemCount: chatList.length,
                            itemBuilder: (context, index) => MessageBubble(
                                  key: ValueKey(index),
                                  time: chatList[index].data()['time'],
                                  avatar: userDetails['userImageUrl']!,
                                  message: chatList[index].data()['message'],
                                  translatedmsg:
                                      chatList[index].data()['translatedmsg'] ??
                                          '',
                                  isMe: checkIsMe(chatList[index].data()),
                                  myAvatar: myavatar,
                                  isMsg: chatList[index].data()['isMsg'],
                                  chatId: chatList[index].data()['chatId'],
                                  isRead: chatList[index].data()['isRead'],
                                ))
                        : Center(
                            child: isOnline
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                        Text(
                                          !initialDataLoaded
                                              ? ''
                                              : 'Say Hi 👋 to ${userDetails['userName']}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 30,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                        if (initialDataLoaded == false &&
                                            chatList.length == 0)
                                          // CircularProgressIndicator(
                                          //   strokeAlign: -4,
                                          //   strokeCap: StrokeCap.round,
                                          // )
                                          LoadingAnimationWidget
                                              .threeRotatingDots(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            size: height * 0.06,
                                          )
                                      ])
                                : Text(
                                    'No Internet 😵‍💫 ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                          )),
                if (!isOnline)
                  SplashScreenAnimation(
                    splashScreen: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: width,
                          // margin: EdgeInsets.only(top: 15),
                          //color: Colors.red,
                          height: height * 0.07,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  top: 16,
                                ),
                                child: Text(
                                  'No Internet Connection 😿',
                                  softWrap: true,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                if (isOnline)
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            margin:
                                EdgeInsets.only(top: 10, left: 15, bottom: 0),
                            width: width * 0.7,
                            child: TextField(
                              onTap: () {
                                setState(() {});
                              },
                              controller: _message,
                              minLines: 1,
                              maxLines: 4,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  hintText: ' Message',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  )),
                            )),
                        Container(
                          margin: EdgeInsets.only(top: 10, left: 8),
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) => PopScope(
                                        canPop: false,
                                        child: SendImageDialog(
                                          recieverId: userDetails['userId'],
                                        ),
                                      ));
                            },
                            child: Icon(
                              LucideIcons.image,
                              color: Theme.of(context).colorScheme.primary,
                              size: 30,
                            ),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 10, right: 15),
                            child: isSending
                                ?
                                //  SplashScreenAnimation(
                                //     splashScreen: Container(
                                //       margin: EdgeInsets.only(right: 10, left: 5),
                                //       child: Icon(
                                //         LucideIcons.send,
                                //         color: Colors.green,
                                //         size: 30,
                                //       ),
                                //     ),
                                //   )
                                LoadingAnimationWidget.threeRotatingDots(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: height * 0.04,
                                  )
                                //  CircularProgressIndicator(
                                //     strokeAlign: -3,
                                //     strokeCap: StrokeCap.round,
                                //   )
                                : IconButton(
                                    icon: Icon(
                                      LucideIcons.send,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      if (_message.text != '' &&
                                          _message.text != ' ') {
                                        setState(() {
                                          isSending = true;
                                        });
                                        Provider.of<ChatProv>(context,
                                                listen: false)
                                            .sendMessage(
                                          _message.text.trim(),
                                          userDetails['userId']!,
                                          userDetails['prefLang']!,
                                          sendInNative,
                                        )
                                            .then((value) {
                                          if (value != '') {
                                            showTopSnackBar(
                                                Overlay.of(context),
                                                CustomSnackBar.error(
                                                    message: value));
                                          }
                                          setState(() {
                                            isSending = false;

                                            //Focus.of(context).unfocus();
                                          });
                                        });
                                        _message.clear();
                                      } else {
                                        showTopSnackBar(
                                          Overlay.of(context),
                                          CustomSnackBar.success(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            message:
                                                "Why not write something awesome first? 🤩",
                                          ),
                                        );
                                      }
                                    },
                                  )),
                      ])
              ],
            ),
          ),
        ));
  }
}
