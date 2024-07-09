import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:convo_connect_chat_app/helpers/screen_size.dart';

import 'package:convo_connect_chat_app/providers/auth_form_provider.dart';
import 'package:convo_connect_chat_app/providers/chat_provider_logic.dart';
import 'package:convo_connect_chat_app/widgets/change_name_dialog.dart';
import 'package:convo_connect_chat_app/widgets/upload_photo.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = '/profile-page';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  @override
  void didChangeDependencies() {
    ChatProv().getMyDetails().then((value) {
      myData = value;
      AuthFormProv().getLanguages().then((value) {
        languages = value as List<String>;
        ChatProv().getLanguageName(myData['prefLang']).then((value) {
          myLang = value;
          setState(() {
            isDataLoaded = true;
          });
        });
      });
    });
    super.didChangeDependencies();
  }

  void changeState() {
    log('CHANGING STATE');
    setState(() {});
    initState;

    //  Navigator.of(context).pushReplacementNamed(ProfilePage.routeName);
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLangTapped = false;
  List<String> languages = [];
  String myLang = '';
  bool isDataLoaded = false;
  String? selectedLanguage;
  Map<String, dynamic> myData = {};

  @override
  Widget build(BuildContext context) {
    final double height = GetScreenSize().screenSize(context).height;
    final double width = GetScreenSize().screenSize(context).width;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Update Profile',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary),
          ),
          centerTitle: true,
        ),
        body: isDataLoaded
            ? Container(
                height: height,
                width: width,
                // color: Colors.red,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          width: (height * width) * 0.0005,
                          height: (height * width) * 0.0005,
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('registeredUsers')
                                .where('userId',
                                    isEqualTo: _auth.currentUser!.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  snapshot.connectionState ==
                                      ConnectionState.done) {
                                return Container();
                              }
                              return Stack(fit: StackFit.expand, children: [
                                Container(
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(1),
                                        borderRadius:
                                            BorderRadius.circular(100)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image(
                                          fit: BoxFit.cover,
                                          image: snapshot.data!.docs.first
                                                              .data()[
                                                          'userImageUrl'] !=
                                                      '' &&
                                                  snapshot.data!.docs.first
                                                              .data()[
                                                          'userImageUrl'] !=
                                                      null
                                              ? CachedNetworkImageProvider(
                                                  snapshot.data!.docs.first
                                                      .data()['userImageUrl'])
                                              : AssetImage(
                                                      'assets/images/no_user.png')
                                                  as ImageProvider),
                                    )),
                                Positioned(
                                    bottom: 1,
                                    right: 1,
                                    child: GestureDetector(
                                      onTap: () {
                                        log('tapped');
                                        showDialog(
                                            context: context,
                                            builder: (context) => UploadPhoto(
                                                  userId: myData['myId'] ?? '',
                                                  previousImage:
                                                      myData['myImageUrl'] ??
                                                          '',
                                                  changeState: changeState,
                                                ));
                                      },
                                      child: Icon(
                                        LucideIcons.edit,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        size: 25,
                                      ),
                                    )),
                              ]);
                            },
                          ),
                        ),
                        SizedBox(
                          height: height * 0.04,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 25, right: 25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.personStanding,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 5),
                                    child: Text(
                                      myData['myName'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 23,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => ChangeNameDialog());
                                },
                                child: Icon(
                                  LucideIcons.pencil,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: height * 0.01,
                        ),
                        SizedBox(
                          width: width * 0.6,
                          child: Divider(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        SizedBox(
                          height: height * 0.01,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 25, right: 25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.languages,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 5),
                                    child: Text(
                                      myLang,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 23,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      useSafeArea: true,
                                      showDragHandle: true,
                                      elevation: 5,
                                      context: context,
                                      builder: (context) => StatefulBuilder(
                                            builder: (context, setState) =>
                                                Container(
                                                    width: double.infinity,
                                                    child: ListView.builder(
                                                        itemCount:
                                                            languages.length,
                                                        itemBuilder:
                                                            (context, index) =>
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      isLangTapped =
                                                                          true;
                                                                    });
                                                                    showTopSnackBar(
                                                                      Overlay.of(
                                                                          context),
                                                                      CustomSnackBar
                                                                          .info(
                                                                        textStyle:
                                                                            TextStyle(color: Colors.black),
                                                                        message:
                                                                            "Changing to ${languages[index]}",
                                                                      ),
                                                                    );
                                                                    selectedLanguage =
                                                                        languages[
                                                                            index];
                                                                    AuthFormProv()
                                                                        .updateLanguage(
                                                                            selectedLanguage!)
                                                                        .then(
                                                                            (value) {
                                                                      Timer(
                                                                          Duration(
                                                                              milliseconds: 500),
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      });
                                                                    }).then((value) {
                                                                      myLang =
                                                                          selectedLanguage!;
                                                                      setState(
                                                                          () {
                                                                        isLangTapped =
                                                                            false;
                                                                      });
                                                                      changeState();
                                                                      showTopSnackBar(
                                                                        Overlay.of(
                                                                            context),
                                                                        CustomSnackBar
                                                                            .success(
                                                                          textStyle:
                                                                              TextStyle(color: Colors.black),
                                                                          message:
                                                                              "Language Updated to ${selectedLanguage}",
                                                                        ),
                                                                      );
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    margin: EdgeInsets.only(
                                                                        top: 15,
                                                                        left:
                                                                            35,
                                                                        right:
                                                                            35),
                                                                    height: 50,
                                                                    decoration: BoxDecoration(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .primary,
                                                                        borderRadius:
                                                                            BorderRadius.circular(50)),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        languages[
                                                                            index],
                                                                        style: TextStyle(
                                                                            color:
                                                                                Theme.of(context).colorScheme.onPrimary,
                                                                            fontWeight: FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ))),
                                          ));
                                },
                                child: Icon(
                                  LucideIcons.hand,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: height * 0.01,
                        ),
                        SizedBox(
                          width: width * 0.5,
                          child: Divider(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 20, bottom: 30),
                      child: Center(
                        child: Text(
                          softWrap: true,
                          'More Edits are coming soon 😀',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              )
            : Center(
                child: LoadingAnimationWidget.threeRotatingDots(
                  color: Theme.of(context).colorScheme.primary,
                  size: height * 0.06,
                ),
              ));
  }
}
