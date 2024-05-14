import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convo_connect_chat_app/helpers/screen_size.dart';
import 'package:convo_connect_chat_app/providers/auth_form_provider.dart';
import 'package:convo_connect_chat_app/providers/auth_provider.dart';
import 'package:convo_connect_chat_app/screens/chats_screen.dart';
import 'package:convo_connect_chat_app/screens/otp_verification_screen.dart';
import 'package:convo_connect_chat_app/widgets/custom_sized_box.dart';
import 'package:convo_connect_chat_app/widgets/language_selection_list.dart';
import 'package:convo_connect_chat_app/widgets/reset_password_dialog.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AuthenticationForm extends StatefulWidget {
  const AuthenticationForm({super.key});

  @override
  State<AuthenticationForm> createState() => _AuthenticationFormState();
}

class _AuthenticationFormState extends State<AuthenticationForm> {
  String selectedLanguage = 'Select your Chat language!';
  List<String> languages = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<AuthFormProv>(context).getLanguages();
    languages = Provider.of<AuthFormProv>(context).getLanguage;
  }

  @override
  Map<String, String> _userData = {
    'name': '',
    'email': '',
    'password': '',
  };

  void showBottomSheet() async {
    final result = await showModalBottomSheet<String>(
        elevation: 10,
        useSafeArea: true,
        enableDrag: true,
        showDragHandle: true,
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setState) => Container(
                width: double.infinity,
                child: ListView.builder(
                    itemCount: languages.length,
                    itemBuilder: (context, index) => GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedLanguage = languages[index];
                              Navigator.of(context).pop(languages[index]);
                            });
                          },
                          child: Container(
                            margin:
                                EdgeInsets.only(top: 15, left: 35, right: 35),
                            height: 50,
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(50)),
                            child: Center(
                              child: Text(
                                languages[index],
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )),
              ),
            ));
    if (result != null) {
      setState(() {
        selectedLanguage = result;
      });
    }
  }

  void saveData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (isLogin) {
        setState(() {
          _isLoading = true;
        });
        String response =
            await Provider.of<AuthFormProv>(context, listen: false)
                .login(_userData['email']!, _userData['password']!);

        if (response == 'userloggedin') {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pushReplacementNamed(ChatsScreen.routeName);
          return;
        }
        if (response == 'invalidemail') {
          setState(() {
            _isLoading = false;
          });
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.error(
              message: "Invalid Email Address 🧐",
            ),
          );

          return;
        }

        if (response == 'otpnotverified') {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  OtpVerificationScreen(email: _userData['email']!)));
          return;
        }
        if (response != 'otpnotverified' &&
            response != 'userloggedin' &&
            response != 'invalidemail') {
          setState(() {
            _isLoading = false;
          });
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.error(
              message: response,
            ),
          );
        }
      }
      if (!isLogin && selectedLanguage == 'Select your Chat language!') {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.success(
            message: "Please tell us your awesome language 😀",
          ),
        );
        return;
      }
      if (!isLogin && selectedLanguage != 'Select your Chat language!') {
        log('got here!');
        setState(() {
          _isLoading = true;
        });
        bool response = await Provider.of<AuthFormProv>(context, listen: false)
            .singup(_userData['name']!, _userData['email']!,
                _userData['password']!, selectedLanguage);
        log('got here2');
        if (response) {
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.success(
              textStyle: TextStyle(color: Colors.black),
              message: "Awesome 🥳, Please proceed to login now",
            ),
          );
          await Timer(Duration(seconds: 1), () {
            setState(() {
              _isLoading = false;

              isLogin = true;
            });
          });
        }
        if (!response) {
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.error(
              message: "Something not right here, please retry 🤔",
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  final TextEditingController _confirmPassController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool isLogin = true;
  bool showPass = false;
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    double height = GetScreenSize().screenSize(context).height;
    double width = GetScreenSize().screenSize(context).width;
    return Center(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
        height: isLogin ? height * 0.55 : height * 0.75,
        width: width * 0.9,
        child: Container(
          decoration: BoxDecoration(
              // border: Border.all(color: Theme.of(context).colorScheme.primary),
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(1),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                    color: Theme.of(context).colorScheme.primary,
                    blurRadius: 5,
                    spreadRadius: 0.1)
              ]),
          child: SingleChildScrollView(
            child: Container(
              height: isLogin ? height * 0.55 : height * 0.75,
              width: width * 0.9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                    child: Column(
                      children: [
                        CustomSizedBox(
                          height: height * 0.02,
                          width: width,
                        ),
                        Icon(
                          isLogin
                              ? LucideIcons.logIn
                              : LucideIcons.personStanding,
                          size: height * 0.06,
                        ),
                        CustomSizedBox(
                          height: height * 0.005,
                          width: width,
                        ),
                        Text(
                          isLogin ? 'Login' : 'Register',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Container(
                          child: Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  if (!isLogin)
                                    TextFormField(
                                      key: ValueKey('name'),
                                      onSaved: (newValue) =>
                                          _userData['name'] = newValue!.trim(),
                                      validator: (value) {
                                        if (value!.length < 3) {
                                          return 'Enter at least 3 characters';
                                        }
                                        if (value.length > 15) {
                                          return 'Max length is 15!';
                                        }
                                      },
                                      autocorrect: true,
                                      decoration: InputDecoration(
                                          label: Text('Your Full Name'),
                                          alignLabelWithHint: true,
                                          prefixIcon: Icon(LucideIcons.cat),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20))),
                                    ),
                                  if (!isLogin)
                                    CustomSizedBox(
                                        height: height * 0.02, width: width),
                                  TextFormField(
                                    key: ValueKey('email'),
                                    keyboardType: TextInputType.emailAddress,
                                    onSaved: (newValue) =>
                                        _userData['email'] = newValue!.trim(),
                                    decoration: InputDecoration(
                                        label: isLogin
                                            ? Text('Email')
                                            : Text('Your Email'),
                                        alignLabelWithHint: true,
                                        prefixIcon: Icon(LucideIcons.mail),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20))),
                                  ),
                                  CustomSizedBox(
                                      height: height * 0.02, width: width),
                                  TextFormField(
                                    key: ValueKey('password'),
                                    obscureText: !isLogin
                                        ? true
                                        : showPass
                                            ? false
                                            : true,
                                    validator: (value) {
                                      if (_confirmPassController.text !=
                                              value &&
                                          !isLogin) {
                                        return 'Passwords dont match';
                                      }
                                    },
                                    onSaved: (newValue) =>
                                        _userData['password'] =
                                            newValue!.trim(),
                                    decoration: InputDecoration(
                                        label: isLogin
                                            ? Text('Password')
                                            : Text('Set password'),
                                        prefixIcon: isLogin
                                            ? showPass
                                                ? Icon(LucideIcons.eye)
                                                : Icon(LucideIcons.eyeOff)
                                            : Icon(LucideIcons.eyeOff),
                                        alignLabelWithHint: true,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20))),
                                  ),
                                  if (!isLogin)
                                    CustomSizedBox(
                                        height: height * 0.02, width: width),
                                  if (!isLogin)
                                    TextFormField(
                                      key: ValueKey('cpassword'),
                                      obscureText: true,
                                      autocorrect: false,
                                      controller: _confirmPassController,
                                      decoration: InputDecoration(
                                          label: Text('Confirm Password'),
                                          prefixIcon: isLogin
                                              ? showPass
                                                  ? Icon(LucideIcons.eye)
                                                  : Icon(LucideIcons.eyeOff)
                                              : Icon(LucideIcons.eyeOff),
                                          alignLabelWithHint: true,
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20))),
                                    ),
                                  CustomSizedBox(
                                      height: height * 0.01, width: width),
                                  if (isLogin)
                                    Row(
                                      children: [
                                        Checkbox(
                                            value: showPass,
                                            onChanged: (e) {
                                              setState(() {
                                                showPass = e!;
                                              });
                                            }),
                                        Text('Show password'),
                                      ],
                                    ),
                                  if (!isLogin)
                                    TextButton.icon(
                                        icon: Icon(LucideIcons.list),
                                        onPressed: () {
                                          showBottomSheet();
                                        },
                                        label: Text(
                                          selectedLanguage,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                  if (_isLoading)
                                    CircularProgressIndicator(
                                      strokeAlign: -3,
                                      strokeCap: StrokeCap.round,
                                      strokeWidth: 5,
                                    ),
                                  if (!_isLoading)
                                    ElevatedButton.icon(
                                        onPressed: () {
                                          saveData();
                                        },
                                        icon: isLogin
                                            ? Icon(LucideIcons.logIn)
                                            : Icon(LucideIcons.personStanding),
                                        label: isLogin
                                            ? Text('Login')
                                            : Text('Register')),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      if (isLogin)
                                        TextButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      ResetPasswordDialog());
                                            },
                                            child: Text(
                                              'Reset Password!',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            )),
                                      TextButton(
                                          onPressed: () {
                                            setState(() {
                                              isLogin = !isLogin;
                                            });
                                          },
                                          child: isLogin
                                              ? Text('New here?',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))
                                              : Text('Back to login?',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
