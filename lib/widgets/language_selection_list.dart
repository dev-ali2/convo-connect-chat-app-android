import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LanguageSelectionList extends StatefulWidget {
  const LanguageSelectionList({super.key});

  @override
  State<LanguageSelectionList> createState() => _LanguageSelectionListState();
}

class _LanguageSelectionListState extends State<LanguageSelectionList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      height: 50,
      width: 50,
      color: Colors.black,
    ));
  }
}
