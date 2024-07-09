import 'dart:developer';
import 'dart:io';

import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:convo_connect_chat_app/providers/chat_provider_logic.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class SendImageDialog extends StatefulWidget {
  String recieverId;

  SendImageDialog({required this.recieverId});

  @override
  State<SendImageDialog> createState() => _SendImageDialogState();
}

class _SendImageDialogState extends State<SendImageDialog>
    with TickerProviderStateMixin {
  late Animation<double> fadeAnim;
  late AnimationController fadeAnimController;
  @override
  void dispose() {
    fadeAnimController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fadeAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: fadeAnimController, curve: Curves.easeIn));
    fadeAnimController.forward();
  }

  bool isImageSelected = false;
  bool isSending = false;
  File pickedImage = File('assets/images/loading.png');

  void selectImage(bool isCamera) async {
    isImageSelected = false;
    if (isCamera) {
      XFile? temp = await ImagePicker.platform
          .getImageFromSource(source: ImageSource.camera);
      if (temp != null) {
        log('Got image ${temp.path}');
        setState(() {
          isImageSelected = true;
          pickedImage = File(temp.path);
        });
      }
    }
    if (!isCamera) {
      XFile? temp = await ImagePicker.platform
          .getImageFromSource(source: ImageSource.gallery);
      if (temp != null) {
        log('Got image ${temp.path}');
        setState(() {
          isImageSelected = true;
          pickedImage = File(temp.path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = GetScreenSize().screenSize(context).height;
    double width = GetScreenSize().screenSize(context).width;
    return ScaleTransition(
      scale: fadeAnim,
      child: Center(
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          height: isImageSelected
              ? height * 0.53
              : !isSending
                  ? height * 0.33
                  : height * 0.25,
          width: width * 0.8,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(30)),
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 25),
                child: Text(
                  !isSending ? 'Send Image' : 'Sending your Image',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                      decoration: TextDecoration.none),
                ),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              if (isImageSelected && !isSending)
                Container(
                    height: height * width * 0.0004,
                    width: height * width * 0.0004,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      image: DecorationImage(
                          fit: BoxFit.cover, image: FileImage(pickedImage)),
                    )),
              if (isSending)
                Container(
                    margin: EdgeInsets.only(top: 30),
                    child:
                        // CircularProgressIndicator(
                        //   strokeAlign: 5,
                        //   strokeCap: StrokeCap.round,
                        //   strokeWidth: 7,
                        // ),
                        LoadingAnimationWidget.threeRotatingDots(
                      color: Theme.of(context).colorScheme.primary,
                      size: height * 0.05,
                    )),
              if (isImageSelected)
                SizedBox(
                  height: height * 0.02,
                ),
              if (!isSending)
                Column(
                  children: [
                    ElevatedButton.icon(
                        onPressed: () {
                          selectImage(true);
                        },
                        icon: Icon(LucideIcons.camera),
                        label: Text('Open Camera')),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    ElevatedButton.icon(
                        onPressed: () {
                          selectImage(false);
                        },
                        icon: Icon(LucideIcons.image),
                        label: Text('Select from files')),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    if (!isImageSelected)
                      ElevatedButton.icon(
                          onPressed: () {
                            fadeAnimController
                                .reverse()
                                .then((value) => Navigator.of(context).pop());
                          },
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                          label: Text('Close')),
                    if (!isImageSelected)
                      SizedBox(
                        height: height * 0.02,
                      ),
                  ],
                ),
              if (isImageSelected && !isSending)
                Container(
                  margin: EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                          onPressed: () {
                            fadeAnimController
                                .reverse()
                                .then((value) => Navigator.of(context).pop());
                          },
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                          label: Text('Cancel')),
                      ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isSending = true;
                              isImageSelected = false;
                            });
                            if (pickedImage.path !=
                                'assets/images/loading.png') {
                              ChatProv()
                                  .sendImage(pickedImage, widget.recieverId)
                                  .then((value) {
                                if (value) {
                                  fadeAnimController.reverse().then(
                                      (value) => Navigator.of(context).pop());
                                  showTopSnackBar(
                                    Overlay.of(context),
                                    CustomSnackBar.success(
                                      textStyle: TextStyle(color: Colors.black),
                                      message: "Image sent 🥳",
                                    ),
                                  );
                                }
                                if (!value) {
                                  fadeAnimController.reverse().then(
                                      (value) => Navigator.of(context).pop());
                                  showTopSnackBar(
                                    Overlay.of(context),
                                    CustomSnackBar.error(
                                      message:
                                          "Sorry we were\'nt able to send your image 😿",
                                    ),
                                  );
                                }
                              });
                            }
                            if (pickedImage.path ==
                                'assets/images/loading.png') {
                              Navigator.of(context).pop();
                              showTopSnackBar(
                                Overlay.of(context),
                                CustomSnackBar.info(
                                  message: "Why not select an image first? 🤔",
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            LucideIcons.upload,
                          ),
                          label: Text('Upload'))
                    ],
                  ),
                ),
              SizedBox(
                height: height * 0.015,
              )
            ],
          )),
        ),
      ),
    );
  }
}
