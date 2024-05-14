import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:convo_connect_chat_app/widgets/custom_sized_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gradient_animation_text/flutter_gradient_animation_text.dart';

class UpdatesList extends StatefulWidget {
  const UpdatesList({super.key});

  @override
  State<UpdatesList> createState() => _UpdatesListState();
}

class _UpdatesListState extends State<UpdatesList> {
  @override
  Widget build(BuildContext context) {
    double height = GetScreenSize().screenSize(context).height;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Updates',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Theme.of(context).colorScheme.primary),
            ),
            CustomSizedBox(height: 10, width: 0),
            Container(
              height: height * 0.7,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GradientAnimationText(
                      duration: Duration(milliseconds: 4000),
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.onPrimary,
                      ],
                      text: Text(
                        'Feature coming soon ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    Text('😀',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
