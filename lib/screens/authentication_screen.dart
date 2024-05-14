import 'package:convo_connect_chat_app/widgets/authentication_form.dart';
import 'package:flutter/material.dart';

class AuthenticatioScreen extends StatefulWidget {
  static const routeName = '/authScreen';
  const AuthenticatioScreen({super.key});

  @override
  State<AuthenticatioScreen> createState() => _AuthenticatioScreenState();
}

class _AuthenticatioScreenState extends State<AuthenticatioScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: Text(
          'Authentication',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: AuthenticationForm(),
    );
  }
}
