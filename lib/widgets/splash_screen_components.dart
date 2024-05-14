import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SplashScreenComponents extends StatelessWidget {
  String status;
  bool needProgressIndicator;
  SplashScreenComponents(
      {required this.status, required this.needProgressIndicator});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                  image: AssetImage('assets/images/trans_app_icon.png'))),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            needProgressIndicator
                ? Center(
                    child:
                        // CircularProgressIndicator(
                        //   strokeAlign: -3,
                        //   strokeCap: StrokeCap.round,
                        //   strokeWidth: 5,
                        // ),
                        LoadingAnimationWidget.threeRotatingDots(
                      color: Theme.of(context).colorScheme.primary,
                      size: 30,
                    ),
                  )
                : Container(),
            SizedBox(
              width: 5,
            ),
            Text(
              status,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ],
        )
      ]),
    );
  }
}
