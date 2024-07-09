import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:convo_connect_chat_app/providers/chat_provider_logic.dart';
import 'package:convo_connect_chat_app/widgets/delete_message_dialog.dart';
import 'package:convo_connect_chat_app/widgets/image_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MessageBubble extends StatefulWidget {
  String time;
  String avatar;
  String message;
  bool isMe;
  String myAvatar;
  bool isMsg;
  String chatId;
  bool isRead;
  String translatedmsg;

  MessageBubble(
      {required this.time,
      required this.avatar,
      required this.message,
      required this.isMe,
      required this.myAvatar,
      required this.isMsg,
      required this.chatId,
      required this.isRead,
      required this.translatedmsg,
      Key? key})
      : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool msgSelected = false;
  bool showingDate = false;
  bool showMyTranslation = false;
  @override
  Widget build(BuildContext context) {
    final _auth = FirebaseAuth.instance.currentUser!.uid;
    double height = GetScreenSize().screenSize(context).height;
    double width = GetScreenSize().screenSize(context).width;
    log('using bubble');
    return GestureDetector(
      onTap: () {
        if (!widget.isMsg) {
          showDialog(
              context: context,
              builder: (context) => ImageViewer(imageUrl: widget.message));
          return;
        }
        if (widget.isMsg) {
          if (widget.isMe) {
            setState(() {
              showMyTranslation = !showMyTranslation;
            });
          }
          setState(() {
            msgSelected = false;
            showingDate = !showingDate;
          });
          return;
        }
      },
      onLongPress: () {
        if (widget.isMe) if (widget.isMsg) {
          if (msgSelected) {
            setState(() {
              msgSelected = false;
              return;
            });
          }
          setState(() {
            msgSelected = true;
            showingDate = true;
          });
          return;
        }
        if (widget.isMe) if (!widget.isMsg) {
          showDialog(
              context: context,
              builder: (context) => DeleteMessageDialog(
                  message: widget.message,
                  chatId: widget.chatId,
                  isMsg: widget.isMsg));
        }
      },
      child: Stack(
        children: [
          Row(
            children: [
              if (!widget.isMe)
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5)),
                  width: 25,
                  height: 25,
                  margin: EdgeInsets.only(
                    left: 10,
                    top: 0,
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: widget.avatar == ''
                          ? Image.asset(
                              'assets/images/no_user.png',
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              widget.avatar,
                              fit: BoxFit.cover,
                            )),
                ),
              if (!widget.isMe)
                Container(
                    margin: EdgeInsets.only(top: 20, left: 15),
                    padding: EdgeInsets.only(left: 20, right: 20, top: 8),
                    height: widget.isMsg ? null : 300,
                    width: !widget.isMsg ? 220 : null,
                    decoration: BoxDecoration(
                        color: widget.isMsg
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                            bottomLeft: Radius.circular(30)),
                        image: !widget.isMsg
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image:
                                    CachedNetworkImageProvider(widget.message),
                              )
                            : null),
                    child: widget.isMsg
                        ? Column(mainAxisSize: MainAxisSize.min, children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.translatedmsg != '')
                                  Container(
                                    margin: EdgeInsets.only(right: 5),
                                    child: Icon(
                                      Icons.message,
                                      size: 15,
                                      applyTextScaling: true,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                Text(
                                  widget.message,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            if (widget.translatedmsg != '')
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 5),
                                    child: Icon(
                                      LucideIcons.languages,
                                      size: 15,
                                      applyTextScaling: true,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                  Text(
                                    widget.translatedmsg,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                                margin: EdgeInsets.only(bottom: 5),
                                child: Row(
                                  children: [
                                    if (showingDate)
                                      Text(
                                        DateFormat('dd/MM/yy  ').format(
                                            DateTime.parse(widget.time)),
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            fontSize: 11),
                                      ),
                                    Text(
                                      DateFormat('hh:mm a')
                                          .format(DateTime.parse(widget.time)),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          fontSize: 11),
                                    ),
                                  ],
                                )),
                          ])
                        : null),
            ],
          ),
          if (false)
            Positioned(
                top: 17,
                right: 10,
                child: Container(
                  width: 30,
                  height: 30,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: widget.myAvatar == ''
                          ? Image.asset('assets/images/no_user.png')
                          : Image.network(widget.myAvatar)),
                )),
          if (widget.isMe)
            Positioned(
                child: Align(
              alignment: Alignment.bottomRight,
              child: Container(
                  margin:
                      EdgeInsets.only(top: 10, right: 15, bottom: 10, left: 15),
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 8),
                  height: widget.isMsg ? null : 300,
                  width: !widget.isMsg ? 220 : null,
                  decoration: BoxDecoration(
                      color: widget.isMsg
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.3),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30),
                          topLeft: Radius.circular(30),
                          bottomLeft: Radius.circular(30)),
                      image: !widget.isMsg
                          ? DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(widget.message))
                          : null),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (msgSelected)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  msgSelected = false;
                                });
                                showDialog(
                                    context: context,
                                    builder: (context) => DeleteMessageDialog(
                                        message: widget.message,
                                        chatId: widget.chatId,
                                        isMsg: widget.isMsg));
                              },
                              child: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),
                            SizedBox(
                              width: width * 0.03,
                            ),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    msgSelected = false;
                                  });
                                },
                                child: Icon(
                                  Icons.cancel,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  size: 30,
                                ))
                          ],
                        ),
                      if (msgSelected)
                        SizedBox(
                          height: height * 0.02,
                        ),
                      if (widget.isMsg)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showMyTranslation && widget.translatedmsg != '')
                              Container(
                                margin: EdgeInsets.only(right: 5),
                                child: Icon(
                                  Icons.message,
                                  size: 15,
                                  applyTextScaling: true,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            Text(
                              widget.message,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      SizedBox(
                        height: 4,
                      ),
                      if (showMyTranslation && widget.translatedmsg != '')
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 5),
                              child: Icon(
                                LucideIcons.languages,
                                size: 15,
                                applyTextScaling: true,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            Text(
                              widget.translatedmsg,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      SizedBox(width: width * 0.05),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              if (msgSelected)
                                Text(
                                  DateFormat('dd/MM/yy  ')
                                      .format(DateTime.parse(widget.time)),
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 11),
                                ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.translatedmsg != '' &&
                                      !showingDate)
                                    Container(
                                      margin: EdgeInsets.only(right: 5),
                                      child: Icon(
                                        LucideIcons.languages,
                                        size: 15,
                                        applyTextScaling: true,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  Text(
                                    DateFormat('hh:mm a')
                                        .format(DateTime.parse(widget.time)),
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontSize: 11),
                                  ),
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          widget.isRead
                              ? Icon(
                                  Icons.done_all,
                                  size: 15,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                )
                              : Icon(
                                  Icons.done,
                                  size: 15,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                        ],
                      )
                    ],
                  )),
            ))
        ],
      ),
    );
  }
}
