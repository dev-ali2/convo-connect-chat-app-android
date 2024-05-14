import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:convo_connect_chat_app/widgets/logout_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:social_media_buttons/social_media_icons.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class developerInfo extends StatelessWidget {
  static const String routeName = '/developer-info';

  @override
  Widget build(BuildContext context) {
    double height = GetScreenSize().screenSize(context).height;
    double width = GetScreenSize().screenSize(context).width;
    String linkedIn = dotenv.env['DEV_LINKEDIN'] ?? '';
    String github = dotenv.env['DEV_GITHUB'] ?? '';
    String mail = dotenv.env['DEV_EMAIL'] ?? '';
    final temp = Uri(scheme: 'mailto', path: mail);

    List<Widget> options = [
      SizedBox(
        height: height * 0.01,
      ),
      Center(
        child: Container(
          height: height * 0.25,
          width: width * 0.9,
          child: Stack(children: [
            Positioned(
              bottom: 1,
              child: Container(
                height: height * 0.19,
                width: width * 0.9,
                decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Text(
                      'Convo Connect',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 23,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    Text(dotenv.env['APP_VERSION'] ?? '1.0'),
                  ],
                ),
              ),
            ),
            Positioned(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                    width: (height * width) * 0.0003,
                    height: (height * width) * 0.0003,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(100)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image(
                          fit: BoxFit.cover,
                          image:
                              AssetImage('assets/images/trans_app_icon.png')),
                    )),
              ),
            ),
          ]),
        ),
      ),
      SizedBox(
        height: height * 0.04,
      ),
      Center(
        child: Container(
          height: height * 0.22,
          width: width * 0.9,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                margin: EdgeInsets.only(top: height * 0.002),
                child: Row(
                  children: [
                    SizedBox(
                      width: width * 0.04,
                    ),
                    Container(
                        width: (height * width) * 0.0003,
                        height: (height * width) * 0.0003,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image(
                              fit: BoxFit.cover,
                              image: AssetImage(
                                  'assets/images/faceless_avatar.png')),
                        )),
                    SizedBox(
                      width: width * 0.04,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Designed and developed by',
                        ),
                        SizedBox(
                          height: height * 0.005,
                        ),
                        Text(
                          'Ali Raza',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 23,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        SizedBox(
                          height: height * 0.02,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: () {
                                  launchUrl(Uri.parse(linkedIn));
                                },
                                icon: Icon(
                                  SocialMediaIcons.linkedin_squared,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 35,
                                )),
                            IconButton(
                                onPressed: () {
                                  launchUrl(Uri.parse(github));
                                },
                                icon: Icon(
                                  SocialMediaIcons.github_squared,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 35,
                                )),
                            IconButton(
                                onPressed: () {
                                  launchUrl(temp);
                                },
                                icon: Icon(
                                  SocialMediaIcons.google,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 35,
                                )),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Text(
                'Hoping to make this idea to Google one day ❤️',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
      SizedBox(
        height: height * 0.04,
      ),
      Center(
        child: Container(
          height: height * 0.3,
          width: width * 0.9,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: height * 0.009),
                child: TextButton(
                    onPressed: () {
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.success(
                          textStyle: TextStyle(color: Colors.black),
                          message: "Coming soon ",
                        ),
                      );
                    },
                    child: Text('Changelog')),
              ),
              Container(
                margin: EdgeInsets.only(top: height * 0.009),
                child: TextButton(
                    onPressed: () {
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.success(
                          textStyle: TextStyle(color: Colors.black),
                          message: "Coming soon on Playstore ",
                        ),
                      );
                    },
                    child: Text('Rate on playstore')),
              ),
              Container(
                margin: EdgeInsets.only(top: height * 0.009),
                child: TextButton(
                    onPressed: () {
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.success(
                          textStyle: TextStyle(color: Colors.black),
                          message: "Coming soon",
                        ),
                      );
                    },
                    child: Text('Privacy Policy')),
              ),
              Container(
                margin: EdgeInsets.only(top: height * 0.009),
                child: TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (c) => LogoutConfirmDialog());
                    },
                    child: Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    )),
              ),
            ],
          ),
        ),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          height: height,
          width: width,
          child: ListView.builder(
              itemCount: options.length, itemBuilder: (c, i) => options[i]),
        ),
      ),
    );
  }
}
