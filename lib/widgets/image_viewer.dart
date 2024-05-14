import 'package:cached_network_image/cached_network_image.dart';
import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  String imageUrl;
  ImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    double height = GetScreenSize().screenSize(context).height;
    double width = GetScreenSize().screenSize(context).width;
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
          ),
        ),
      ),
    );
  }
}
