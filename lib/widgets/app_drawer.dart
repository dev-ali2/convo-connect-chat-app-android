import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:convo_connect_chat_app/animations/splash_screen_anim.dart';

import 'package:convo_connect_chat_app/helpers/screen_size.dart';

import 'package:convo_connect_chat_app/providers/chat_provider_logic.dart';
import 'package:convo_connect_chat_app/screens/developer_info.dart';
import 'package:convo_connect_chat_app/screens/profile_page.dart';
import 'package:convo_connect_chat_app/screens/report_page.dart';
import 'package:convo_connect_chat_app/screens/settings_page.dart';
import 'package:convo_connect_chat_app/widgets/custom_sized_box.dart';
import 'package:convo_connect_chat_app/widgets/logout_confirm_dialog.dart';

import 'package:flutter/material.dart';

import 'package:lucide_icons/lucide_icons.dart';

class AppDrawer extends StatelessWidget {
  //List<ChatData> chats = TempChats().Chats;

  @override
  Widget build(BuildContext context) {
    // String loggedInUserName = Provider.of<AuthFormProv>(context).getUserName;
    // String loggedInUserImage = Provider.of<AuthFormProv>(context).getUserImage;

    double width = GetScreenSize().screenSize(context).width;
    double height = GetScreenSize().screenSize(context).height;

    return SafeArea(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            CustomSizedBox(height: height * 0.02, width: 0),
            FutureBuilder(
              future: ChatProv().getMyDetails(),
              builder: (c1, s1) {
                if (s1.connectionState == ConnectionState.waiting) {
                  return SplashScreenAnimation(
                    splashScreen: Center(
                        child: Container(
                      width: (width * height) * 0.00043,
                      height: (height * width) * 0.00043,
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(100)),
                    )),
                  );
                }
                return Center(
                    child: Container(
                        width: (width * height) * 0.00043,
                        height: (height * width) * 0.00043,
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(100)),
                        child: s1.data!['myImageUrl'] != ''
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: CachedNetworkImage(
                                  imageUrl: s1.data!['myImageUrl'],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                ))
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.asset(
                                  'assets/images/no_user.png',
                                  fit: BoxFit.cover,
                                ))));
              },
            ),
            CustomSizedBox(height: height * 0.001, width: width),
            FutureBuilder(
                future: ChatProv().getMyDetails(),
                builder: (c2, s2) {
                  if (s2.connectionState == ConnectionState.waiting) {
                    return SplashScreenAnimation(
                      splashScreen: Center(
                        child: Text(
                          'Loading...',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: Text(
                      s2.data!['myName'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  );
                }),
            CustomSizedBox(height: height * 0.02, width: width),
            Column(
              children: [
                InkWell(
                  onTap: () {
                    Timer(Duration(milliseconds: 500), () {
                      Navigator.of(context)
                          .popAndPushNamed(ProfilePage.routeName);
                    });
                  },
                  splashColor: Theme.of(context).colorScheme.primary,
                  child: ListTile(
                    leading: Icon(
                      Icons.face_5,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      'Profile',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Update your Profile',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Timer(Duration(milliseconds: 500), () {
                      Navigator.of(context).pushNamed(settingsPage.routeName);
                    });
                  },
                  splashColor: Theme.of(context).colorScheme.primary,
                  child: ListTile(
                    leading: Icon(LucideIcons.settings2,
                        color: Theme.of(context).colorScheme.primary),
                    title: Text(
                      'Settings',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Edit app Settings',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Timer(Duration(milliseconds: 500), () {
                      Navigator.of(context).pushNamed(ReportPage.routeName);
                    });
                  },
                  splashColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  child: ListTile(
                    leading: Icon(Icons.warning_amber_rounded,
                        color: Theme.of(context).colorScheme.primary),
                    title: Text(
                      'Report',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Send a bug report',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Timer(Duration(milliseconds: 500), () {
                      Navigator.of(context).pushNamed(developerInfo.routeName);
                    });
                  },
                  splashColor: Theme.of(context).colorScheme.primary,
                  child: ListTile(
                    leading: Icon(LucideIcons.badgeInfo,
                        color: Theme.of(context).colorScheme.primary),
                    title: Text(
                      'About',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'App info',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    // Provider.of<AuthProv>(context, listen: false)
                    //     .signoutUser(context);
                    Timer(Duration(milliseconds: 300), () {
                      Navigator.of(context).pop();
                    });
                    Timer(Duration(milliseconds: 500), () {
                      showDialog(
                          context: context,
                          builder: (context) => LogoutConfirmDialog());
                    });
                  },
                  splashColor: Theme.of(context).colorScheme.primary,
                  child: ListTile(
                    leading: Icon(LucideIcons.logOut, color: Colors.red),
                    title: Text(
                      'Logout',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ));
  }
}
