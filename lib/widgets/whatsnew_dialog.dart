import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:flutter/material.dart';

class WhatNewDialog extends StatefulWidget {
  Map<String, dynamic> data;
  WhatNewDialog({required this.data});

  @override
  State<WhatNewDialog> createState() => _WhatNewDialogState();
}

class _WhatNewDialogState extends State<WhatNewDialog> {
  @override
  Widget build(BuildContext context) {
    log('new feature 2 data here is ${widget.data.toString()}');
    double width = GetScreenSize().screenSize(context).width;
    double height = GetScreenSize().screenSize(context).height;
    return Center(
      child: Container(
        width: width * 0.9,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                margin: EdgeInsets.only(top: height * 0.02, bottom: 0),
                child: Text(
                  'Whats New 🤔',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: height * width * 0.00008),
                )),
            Container(
                margin:
                    EdgeInsets.only(top: height * 0.01, bottom: height * 0.05),
                child: Text(
                  'Version ${widget.data['version']}',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: height * width * 0.00004),
                )),
            ListView.builder(
                shrinkWrap: true,
                itemCount: (widget.data['whatsNew'] as List).length,
                itemBuilder: (context, index) => Container(
                    width: width * 0.9,
                    margin: EdgeInsets.only(
                        top: height * 0,
                        bottom: height * 0.03,
                        left: height * 0.01,
                        right: height * 0.01),
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      (widget.data['whatsNew'] as List)[index],
                      softWrap: true,
                    )))
          ],
        ),
      ),
    );
  }
}
