import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:convo_connect_chat_app/main.dart';
import 'package:convo_connect_chat_app/providers/auth_form_provider.dart';
import 'package:convo_connect_chat_app/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class UploadPhoto extends StatefulWidget {
  void Function() changeState;
  String userId;
  String previousImage;
  UploadPhoto(
      {required this.userId,
      required this.previousImage,
      required this.changeState});

  @override
  State<UploadPhoto> createState() => _UploadPhotoState();
}

class _UploadPhotoState extends State<UploadPhoto> {
  bool newImagePicked = false;
  bool isUploading = false;
  Future<String> getLatestImage() async {
    var doc = await FirebaseFirestore.instance
        .collection('registeredUsers')
        .where('userId', isEqualTo: widget.userId)
        .get();
    return doc.docs.first.data()['userImageUrl'] ?? '';
  }

  @override
  void ImageProcessing() async {
    newImagePicked = false;
    XFile? temp = await ImagePicker.platform
        .getImageFromSource(source: ImageSource.gallery);
    if (temp != null) {
      log('Got image ${temp.path}');
      setState(() {
        newImagePicked = true;
        pickedImage = File(temp.path);
        imageCache.clear();

        if (widget.previousImage != '') {
          CachedNetworkImage.evictFromCache(widget.previousImage);
        }
      });
    }
  }

  File pickedImage = File('assets/images/no_user.png');
  @override
  Widget build(BuildContext context) {
    log('Got data before uploading  ${widget.userId} ${widget.previousImage} ');
    final double height = GetScreenSize().screenSize(context).height;
    final double width = GetScreenSize().screenSize(context).width;
    return Center(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        width: (height * width) * 0.0009,
        height: !isUploading
            ? (height * width) * 0.00115
            : (height * width) * 0.0006,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        child: Container(
          height: (height * width) * 0.001,
          width: (height * width) * 0.0009,
          child: Column(
            children: [
              SizedBox(
                height: height * 0.02,
              ),
              FutureBuilder(
                future: getLatestImage(),
                builder: (c, s) => Container(
                  width: width * height * 0.00035,
                  height: width * height * 0.00035,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.black.withOpacity(0.3),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: s!.data == '' && newImagePicked == false
                              ? AssetImage('assets/images/no_user.png')
                              : s!.data != '' && newImagePicked == false
                                  ? CachedNetworkImageProvider(s.data!)
                                  : newImagePicked == true
                                      ? FileImage(pickedImage)
                                      : AssetImage('assets/images/no_user.png')
                                          as ImageProvider)),
                ),
              ),
              SizedBox(
                height: height * 0.03,
              ),
              if (!isUploading)
                ElevatedButton.icon(
                    onPressed: ImageProcessing,
                    icon: Icon(LucideIcons.image),
                    label: Text('Select new Image')),
              if (!newImagePicked || !isUploading)
                SizedBox(
                  height: height * 0.01,
                ),
              if (!newImagePicked)
                ElevatedButton.icon(
                    onPressed: () async {
                      showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.success(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              message: 'Please wait... 🧐'));

                      var getDoc = await FirebaseFirestore.instance
                          .collection('registeredUsers')
                          .where('userId', isEqualTo: widget.userId)
                          .get();

                      if (getDoc.docs.first.data()['userImageUrl'] == '' ||
                          getDoc.docs.first.data()['userImageUrl'] == null) {
                        showTopSnackBar(
                            Overlay.of(context),
                            CustomSnackBar.info(
                                message: 'Already no image is set 🧐'));
                        return;
                      }
                      ChatProv().removeProfilePhoto().then((value) {
                        CachedNetworkImage.evictFromCache(widget.previousImage);
                        widget.changeState;
                        showTopSnackBar(Overlay.of(context),
                            CustomSnackBar.success(message: value));

                        Navigator.of(context).pop();
                      });
                    },
                    icon: Icon(
                      Icons.remove,
                      color: Colors.red,
                    ),
                    label: Text(
                      'Remove Photo',
                      style: TextStyle(color: Colors.red),
                    )),
              SizedBox(
                height: height * 0.01,
              ),
              if (!newImagePicked)
                ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.red,
                    ),
                    label: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red),
                    )),
              if (!isUploading)
                SizedBox(
                  height: height * 0.03,
                ),
              if (isUploading)
                // CircularProgressIndicator(
                //   strokeCap: StrokeCap.round,
                //   strokeAlign: 1,
                //   strokeWidth: 7,
                // ),
                LoadingAnimationWidget.threeRotatingDots(
                  color: Theme.of(context).colorScheme.primary,
                  size: height * 0.05,
                ),
              if (!isUploading && newImagePicked == true)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                        label: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        )),
                    SizedBox(
                      width: width * 0.03,
                    ),
                    if (!isUploading)
                      ElevatedButton.icon(
                          onPressed: () {
                            if (pickedImage.path !=
                                'assets/images/no_user.png') {
                              setState(() {
                                isUploading = true;
                              });
                              AuthFormProv()
                                  .updateProfileImage(
                                      widget.userId, pickedImage)
                                  .then((value) {
                                widget.changeState;
                                if (value != 'error') {
                                  log('Image Uploaded');
                                  Navigator.of(context).pop();
                                  // setState(() {
                                  //   isUploading = false;
                                  // });

                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //     SnackBar(

                                  //         elevation: 0,
                                  //         behavior: SnackBarBehavior.floating,
                                  //         backgroundColor: Colors.transparent,
                                  //         content: AwesomeSnackbarContent(

                                  //             title: 'On Snap!',
                                  //             message:
                                  //                 'This is an example error message that will be shown in the body of snackbar!',
                                  //             contentType:
                                  //                 ContentType.success)));
                                  showTopSnackBar(
                                    Overlay.of(context),
                                    CustomSnackBar.success(
                                      textStyle: TextStyle(color: Colors.black),
                                      message:
                                          "Your Image has been uploaded 🥳",
                                    ),
                                  );
                                } else {
                                  log('there is an error uploading image');
                                  setState(() {
                                    isUploading = false;
                                    Navigator.of(context).pop();
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //     SnackBar(
                                    //         content: Text(
                                    //             'Error while uploading your Image')));
                                    showTopSnackBar(
                                      Overlay.of(context),
                                      CustomSnackBar.error(
                                        message:
                                            "Something went wrong while uploading 😿",
                                      ),
                                    );
                                  });
                                }
                              });
                            } else {
                              Navigator.of(context).pop();
                              showTopSnackBar(
                                Overlay.of(context),
                                CustomSnackBar.info(
                                  message: "Why not select an image first? 🤔",
                                ),
                              );
                            }
                          },
                          icon: Icon(LucideIcons.upload),
                          label: Text('Upload')),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
