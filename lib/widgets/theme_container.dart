import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:flutter/material.dart';

class ThemeContainer extends StatelessWidget {
  MaterialColor color;
  String colorName;
  ThemeContainer({required this.color, required this.colorName});

  @override
  Widget build(BuildContext context) {
    double height = GetScreenSize().screenSize(context).height;
    double width = GetScreenSize().screenSize(context).width;
    return Column(
      children: [
        SizedBox(
          height: 15,
        ),
        Container(
          width: (height * width) * 0.00047,
          height: (height * width) * 0.00035,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(color: color, blurRadius: 1, spreadRadius: 1)
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 20, left: 10),
                height: (height * width) * 0.00005,
                width: (height * width) * 0.00035,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(50)),
              ),
              Container(
                margin: EdgeInsets.only(top: 15, left: 10),
                height: (height * width) * 0.00005,
                width: (height * width) * 0.00025,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(50)),
              ),
              Container(
                margin: EdgeInsets.only(top: 15, left: 10),
                height: (height * width) * 0.00005,
                width: (height * width) * 0.00015,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          colorName,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 18),
        )
      ],
    );
  }
}
