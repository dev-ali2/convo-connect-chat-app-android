import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:convo_connect_chat_app/providers/auth_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ResetPasswordDialog extends StatelessWidget {
  TextEditingController _email = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final double height = GetScreenSize().screenSize(context).height;
    final double width = GetScreenSize().screenSize(context).width;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0),
      body: Center(
        child: Container(
          height: height * 0.4,
          width: width * 0.9,
          decoration: BoxDecoration(
              border:
                  Border.all(color: Theme.of(context).colorScheme.secondary),
              borderRadius: BorderRadius.circular(30),
              color: Theme.of(context).colorScheme.onPrimary),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                margin: EdgeInsets.only(top: 0),
                child: Text(
                  'Enter your Email',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                ),
              ),
              Container(
                  width: width * 0.7,
                  child: TextField(
                      controller: _email,
                      decoration: InputDecoration(
                          hintText: 'Email',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))))),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.red,
                      ),
                      label: Text('Cancel')),
                  ElevatedButton.icon(
                      onPressed: () {
                        if (_email.text.length < 5) {
                          showTopSnackBar(
                              Overlay.of(context),
                              CustomSnackBar.info(
                                  message: 'Email length is too shot'));
                          return;
                        }
                        if (!_email.text.contains('@') ||
                            !_email.text.contains('.com')) {
                          showTopSnackBar(Overlay.of(context),
                              CustomSnackBar.info(message: 'Invalid Email'));
                          return;
                        }
                        AuthFormProv()
                            .resetPassword(_email.text.trim())
                            .then((value) {
                          if (value ==
                              'Please check your email to reset your password') {
                            showTopSnackBar(
                                Overlay.of(context),
                                CustomSnackBar.success(
                                    message:
                                        'Please check your email to reset your password'));
                            Navigator.of(context).pop();
                            return;
                          }
                          showTopSnackBar(
                              Overlay.of(context),
                              CustomSnackBar.info(
                                  message:
                                      'Something went wrong, please retry'));
                        });
                      },
                      icon: Icon(LucideIcons.mailWarning),
                      label: Text('Proceed to reset')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
