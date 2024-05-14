import 'package:convo_connect_chat_app/widgets/updates_list.dart';
import 'package:flutter/material.dart';

class UpdatesScreen extends StatefulWidget {
  static const routeName = '/updatesScreen';
  const UpdatesScreen({super.key});

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen>
    with AutomaticKeepAliveClientMixin<UpdatesScreen> {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: UpdatesList(),
    );
  }
}
