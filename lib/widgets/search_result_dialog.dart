import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:convo_connect_chat_app/screens/user_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SearchResultDialog extends StatefulWidget {
  Map<String, dynamic> searchedUserDetails = {};

  SearchResultDialog({required this.searchedUserDetails});

  @override
  State<SearchResultDialog> createState() => _SearchResultDialogState();
}

class _SearchResultDialogState extends State<SearchResultDialog>
    with TickerProviderStateMixin {
  late Animation<double> fadeAnim;
  late AnimationController fadeAnimController;
  @override
  void dispose() {
    fadeAnimController.dispose();
    super.dispose();
  }

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
    return ScaleTransition(
      scale: fadeAnim,
      child: Dialog(
        child: Container(
          height: height * 0.37,
          width: width,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(30)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      'We have brought them 🥳',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    height: height * width * 0.0003,
                    width: height * width * 0.0003,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(100),
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: widget.searchedUserDetails['userImageUrl'] !=
                                    ''
                                ? NetworkImage(
                                    widget.searchedUserDetails['userImageUrl'])
                                : AssetImage('assets/images/no_user.png')
                                    as ImageProvider)),
                  ),
                  Text(
                    widget.searchedUserDetails['userName'],
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                      onPressed: () => fadeAnimController
                          .reverse()
                          .then((value) => Navigator.of(context).pop()),
                      icon: Icon(
                        Icons.cancel,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      label: Text('Close')),
                  // SizedBox(
                  //   width: 25,
                  // ),
                  ElevatedButton.icon(
                      icon: Icon(LucideIcons.messageCircle),
                      onPressed: () {
                        fadeAnimController.reverse().then((value) =>
                            Navigator.of(context).popAndPushNamed(
                                UserChatScreen.routeName,
                                arguments: {
                                  'userName':
                                      widget.searchedUserDetails['userName'],
                                  'userEmail':
                                      widget.searchedUserDetails['userEmail'],
                                  'userId':
                                      widget.searchedUserDetails['userId'],
                                  'userImageUrl': widget
                                      .searchedUserDetails['userImageUrl'],
                                  'prefLang':
                                      widget.searchedUserDetails['prefLang'] ==
                                              ''
                                          ? 'en'
                                          : widget
                                              .searchedUserDetails['prefLang']
                                }));
                      },
                      label: Text('Send Message')),
                ],
              ),
              SizedBox(
                height: height * 0.001,
              )
            ],
          ),
        ),
      ),
    );
  }
}
