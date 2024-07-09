import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:convo_connect_chat_app/providers/auth_provider_logic.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class LogoutConfirmDialog extends StatefulWidget {
  @override
  State<LogoutConfirmDialog> createState() => _LogoutConfirmDialogState();
}

class _LogoutConfirmDialogState extends State<LogoutConfirmDialog>
    with TickerProviderStateMixin {
  late Animation<double> fadeAnim;
  late AnimationController fadeAnimController;

  @override
  void initState() {
    super.initState();
    fadeAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: fadeAnimController, curve: Curves.easeIn));
    fadeAnimController.forward();
  }

  @override
  Widget build(BuildContext context) {
    double height = GetScreenSize().screenSize(context).height;
    double width = GetScreenSize().screenSize(context).width;
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0),
      body: Center(
        child: ScaleTransition(
          scale: fadeAnim,
          child: Container(
            height: (height * width) * 0.0006,
            width: (height * width) * 0.00089,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Theme.of(context).colorScheme.onPrimary,
              // boxShadow: [
              //   BoxShadow(
              //       color: Theme.of(context).colorScheme.primary,
              //       blurRadius: 7,
              //       spreadRadius: 1)
              // ]
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Confirm ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22)),
                        Text(
                          'Logout',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text('Please confirm your action !'),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                            onPressed: () {
                              fadeAnimController
                                  .reverse()
                                  .then((value) => Navigator.of(context).pop());
                            },
                            icon: Icon(
                              Icons.cancel,
                            ),
                            label: Text('Cancel')),
                        SizedBox(
                          width: 15,
                        ),
                        ElevatedButton.icon(
                            onPressed: () {
                              fadeAnimController.reverse().then(
                                  (value) => AuthProv().signoutUser(context));
                            },
                            icon: Icon(
                              LucideIcons.logOut,
                              color: Colors.red,
                            ),
                            label: Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ))
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
