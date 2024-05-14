import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GetScreenSize {
  Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }
}
