import 'package:convo_connect_chat_app/widgets/report_dialog.dart';
import 'package:flutter/material.dart';

class ReportPage extends StatelessWidget {
  static const String routeName = '/reportPage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Report a bug',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ReportDialog(),
    );
  }
}
