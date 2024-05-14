import 'dart:developer';

import 'package:convo_connect_chat_app/widgets/whatsnew_dialog.dart';
import 'package:flutter/material.dart';

class WhatNewScreen extends StatelessWidget {
  static const String routename = '/whatsnew';
  // Map<String, dynamic> data;
  // WhatNewScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    log('new feature got data here is ${data.toString()}');
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Release Notes',
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: WhatNewDialog(data: data));
  }
}
