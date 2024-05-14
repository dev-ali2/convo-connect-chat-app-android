import 'dart:async';

import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:convo_connect_chat_app/widgets/select_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class settingsPage extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    double height = GetScreenSize().screenSize(context).height;
    double width = GetScreenSize().screenSize(context).width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          height: height,
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Divider(),
                  InkWell(
                    onTap: () {
                      Timer(Duration(milliseconds: 500), () {
                        showModalBottomSheet(
                            elevation: 5,
                            isScrollControlled: true,
                            showDragHandle: true,
                            useSafeArea: true,
                            context: context,
                            builder: ((context) => SelectTheme()));
                      });
                    },
                    splashColor: Theme.of(context).colorScheme.primary,
                    child: Container(
                        width: width,
                        decoration: BoxDecoration(),
                        child: Center(
                          child: ListTile(
                            leading: Text(
                              'Change Color Scheme',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 18),
                            ),
                            trailing: Icon(
                              LucideIcons.paintbrush,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        )),
                  ),
                  Divider(),
                ],
              ),
              Container(
                width: width,
                margin: EdgeInsets.only(top: 20, bottom: 30),
                child: Center(
                  child: Text(
                    softWrap: true,
                    'More settings are coming soon 😀',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
