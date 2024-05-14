import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChatUserDetailScreen extends StatelessWidget {
  Map<String, dynamic> userDetails;
  String userLang;
  String memberSince;
  ChatUserDetailScreen(
      {required this.userDetails,
      required this.userLang,
      required this.memberSince});

  @override
  Widget build(BuildContext context) {
    double height = GetScreenSize().screenSize(context).height;
    double width = GetScreenSize().screenSize(context).width;
    return Container(
      height: height * 0.6,
      width: double.infinity,
      child: SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          Center(
            child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(100)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image(
                      fit: BoxFit.cover,
                      image: userDetails['userImageUrl'] != ''
                          ? NetworkImage(userDetails['userImageUrl'])
                          : AssetImage('assets/images/no_user.png')
                              as ImageProvider),
                )),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
              child: Text(
            userDetails['userName'],
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 27),
          )),
          SizedBox(
            height: 20,
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
                userDetails['userEmail'],
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, fontSize: 16),
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.languages),
              SizedBox(
                width: 10,
              ),
              Text(
                userLang,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, fontSize: 16),
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.clock),
              SizedBox(
                width: 10,
              ),
              Text(
                'Member Since ${memberSince}',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, fontSize: 16),
              )
            ],
          )
        ],
      )),
    );
  }
}
