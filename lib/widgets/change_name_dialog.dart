import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:convo_connect_chat_app/providers/chat_provider_logic.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ChangeNameDialog extends StatefulWidget {
  @override
  State<ChangeNameDialog> createState() => _ChangeNameDialogState();
}

class _ChangeNameDialogState extends State<ChangeNameDialog> {
  bool changingName = false;
  TextEditingController _name = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final double height = GetScreenSize().screenSize(context).height;
    final double width = GetScreenSize().screenSize(context).width;
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0),
      body: Center(
        child: Container(
          height: height * 0.4,
          width: width * 0.9,
          decoration: BoxDecoration(
              border:
                  Border.all(color: Theme.of(context).colorScheme.secondary),
              borderRadius: BorderRadius.circular(30),
              color: Theme.of(context).colorScheme.onPrimary),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                child: Text(
                  'Edit your Name',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                ),
              ),
              Container(
                  width: width * 0.7,
                  child: TextField(
                      controller: _name,
                      decoration: InputDecoration(
                          hintText: 'Name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))))),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.red,
                      ),
                      label: Text('Cancel')),
                  if (!changingName)
                    ElevatedButton.icon(
                        onPressed: () {
                          if (_name.text.length < 3) {
                            showTopSnackBar(
                                Overlay.of(context),
                                CustomSnackBar.info(
                                    message: 'Name is too short'));
                            return;
                          }
                          if (_name.text.length > 15) {
                            showTopSnackBar(
                                Overlay.of(context),
                                CustomSnackBar.info(
                                    message:
                                        'Name length exceeded 15 Alphabets'));
                            return;
                          }
                          setState(() {
                            changingName = true;
                          });
                          ChatProv()
                              .changeName(_name.text.trim())
                              .then((value) {
                            {
                              showTopSnackBar(Overlay.of(context),
                                  CustomSnackBar.success(message: value));
                              changingName = false;

                              Navigator.of(context).pop();
                              return;
                            }
                          });
                        },
                        icon: Icon(LucideIcons.edit),
                        label: Text('Save')),
                  if (changingName)
                    LoadingAnimationWidget.threeRotatingDots(
                      color: Theme.of(context).colorScheme.primary,
                      size: height * 0.04,
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
