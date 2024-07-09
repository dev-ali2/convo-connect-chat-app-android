import 'dart:developer';

import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:convo_connect_chat_app/providers/chat_provider_logic.dart';
import 'package:convo_connect_chat_app/screens/user_chat_screen.dart';
import 'package:convo_connect_chat_app/widgets/search_result_dialog.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class SearchUserBox extends StatefulWidget {
  @override
  State<SearchUserBox> createState() => _SearchUserBoxState();
}

class _SearchUserBoxState extends State<SearchUserBox>
    with TickerProviderStateMixin {
  String name = '';

  TextEditingController _searchEmail = TextEditingController();

  bool searchedClicked = false;
  late Animation<double> fadeAnim;
  late AnimationController fadeAnimController;
  @override
  void initState() {
    fadeAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    fadeAnim = Tween<double>(begin: 0, end: 1).animate(fadeAnimController);
    fadeAnimController.forward();
    super.initState();
  }

  @override
  void dispose() {
    fadeAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> searchedUserDetails = {};
    var chatProvider = Provider.of<ChatProv>(context, listen: false);
    double height = GetScreenSize().screenSize(context).height;
    double width = GetScreenSize().screenSize(context).width;
    return FadeTransition(
      opacity: fadeAnim,
      child: Dialog(
        surfaceTintColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        shadowColor: Theme.of(context).colorScheme.primary,
        alignment: Alignment.center,
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(50)),
          height: height * 0.3,
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: EdgeInsets.only(
                          top: height * 0.02, bottom: height * 0.002),
                      child: Text(
                        'Find by Email',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      )),
                  Padding(
                      padding: EdgeInsets.only(top: 0, bottom: height * 0.02),
                      child: Text(
                        'Search will run in Chats and online',
                        style: TextStyle(fontSize: 15),
                      )),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: TextField(
                  controller: _searchEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      hintText: 'Enter Email',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20))),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: height * 0.02,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                        onPressed: () => fadeAnimController
                            .reverse()
                            .then((value) => Navigator.of(context).pop()),
                        icon: Icon(Icons.cancel, color: Colors.red),
                        label: Text('Cancel')),
                    ElevatedButton.icon(
                        label: Text('Find user'),
                        onPressed: () {
                          if (_searchEmail.text == '') {
                            Navigator.of(context).pop();
                            showTopSnackBar(
                              Overlay.of(context),
                              CustomSnackBar.info(
                                message: "No Email was given 😕",
                              ),
                            );
                            return;
                          }
                          searchedClicked = true;

                          fadeAnimController.reverse();
                          chatProvider
                              .searchUserInDatabase(_searchEmail.text.trim())
                              .then((value) {
                            log('value got ${value}');
                            if (value != {}) {
                              searchedUserDetails = value;
                            }
                          }).then((value) {
                            log('searched user details set as ${searchedUserDetails.toString()}');
                            if (searchedUserDetails.isNotEmpty) {
                              name = searchedUserDetails['userName']!;

                              Navigator.of(context).pop();
                              showDialog(
                                  context: context,
                                  builder: (context) => SearchResultDialog(
                                        searchedUserDetails:
                                            searchedUserDetails,
                                      ));
                            }
                            if (searchedUserDetails.isEmpty) {
                              log('got here in popup');
                              Navigator.of(context).pop();
                              showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                        child: Container(
                                          height: height * 0.2,
                                          width: width,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Center(
                                                child: Text(
                                                  'Sorry we did\'nt find them 😕',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 23),
                                                ),
                                              ),
                                              SizedBox(
                                                height: height * 0.025,
                                              ),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    'OK',
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ));
                            }
                          });
                        },
                        icon: Icon(
                          LucideIcons.search,
                          size: 25,
                          color: Theme.of(context).colorScheme.primary,
                        ))
                  ],
                ),
              ),
              SizedBox(
                height: height * 0.01,
              )
            ],
          ),
        ),
      ),
    );
  }
}
