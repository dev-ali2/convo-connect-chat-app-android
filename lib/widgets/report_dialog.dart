import 'dart:async';

import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:convo_connect_chat_app/providers/chat_provider_logic.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ReportDialog extends StatelessWidget {
  TextEditingController email = TextEditingController();
  TextEditingController report = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double height = GetScreenSize().screenSize(context).height;
    double width = GetScreenSize().screenSize(context).width;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height * 0.02,
            ),
            Text(
              'Describe your issue 😕',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: height * 0.02,
            ),
            Container(
              width: width * 0.8,
              child: TextField(
                controller: email,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)),
                    hintText: 'Contact Email'),
              ),
            ),
            SizedBox(
              height: height * 0.02,
            ),
            Container(
              width: width * 0.8,
              child: TextField(
                controller: report,
                maxLines: 6,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)),
                    hintText: 'Issue Details'),
              ),
            ),
            SizedBox(
              height: height * 0.02,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    label: Text('Cancel')),
                ElevatedButton.icon(
                    onPressed: () {
                      if (email.text.length < 6 || !email.text.contains('@')) {
                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.error(
                            message: "Please enter a valid email 😕",
                          ),
                        );
                        return;
                      }
                      if (report.text.length < 10) {
                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.error(
                            message: "Report is too short 😕",
                          ),
                        );
                        return;
                      }
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.info(
                          message: "Trying to send report 🧐",
                        ),
                      );

                      ChatProv()
                          .sendReport(report.text.trim(), email.text.trim())
                          .then((value) {
                        if (value) {
                          showTopSnackBar(
                            Overlay.of(context),
                            CustomSnackBar.success(
                              textStyle: TextStyle(color: Colors.black),
                              message: "We received your report 👍",
                            ),
                          );
                          Navigator.of(context).pop();
                          return;
                        }
                        if (!value) {
                          showTopSnackBar(
                            Overlay.of(context),
                            CustomSnackBar.error(
                              message: "Report sending failed 😿",
                            ),
                          );
                          return;
                        }
                      });
                    },
                    icon: Icon(Icons.done),
                    label: Text('Send'))
              ],
            )
          ],
        ),
      ),
    );
  }
}
