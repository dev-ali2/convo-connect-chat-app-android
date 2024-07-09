import 'dart:async';
import 'dart:developer';

import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:convo_connect_chat_app/main.dart';
import 'package:convo_connect_chat_app/providers/auth_provider_logic.dart';
import 'package:convo_connect_chat_app/screens/chats_screen.dart';
import 'package:convo_connect_chat_app/widgets/theme_container.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

MaterialColor lightColor = Colors.cyan;
MaterialColor darkColor = Colors.cyan;

class CustomThemeData {
  ThemeData lightTheme =
      ThemeData(brightness: Brightness.light, colorSchemeSeed: lightColor);
  ThemeData darkTheme =
      ThemeData(brightness: Brightness.dark, colorSchemeSeed: darkColor);
}

class SelectTheme extends StatelessWidget {
  void setTheme(int index) {
    lightColor = colors[index];
    darkColor = colors[index];
    AuthProv()
        .setTheme(index)
        .then((value) => Timer(Duration(milliseconds: 500), () {
              runApp(MyApp());
            }));
  }

  List<MaterialColor> colors = [
    Colors.cyan,
    Colors.amber,
    Colors.pink,
    Colors.purple,
    Colors.deepOrange,
    Colors.green,
    Colors.brown,
  ];
  List<String> colorNames = [
    'Cyan',
    'Amber',
    'Pink',
    'Purple',
    'Orange',
    'Green',
    'Brown'
  ];
  @override
  Widget build(BuildContext context) {
    double height = GetScreenSize().screenSize(context).height;
    double width = GetScreenSize().screenSize(context).width;

    return Container(
      // height: height * 0.6,
      width: double.infinity,
      child: GridView.builder(
        itemCount: colors.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 0),
        itemBuilder: (context, index) => InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            setTheme(index);
            Timer(Duration(milliseconds: 500), () {
              Navigator.of(context).pop();
            });
            showTopSnackBar(
              dismissDirection: [
                DismissDirection.up,
                DismissDirection.startToEnd,
                DismissDirection.endToStart,
                DismissDirection.horizontal
              ],
              Overlay.of(context),
              CustomSnackBar.success(
                backgroundColor: colors[index],
                message: "Applying this Color 🤩",
              ),
            );
          },
          splashColor: colors[index].withOpacity(1),
          child: Container(
            child: ThemeContainer(
              color: colors[index],
              colorName: colorNames[index],
            ),
          ),
        ),
      ),
    );
  }
}
