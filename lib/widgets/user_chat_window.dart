import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:convo_connect_chat_app/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';

class UserChatWindow extends StatefulWidget {
  Map<String, dynamic> userDetails;
  String auth;
  String myAvatar;
  UserChatWindow(
      {required this.userDetails, required this.auth, required this.myAvatar});

  @override
  State<UserChatWindow> createState() => _UserChatWindowState();
}

class _UserChatWindowState extends State<UserChatWindow> {
  bool checkIsMe(Map<String, dynamic> doc) {
    if (doc['senderId'] == widget.auth) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    double height = GetScreenSize().screenSize(context).height;
    double width = GetScreenSize().screenSize(context).width;
    return Container(
      height: height * 0.8,
      width: double.infinity,
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('messages')
              .orderBy('time', descending: true)
              .snapshots(),
          builder: (context, snapShot) {
            if (snapShot.connectionState == ConnectionState.waiting) {
              return Center(
                  // child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Text(
                  //         'Updating ',
                  //         style: TextStyle(
                  //             fontWeight: FontWeight.bold,
                  //             fontSize: 30,
                  //             color: Theme.of(context)
                  //                 .colorScheme
                  //                 .primary),
                  //       ),
                  //       CircularProgressIndicator(
                  //         strokeAlign: -4,
                  //         strokeCap: StrokeCap.round,
                  //       )
                  //     ]),
                  );
            }
            var filteredDocs = snapShot.data!.docs.where((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return (data['senderId'] == widget.userDetails['userId'] &&
                      data['recieverId'] == widget.auth) ||
                  (data['recieverId'] == widget.userDetails['userId'] &&
                      data['senderId'] == widget.auth);
            }).toList();
            log('filter doc length is : ${filteredDocs.length.toString()}');
            return ListView.builder(
                reverse: true,
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) => MessageBubble(
                      time: filteredDocs[index].data()['time'],
                      avatar: widget.userDetails['userImageUrl']!,
                      message: filteredDocs[index].data()['message'],
                      translatedmsg:
                          filteredDocs[index].data()['translatedmsg'] ?? '',
                      isMe: checkIsMe(filteredDocs[index].data()),
                      myAvatar: widget.myAvatar,
                      isMsg: filteredDocs[index].data()['isMsg'],
                      chatId: filteredDocs[index].data()['chatId'],
                      isRead: filteredDocs[index].data()['isRead'],
                    ));
          }),
    );
  }
}
