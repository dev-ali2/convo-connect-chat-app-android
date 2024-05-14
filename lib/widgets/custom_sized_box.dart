import 'package:flutter/material.dart';

class CustomSizedBox extends StatelessWidget {
  final double? height;
  final double? width;
  const CustomSizedBox({required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
    );
  }
}
