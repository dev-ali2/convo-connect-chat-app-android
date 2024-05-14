import 'package:cached_network_image/cached_network_image.dart';
import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:convo_connect_chat_app/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MyDetails extends StatefulWidget {
  Map<String, dynamic> myData;
  String regDate;
  String lang;
  String myImage;
  MyDetails(
      {required this.myData,
      required this.regDate,
      required this.lang,
      required this.myImage});

  @override
  State<MyDetails> createState() => _MyDetailsState();
}

class _MyDetailsState extends State<MyDetails> with TickerProviderStateMixin {
  late Animation<Offset> Anim;
  late Animation<double> fadeAnim;
  late AnimationController AnimController;

  @override
  void dispose() {
    AnimController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    AnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    Anim = Tween<Offset>(begin: Offset(1, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: AnimController, curve: Curves.easeIn));
    fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: AnimController, curve: Curves.easeIn));
    AnimController.forward();
  }

  @override
  Widget build(BuildContext context) {
    double height = GetScreenSize().screenSize(context).height;
    double width = GetScreenSize().screenSize(context).width;
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0),
      body: Center(
        child: Container(
          height: (height * width) * 0.0016,
          width: (height * width) * 0.0012,
          margin: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(30)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: height * 0.02,
                ),
                Center(
                    child: Text(
                  'Your Profile Card',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27),
                )),
                SizedBox(
                  height: height * 0.03,
                ),
                Center(
                  child: Container(
                      width: (height * width) * 0.0005,
                      height: (height * width) * 0.0005,
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(100)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image(
                            fit: BoxFit.cover,
                            image: widget.myImage != ''
                                ? CachedNetworkImageProvider(widget.myImage)
                                : AssetImage('assets/images/no_user.png')
                                    as ImageProvider),
                      )),
                ),
                SizedBox(
                  height: height * 0.035,
                ),
                Center(
                    child: Text(
                  widget.myData['myName'],
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 27),
                )),
                SizedBox(
                  height: height * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.mail,
                      size: 30,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.myData['myEmail'],
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16),
                    )
                  ],
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.languages),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.lang,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16),
                    )
                  ],
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.clock),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Member Since ${widget.regDate}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16),
                    )
                  ],
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context)
                              .popAndPushNamed(ProfilePage.routeName);
                        },
                        icon: Icon(
                          LucideIcons.badgeInfo,
                        ),
                        label: Text('Edit Profile')),
                    ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.done,
                        ),
                        label: Text('OK')),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
