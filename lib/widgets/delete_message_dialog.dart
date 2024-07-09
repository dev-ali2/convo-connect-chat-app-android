import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:convo_connect_chat_app/providers/chat_provider_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class DeleteMessageDialog extends StatefulWidget {
  @override
  String message;
  String chatId;
  bool isMsg;

  DeleteMessageDialog(
      {required this.message, required this.chatId, required this.isMsg});

  @override
  State<DeleteMessageDialog> createState() => _DeleteMessageDialogState();
}

class _DeleteMessageDialogState extends State<DeleteMessageDialog> {
  bool isdeleting = false;
  @override
  Widget build(BuildContext context) {
    double height = GetScreenSize().screenSize(context).height;
    double width = GetScreenSize().screenSize(context).width;
    return Center(
      child: Container(
        height: 60,
        width: width * 0.5,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary,
            borderRadius: BorderRadius.circular(40)),
        child: Container(
          width: width * 0.48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                !isdeleting ? 'Unsend' : 'Deleting...',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isdeleting = true;
                  });
                  ChatProv().unsendMessage(widget.chatId).then((value) {
                    if (value) {
                      isdeleting = false;
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.info(
                          message: "Message Unsent 🫢",
                        ),
                      );
                      Navigator.of(context).pop();

                      return;
                    }
                    if (!value) {
                      isdeleting = false;
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.error(
                          message: "Sorry we can\'nt unsend your message 🥲",
                        ),
                      );
                      Navigator.of(context).pop();

                      return;
                    }
                  });
                },
                child: !isdeleting
                    ? Icon(
                        LucideIcons.trash,
                        size: 30,
                        color: Colors.red,
                      )
                    :
                    // : CircularProgressIndicator(
                    //     strokeCap: StrokeCap.round,
                    //     strokeWidth: 6,
                    //     strokeAlign: -1,
                    //   ),
                    LoadingAnimationWidget.threeRotatingDots(
                        color: Theme.of(context).colorScheme.primary,
                        size: height * 0.04,
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
