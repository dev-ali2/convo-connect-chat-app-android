import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthFormProv with ChangeNotifier {
  Map<String, String> myData = {
    'myId': '',
    'myEmail': '',
    'myName': '',
    'myImageUrl': '',
    'prefLang': '',
  };
  List<String> gotlangNames = [];
  List<String> gotLanguages = [];
  String loggedInUserName = '';
  String loggedInUserImage = '';
  FirebaseFirestore? db;
  String get getUserName {
    return loggedInUserName.toString();
  }

  String get getUserImage {
    return loggedInUserImage.toString();
  }

  List<String> get getLanguage {
    return gotlangNames;
  }

  Future<String> resetPassword(String email) async {
    try {
      var _auth = await FirebaseAuth.instance;
      await _auth.sendPasswordResetEmail(email: email);
      return 'Please check your email to reset your password';
    } catch (e) {
      return e.toString();
    }
  }

  Future<Map<String, dynamic>> getMyDetails() async {
    log('running getMyDetails from Auth form provider');
    await setMyDetails();
    return myData;
  }

  Future<String> updateProfileImage(String userId, File image) async {
    try {
      String imageUrl = '';
      FirebaseAuth _auth = await FirebaseAuth.instance;
      db = await FirebaseFirestore.instance;
      FirebaseStorage storage = await FirebaseStorage.instance;
      final ref = await storage.ref().child('images').child(userId + '.jpg');
      await ref.putFile(image).whenComplete(() async {
        final url = await ref.getDownloadURL();
        imageUrl = url;
        await setMyDetails();
        db!
            .collection('registeredUsers')
            .where('userId', isEqualTo: userId)
            .get()
            .then((value) => value.docs.forEach((element) {
                  element.reference.update({'userImageUrl': url});
                }));
      });
      notifyListeners();
      return imageUrl;
    } catch (e) {
      log(e.toString());
      return 'error';
    }
  }

  Future<void> updateLanguage(String language) async {
    FirebaseAuth _auth = await FirebaseAuth.instance;
    FirebaseFirestore db = await FirebaseFirestore.instance;
    await getLanguages();
    int index = await gotlangNames.indexWhere((element) => element == language);
    await setMyDetails();
    myData['prefLang'] = gotLanguages[index];
    log('My new data with language is ${myData}');
    db
        .collection('registeredUsers')
        .where('userId', isEqualTo: myData['myId'])
        .get()
        .then((value) {
      value.docs.forEach((element) {
        element.reference.update({'prefLang': myData['prefLang']});
      });
    });
  }

  Future<void> setMyDetails() async {
    log('running setmydetails');
    var _auth = await FirebaseAuth.instance;
    db = await FirebaseFirestore.instance;

    var data = await db!
        .collection('registeredUsers')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .get();
    myData = {
      'myId': data.docs.first.data()['userId'],
      'myEmail': data.docs.first.data()['userEmail'],
      'myName': data.docs.first.data()['userName'],
      'myImageUrl': data.docs.first.data()['userImageUrl'],
      'prefLang': data.docs.first.data()['prefLang'],
    };
    log('my data set');
    log('here is my data : ${myData.toString()}');
    //log(myData.toString());
  }

  Future<List> getLanguages() async {
    gotLanguages.clear();
    gotlangNames.clear();
    db = await FirebaseFirestore.instance;
    var data = await db!.collection('languages').get();
    for (var doc in data.docs) {
      gotlangNames.add(doc.data()['name']);
      gotLanguages.add(doc.data()['language']);
    }
    log('got languages : ${gotLanguages.toString()}');
    log('got languages names : ${gotlangNames.toString()}');
    return gotlangNames;
  }

  Future<bool> singup(
      String name, String email, String password, String language) async {
    var _auth = await FirebaseAuth.instance;
    try {
      db = await FirebaseFirestore.instance;
      var gotData = await db!.collection('disableFirebase').get();
      bool isFirebaseOn = gotData.docs.first.data()['isFirebaseON'];
      if (isFirebaseOn && isFirebaseOn != null && gotData != null) {
        UserCredential _authResult;
        _authResult = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        log(_authResult.toString());
        log(_authResult.user!.uid);
        await getLanguages();
        int index =
            await gotlangNames.indexWhere((element) => element == language);

        final Map<String, dynamic> dataToSave = {
          'userEmail': email,
          'userId': _authResult.user!.uid,
          'userName': name,
          'userImageUrl': '',
          'DateCreated': DateTime.now().toIso8601String(),
          'prefLang': gotLanguages[index],
          'canUseAPI': true,
          'isUserBlocked': false,
          'oneSignalSubId': '',
          'oneSignalUserId': '',
        };
        log('new debig siging up with data ${dataToSave}');

        await db!.collection('registeredUsers').add(dataToSave).then((value) =>
            log('new debug value from firebase ${value.toString()}'));

        final Map<String, dynamic> chatCounts = {
          'userId': dataToSave['userId'],
          'messagesLeft': 15
        };
        await db!.collection('usersTranslatedCount').add(chatCounts).then(
            (value) => log(
                'new debug adding chat count response ${value.toString()}'));
        await FirebaseAuth.instance.signOut();

        return true;
      }
      return false;
    } catch (e) {
      log('new debug siging up error ${e.toString()}');
      return false;
    }
  }

  Future<String> login(String email, String password) async {
    var _auth = await FirebaseAuth.instance;
    try {
      if (email.length < 5 ||
          email == '' ||
          !email.contains('@') ||
          !email.contains('.com')) {
        return 'invalidemail';
      }
      var gotData = await db!.collection('disableFirebase').get();
      bool isFirebaseOn = gotData.docs.first.data()['isFirebaseON'];
      if (isFirebaseOn && isFirebaseOn != null && gotData != null) {
        db = await FirebaseFirestore.instance;
        // var getDoc = await db!
        //     .collection('registeredUsers')
        //     .where('userEmail', isEqualTo: email)
        //     .get();

        UserCredential _authResult;
        _authResult = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        log('new debug sign in function performed ith values ${_authResult.toString()}');

        // bool checkOTPverification = getDoc.docs.first.data()['otpVerified'];
        // if (checkOTPverification == false || checkOTPverification == null) {
        //   await _auth.signOut();
        //   return 'otpnotverified';
        // }
        _auth = await FirebaseAuth.instance;
        if (!_auth.currentUser!.emailVerified) {
          return 'otpnotverified';
        }

        return 'userloggedin';
      }
      return 'cantloginuser';
    } catch (e) {
      log('new debug error in signing in ${e.toString()}');
      if (e.toString().contains(
          '[firebase_auth/invalid-credential] The supplied auth credential is incorrect, malformed or has expired')) {
        return 'No user with these details found';
      }
      return 'Something went wrong, please retry';
    }
  }

  Future<void> readUserDataFromFirebase() async {
    var _auth = await FirebaseAuth.instance;
    db = await FirebaseFirestore.instance;
    log('current user ID from AuthForm/readUserData : ${_auth.currentUser!.uid}');
    var user = await db!
        .collection('registeredUsers')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .get();

    var gotUser = await user.docs.first.data();

    loggedInUserName = gotUser['userName'].toString();
    // log(gotUser['userEmail']);
    // log(gotUser['userName']);
    loggedInUserName = gotUser['userName'].toString();
    loggedInUserImage = gotUser['userImageUrl'].toString();
    // log('set username ${loggedInUserName}');
    //notifyListeners();
    //return gotUser['username'];
  }
}
