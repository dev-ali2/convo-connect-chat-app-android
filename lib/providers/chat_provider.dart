import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:convo_connect_chat_app/main.dart';
import 'package:convo_connect_chat_app/providers/auth_form_provider.dart';
import 'package:convo_connect_chat_app/providers/auth_provider.dart';
import 'package:convo_connect_chat_app/screens/account_blocked.dart';
import 'package:convo_connect_chat_app/screens/firebase_disabled.dart';
import 'package:convo_connect_chat_app/screens/settings_page.dart';
import 'package:convo_connect_chat_app/screens/splash_screen.dart';
import 'package:convo_connect_chat_app/screens/starter_screen.dart';
import 'package:convo_connect_chat_app/screens/user_chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:googleapis_auth/auth_io.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ChatProv with ChangeNotifier {
  // FirebaseMessaging messaging = FirebaseMessaging.instance;
  // final FlutterLocalNotificationsPlugin localNotifications =
  //     FlutterLocalNotificationsPlugin();
  List<String> gotlangNames = [];
  List<String> gotLanguages = [];
  List<String> finalRecievedChatsUserId = [];
  List<String> finalSentChatsUserId = [];
  Set<String>? _chatsSet;
  List<String> _uniqueChatsList = [];
  QuerySnapshot? sentChats;
  QuerySnapshot? receivedChats;
  FirebaseFirestore? db;
  String searcherdUser = '';
  Map<String, String> selectedUserData = {
    'userId': '',
    'userEmail': '',
    'userName': '',
    'userImageUrl': '',
    'prefLang': '',
  };
  Map<String, String> myData = {
    'myId': '',
    'myEmail': '',
    'myName': '',
    'myImageUrl': '',
    'prefLang': '',
    // 'notificationId': '',
    'oneSignalUserId': '',
    'oneSignalSubId': ''
  };
  List<Map<String, dynamic>> sortedChats = [];

  String get getSearchedUser {
    return searcherdUser;
  }

  List get getChats {
    return _uniqueChatsList;
  }

  String get getMyAvatar {
    return myData['myImageUrl']!;
  }

  bool checkIsMe(Map<String, dynamic> doc, var _auth) {
    if (doc['senderId'] == _auth) {
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> getUpdateNotes() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      db = await FirebaseFirestore.instance;
      var getDoc = await db!.collection('updateNotes').get();
      String version = getDoc.docs.first.data()['version'];
      List whatsNew = getDoc.docs.first.data()['whatsnew'];
      List<String> finalWhatNew =
          await whatsNew.map((e) => e.toString()).toList();
      Map<String, dynamic> dataToReturn = {
        'version': version,
        'whatsNew': finalWhatNew
      };
      // log('new feature version $version');
      // log('new feature whatsnew ${whatsNew}');
      String checkStoredVersion = await prefs.getString('version') ?? '';
      log('new feature, data from hared prefs ${checkStoredVersion}');
      if (checkStoredVersion == '' || checkStoredVersion != version) {
        log('new feature data not same so returning');
        await prefs.setString('version', version);

        log('new feature returning data ${dataToReturn}');
        return dataToReturn;
      }
      if (checkStoredVersion == null ||
          checkStoredVersion == '' ||
          checkStoredVersion == version) {
        log('new feature data is same same so returning nothing');

        return {};
      }
      return {};
    } catch (e) {
      log('new Error ${e.toString()}');
      return {};
    }
  }

  Future<void> sendOneSignalNotification(String userId, String title,
      String body, Map<String, dynamic> payload) async {
    try {
      log('running sendOneSignal Notification');
      var getDoc = await db!
          .collection('registeredUsers')
          .where('userId', isEqualTo: userId)
          .get();
      String oneSignalSubId = getDoc.docs.first.data()['oneSignalSubId'];
      if (oneSignalSubId != '' && oneSignalSubId != null) {
        final url = 'https://onesignal.com/api/v1/notifications';
        var headers = {
          "Content-Type": "application/json",
          "Authorization": dotenv.env['ONESIGNAL_KEY']!
        };
        final jsonBody = await json.encode({
          "app_id": dotenv.env['ONESIGNAL_APP_ID'],
          "include_player_ids": [oneSignalSubId],
          "contents": {"en": body},
          "headings": {"en": title},
          "data": {"id": myData['myId']}
        });

        final response =
            await http.post(Uri.parse(url), headers: headers, body: jsonBody);
        log('One signal respone ${response.body}');
      }
    } catch (e) {
      log('error has been captured ! ${e.toString()}');
    }
  }

  Future<void> initOneSignal() async {
    // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // OneSignal.Debug.setAlertLevel(OSLogLevel.none);
    try {
      String oneSignalSubId = '';
      String oneSignalUserId = '';
      var oneSignalID = await dotenv.env['ONESIGNALID'];
      OneSignal.initialize(oneSignalID!);
      bool checkPermission =
          await OneSignal.Notifications.requestPermission(true);
      if (!checkPermission) {
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      }
      oneSignalUserId = await OneSignal.User.getOnesignalId() ?? '';
      oneSignalSubId = await OneSignal.User.pushSubscription.id ?? '';
      db = await FirebaseFirestore.instance;
      await setMyDetails();
      await db!
          .collection('registeredUsers')
          .where('userId', isEqualTo: myData['myId'])
          .get()
          .then((value) => value.docs.forEach((element) {
                element.reference.update({
                  'oneSignalSubId': oneSignalSubId,
                  'oneSignalUserId': oneSignalUserId
                });
              }));
    } catch (e) {
      log('new debud, one signal init error ${e.toString()}');
    }
  }

  Future<String> getMyProfilePic() async {
    log('running getMyProfilePic');
    await setMyDetails();
    return myData['myImageUrl'] ?? '';
  }

  Future<String> changeName(String newName) async {
    log('running changeName');
    try {
      await setMyDetails();
      db = await FirebaseFirestore.instance;
      await db!
          .collection('registeredUsers')
          .where('userId', isEqualTo: myData['myId'])
          .get()
          .then((value) => value.docs.forEach((element) {
                element.reference.update({'userName': newName});
              }));
      notifyListeners();
      return 'Profile Edited';
    } catch (e) {
      return 'Something went wrong';
    }
  }

  Future<String> removeProfilePhoto() async {
    log('running remove profile photo');
    try {
      await setMyDetails();
      db = await FirebaseFirestore.instance;
      await db!
          .collection('registeredUsers')
          .where('userId', isEqualTo: myData['myId'])
          .get()
          .then((value) => value.docs.forEach((element) {
                element.reference.update({'userImageUrl': ''});
              }));
      notifyListeners();
      return 'done';
    } catch (e) {
      log(e.toString());
      return 'error';
    }
  }

  Future<int> getNoOFTranslations() async {
    log('running getNoOfTranslations');
    await setMyDetails();
    db = await FirebaseFirestore.instance;
    var temp = await db!
        .collection('usersTranslatedCount')
        .where('userId', isEqualTo: myData['myId'])
        .get();
    int noOfTranslations = temp.docs.first.data()['messagesLeft'];

    return noOfTranslations;
  }

  Future<void> isFirebaseOn(BuildContext context) async {
    log('running isFirebaseOn');
    db = await FirebaseFirestore.instance;
    var result = await db!.collection('disableFirebase').get();

    if (result.docs.first.data()['isFirebaseON'] != true ||
        result.docs.first.data()['isFirebaseON'] == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => FirebaseDisabled()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> amIblocked(String myId, BuildContext context) async {
    log('running amIbloced');
    db = await FirebaseFirestore.instance;
    var result = await db!
        .collection('registeredUsers')
        .where('userId', isEqualTo: myId)
        .get();
    if (result.docs.first.data()['isUserBlocked'] != null) {
      if (result.docs.first.data()['isUserBlocked'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AccountBlockedScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  Future<bool> sendReport(String report, String email) async {
    log('running sendReport');
    Map<String, dynamic> gotMyDetails = await getMyDetails();
    db = await FirebaseFirestore.instance;
    Map<String, dynamic> report = {
      'senderName': gotMyDetails['myName'],
      'senderEmail': gotMyDetails['myEmail'],
      'senderId': gotMyDetails['myId'],
      'time': DateFormat('yy/MM/dd').format(DateTime.now()),
      'contactEmail': email.trim()
    };
    try {
      await db!.collection('reports').add(report);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> getLatestMessage(String userId) async {
    log('running get latest message with list length ${sortedChats.length}');
    var _auth = await FirebaseAuth.instance;
    db = await FirebaseFirestore.instance;
    await fetchChatList();
    for (var map in sortedChats) {
      if (map['senderId'] == userId || map['recieverId'] == userId) {
        String checkMessage = map['message'];
        if (checkMessage.startsWith('https://')) {
          return 'Photo';
        }
        bool isMe = checkIsMe(map, _auth.currentUser!.uid);
        log('new feature checking is me ${isMe}');
        if (isMe) {
          return 'You: ${map['message']}';
        }

        return map['message'];
      }
    }
    return '';
  }

  Future<bool> checkAPIpermissions() async {
    Map<String, dynamic> myDetails = await getMyDetails();
    db = await FirebaseFirestore.instance;
    var data = await db!
        .collection('registeredUsers')
        .where('userId', isEqualTo: myData['myId'])
        .get();
    if (data.docs.first.data()['canUseAPI'] == null ||
        data.docs.first.data()['canUseAPI'] == false) {
      return false;
    }
    if (data.docs.first.data()['canUseAPI'] != false &&
        data.docs.first.data()['canUseAPI'] != null) {
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> getMyDetails() async {
    await setMyDetails();
    return myData;
  }

  Future<bool> unsendMessage(String chatId) async {
    log('running unsend message');
    FirebaseAuth _auth = await FirebaseAuth.instance;
    db = await FirebaseFirestore.instance;
    FirebaseStorage storage = await FirebaseStorage.instance;
    await db!
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .get()
        .then((value) => value.docs.forEach((element) {
              element.reference.delete().then((value) {
                return true;
              });
            }));
    return true;
  }

  Future<bool> sendImage(File image, String recieverId) async {
    log('running send Image');

    try {
      FirebaseAuth _auth = await FirebaseAuth.instance;
      db = await FirebaseFirestore.instance;
      FirebaseStorage storage = await FirebaseStorage.instance;
      await setMyDetails();

      final ref = await storage
          .ref()
          .child('msgImages')
          .child('${DateTime.now().toString()}${myData['myId']}' + '.jpg');
      await ref.putFile(image).whenComplete(() async {
        final url = await ref.getDownloadURL();

        await getUserFromDatabase(recieverId);

        final Map<String, dynamic> messageData = await {
          'chatId': '${DateTime.now().toString()}${myData['myId']}',
          'isMsg': false,
          'isRead': false,
          'senderName': myData['myName']!,
          'recieverName': selectedUserData['userName']!,
          'senderId': _auth.currentUser!.uid,
          'recieverId': selectedUserData['userId']!,
          'message': url,
          'senderAvatar': myData['myImageUrl']!,
          'recieverAvatar': selectedUserData['userImageUrl']!,
          'time': DateTime.now().toIso8601String(),
          'senderLang': myData['prefLang']!,
          'recieverLang': selectedUserData['prefLang']!,
        };
        var messageToSend = await db!.collection('messages').add(messageData);
        sendOneSignalNotification(
            messageData['recieverId'],
            myData['myName'] ?? 'New Message',
            messageData['message'].toString().contains('http')
                ? '🖼️ Photo'
                : messageData['message'],
            myData);
        log('time to return true');
        //await fetchChatList();
        return true;
      });
    } catch (e) {
      log(e.toString());

      return false;
    }
    return true;
  }

  Future<String> getUserRegistrationDate(String userId) async {
    log('running getUserRegistrationDate');
    db = await FirebaseFirestore.instance;
    var result1 = await db!
        .collection('registeredUsers')
        .where('userId', isEqualTo: userId)
        .get();
    String result2 = result1.docs.first.data()['DateCreated'];
    DateTime dateTime = DateTime.parse(result2);
    String finalResult = DateFormat('yy/MM/dd').format(dateTime);
    return finalResult;
  }

  Future<int> getAllUnreadMessages() async {
    log('running total messages count');
    var myUserId = await FirebaseAuth.instance.currentUser!.uid;
    db = await FirebaseFirestore.instance;
    var docs = await db!
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('recieverId', isEqualTo: myUserId)
        .get();
    return docs.docs.length;
  }

  Future<int> userUnreadMessages(String senderId) async {
    log('running userUnreadMessages');
    var myUserId = await FirebaseAuth.instance.currentUser!.uid;
    int count = 0;
    db = await FirebaseFirestore.instance;
    var result1 = await db!
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('recieverId', isEqualTo: myUserId)
        .where('senderId', isEqualTo: senderId)
        .get();
    var result2 = result1.docs;
    count = result2.length;
    return count;
  }

  Future<void> markAsRead(String senderId) async {
    log('running markasRead');
    var myUserId = await FirebaseAuth.instance.currentUser!.uid;
    db = await FirebaseFirestore.instance;
    var temp = await db!
        .collection('messages')
        .where('recieverId', isEqualTo: myUserId)
        .where('senderId', isEqualTo: senderId)
        .get()
        .then((value) => value.docs.forEach((element) {
              element.reference.update({'isRead': true});
            }));
  }

  Future<String> getUserLanguage(String userId) async {
    log('running getUserLang');
    db = await FirebaseFirestore.instance;
    var result1 = await db!
        .collection('registeredUsers')
        .where('userId', isEqualTo: userId)
        .get();
    var result2 = result1.docs.first.data();
    String result3 = await getLanguageName(result2['prefLang']);
    log('user lang is ${result3}');
    return result3;
  }

  Future<bool> isRecieverUsingNative(String recieverId) async {
    log('running isRecieverUsingNative');
    FirebaseAuth _auth = FirebaseAuth.instance;

    var gotDoc = await db!
        .collection('nativeChatUsers')
        .where('recieverId', isEqualTo: recieverId)
        .where('senderId', isEqualTo: myData['myId'])
        .get();

    if (gotDoc.docs.isNotEmpty) {
      Map<String, dynamic> gotData = gotDoc.docs.first.data();
      if (gotData.isNotEmpty) {
        return gotData['useNativeChat'];
      }
    }

    return false;
  }

  Future<bool> amIUsingNative(String senderId) async {
    log('running amIUsingNative');
    await setMyDetails();
    var getList = await db!.collection('nativeChatUsers').get();
    for (var doc in getList.docs) {
      if (doc.data()['recieverId'] == myData['myId'] &&
          doc.data()['senderId'] == senderId) {
        return doc.data()['useNativeChat'];
      }
    }
    return false;
  }

  Future<void> setMyNativeLanguage(
      bool recieveInNative, String senderId) async {
    log('running setMyNativeLanguage');
    log('got sender person iD ${senderId}');
    await setMyDetails();
    FirebaseAuth _auth = await FirebaseAuth.instance;
    var getList = await db!.collection('nativeChatUsers').get();
    Map<String, dynamic> gotMap = {};

    for (var doc in getList.docs) {
      log('here in for loop');
      Map<String, dynamic> temp = doc.data();
      if (temp['recieverId'] == myData['myId'] &&
          temp['senderId'] == senderId) {
        log('got Map data as ${temp.toString()}');
        gotMap = temp;

        await db!
            .collection('nativeChatUsers')
            .where('recieverId', isEqualTo: myData['myId'])
            .where('senderId', isEqualTo: senderId)
            .get()
            .then((value) {
          value.docs.forEach((element) {
            element.reference.update({'useNativeChat': recieveInNative});
          });
        });
      }
    }
    if (gotMap.isEmpty) {
      log('setting new data');
      await db!.collection('nativeChatUsers').add({
        'recieverId': myData['myId'],
        'senderId': senderId,
        'useNativeChat': recieveInNative
      });
    }
  }

  Future<String> getMyLanguage() async {
//FirebaseAuth _auth = await  FirebaseAuth.instance;
//db = await FirebaseFirestore.instance;
    log('running getMyLanguage');
    await setMyDetails();
    if (myData['prefLang'] == '') {
      myData['prefLang'] = 'en';
    }

    return await getLanguageName(myData['prefLang']!);
  }

  Future<String> detectLanguage(String messageToCheck) async {
    log('Running detectLanguage');
    final response = await http.post(Uri.parse(dotenv.env['DETECT_LANG_URL']!),
        headers: {
          'content-type': 'application/json',
          'X-RapidAPI-Key': dotenv.env['RAPID_API_KEY']!,
          'X-RapidAPI-Host': dotenv.env['RAPID_API_HOST']!
        },
        body: await json.encode({'q': messageToCheck}));
    final data1 = json.decode(response.body);
    final data2 = data1['data']['detections'][0]['language'];
    log('DETECTED LANGUAGE = ${data2}');
    return data2.toString();
  }

  Future<String> translateMessage(
      String fromLang, String toLang, String message) async {
    log('running translateMsg');
    String fromThisLang = fromLang;
    if (fromThisLang == '') {
      fromThisLang = 'en';
    }

    final response = await http.post(Uri.parse(dotenv.env['TRANSLATION_URL']!),
        headers: {
          'content-type': 'application/json',
          'X-RapidAPI-Key': dotenv.env['RAPID_API_KEY']!,
          'X-RapidAPI-Host': dotenv.env['RAPID_API_HOST']!
        },
        body: json
            .encode({'q': message, 'source': fromThisLang, 'target': toLang}));
    final data = await json.decode(response.body);
    final String data2 = data['data']['translations']['translatedText'];
    log(data2.toString());
    return data2;
  }

  Future<String> getLanguageName(String language) async {
    gotLanguages.clear();
    gotlangNames.clear();
    log('running getLanguages');
    log('getting languages');
    log('got language to search ${language}');

    db = await FirebaseFirestore.instance;
    var data = await db!.collection('languages').get();
    for (var doc in data.docs) {
      gotlangNames.add(doc.data()['name']);
      gotLanguages.add(doc.data()['language']);
    }
    log('got languages : ${gotLanguages.toString()}');
    log('got languages names : ${gotlangNames.toString()}');

    return gotlangNames[
        gotLanguages.indexWhere((element) => element == language)];
  }

  Future<Map<String, String>> searchUserInDatabase(String enteredEmail) async {
    log('running search user in database');
    var _auth = await FirebaseAuth.instance;
    db = await FirebaseFirestore.instance;
    var user = await db!
        .collection('registeredUsers')
        .where('userEmail', isEqualTo: enteredEmail)
        .get();
    log('entered email ${enteredEmail}');
    //log(user.docs.length.toString());
    if (user.docs.length >= 1 &&
        user.docs.first.data()['userId'] != _auth.currentUser!.uid) {
      log('user found with ${user.docs.first.data()['userEmail']}');
      searcherdUser = user.docs.first.data()['userName'];
      selectedUserData = {
        'userId': user.docs.first.data()['userId'],
        'userEmail': user.docs.first.data()['userEmail'],
        'userName': user.docs.first.data()['userName'],
        'userImageUrl': user.docs.first.data()['userImageUrl'],
        'prefLang': user.docs.first.data()['prefLang'],
      };
      log('Selected user data ${selectedUserData}'.toString());

      Timer(Duration(seconds: 1), () {
        searcherdUser = '';
      });
      return selectedUserData;
    } else {
      searcherdUser = '';
      //notifyListeners();
      return {};
    }
  }

  Future<void> setMyDetails() async {
    log('running setmydetails');

    try {
      var _auth = await FirebaseAuth.instance;
      log('new debug setting details fireauth dat ${_auth.toString()}');
      db = await FirebaseFirestore.instance;
      log('new debug setting details firestore instance ${db.toString()}');

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
        'oneSignalSubId': data.docs.first.data()['oneSignalSubId'],
        'oneSignalUserId': data.docs.first.data()['oneSignalUserId'],
      };
      log('new debug setting details stored doc data ${myData.toString()}');
    } catch (e) {
      log('new debug, setting my details error ${e.toString()}');
    }

    log('my data set');
    log('here is my data : ${myData.toString()}');

    //log(myData.toString());
  }

  Future<String> sendMessage(
      String message, String userId, String language, bool convert) async {
    log('running send message');
    log('got details, ${message}, ${userId}, ${language}, ${convert.toString()}');
    var _auth = await FirebaseAuth.instance;

    db = await FirebaseFirestore.instance;
    //? to turn ON await getUserFromDatabase(userId);

    await setMyDetails();

    bool isUserUsingNative = await isRecieverUsingNative(userId);
    log('Using Native language? ${isUserUsingNative.toString()}');

    log('user id I got is : ${userId}');
    await getUserFromDatabase(userId);
    log('going to run no of tries');
    var getTries = await db!
        .collection('usersTranslatedCount')
        .where('userId', isEqualTo: myData['myId'])
        .get();
    log('got no of tries ${getTries.docs.first.data()['messagesLeft']}');
    int noOfTries = getTries.docs.first.data()['messagesLeft'];
    final String fromLang = await detectLanguage(message);
    if ((language != '' && convert == true) ||
        (language == '' && convert == true) ||
        isUserUsingNative == true) {
      String gotLang = language;
      if (gotLang == '') {
        gotLang = 'en';
      }
      if ((convert == true || isUserUsingNative == true) && noOfTries <= 0) {
        if (isUserUsingNative == true) {
          return 'They want translated message but you do not have any enough translations';
        }
        if (isUserUsingNative == false && convert == true) {
          return 'You do not have enough translations';
        }
      }

      String translatedMsg = await translateMessage(fromLang, gotLang, message);
      final Map<String, dynamic> messageData = await {
        'chatId': '${DateTime.now().toString()}${myData['myId']}',
        'isMsg': true,
        'isRead': false,
        'senderName': myData['myName']!,
        'recieverName': selectedUserData['userName']!,
        'senderId': _auth.currentUser!.uid,
        'recieverId': selectedUserData['userId']!,
        'message': message,
        'translatedmsg': translatedMsg,
        'senderAvatar': myData['myImageUrl']!,
        'recieverAvatar': selectedUserData['userImageUrl']!,
        'time': DateTime.now().toIso8601String(),
        'senderLang': myData['prefLang']!,
        'recieverLang': selectedUserData['prefLang']!,
      };
      await db!.collection('messages').add(messageData);
      db!
          .collection('usersTranslatedCount')
          .where('userId', isEqualTo: myData['myId'])
          .get()
          .then((value) => value.docs.forEach((element) {
                element.reference.update({'messagesLeft': noOfTries - 1});
              }));

      sendOneSignalNotification(
          messageData['recieverId'],
          myData['myName'] ?? 'New Message',
          messageData['message'].toString().contains('http')
              ? 'Image'
              : messageData['message'],
          myData);
      return '';
      // await fetchChatList();
    }
    if ((convert == false && isUserUsingNative == false)) {
      final Map<String, dynamic> messageData = await {
        'chatId': '${DateTime.now().toString()}${myData['myId']}',
        'isMsg': true,
        'isRead': false,
        'senderName': myData['myName']!,
        'recieverName': selectedUserData['userName']!,
        'senderId': _auth.currentUser!.uid,
        'recieverId': selectedUserData['userId']!,
        'message': message,
        'translatedmsg': '',
        'senderAvatar': myData['myImageUrl']!,
        'recieverAvatar': selectedUserData['userImageUrl']!,
        'time': DateTime.now().toIso8601String(),
        'senderLang': myData['prefLang']!,
        'recieverLang': selectedUserData['prefLang']!,
      };
      log('message data ${messageData}');
      // sendOneSignalNotification(
      //     messageData['recieverId'],
      //     myData['myName'] ?? 'New Message',
      //     messageData['message'].toString().contains('http')
      //         ? 'Image'
      //         : messageData['message'],
      //     myData);

      var messageToSend = await db!.collection('messages').add(messageData);
      sendOneSignalNotification(
          messageData['recieverId'],
          myData['myName'] ?? 'New Message',
          messageData['message'].toString().contains('http')
              ? 'Image'
              : messageData['message'],
          myData);
      return '';
      // await fetchChatList();
    }
    return 'Error in sending message';
  }

  Future<List<String>> fetchChatList() async {
    log('running fetch chat list');
    FirebaseAuth _auth = await FirebaseAuth.instance;
    db = await FirebaseFirestore.instance;

    sentChats = await db!
        .collection('messages')
        .where('senderId', isEqualTo: _auth.currentUser!.uid)
        .orderBy('time', descending: true)
        .get();
    log('sent chats count: ${sentChats!.docs.length}');
    receivedChats = await db!
        .collection('messages')
        .where('recieverId', isEqualTo: _auth.currentUser!.uid)
        .orderBy('time', descending: true)
        .get();

    log('Recieved chats count: ${receivedChats!.docs.length}');
    // for (var doc in sentChats!.docs) {
    //   var data = await doc.data() as Map<String, dynamic>;

    //   finalSentChatsUserId.add(data['recieverId']!);
    // }
    // for (var doc in receivedChats!.docs) {
    //   var data = await doc.data() as Map<String, dynamic>;
    //   finalRecievedChatsUserId.add(data['senderId']!);
    // }

    log('count before loop is ${sentChats!.docs.length.toString()}');
    List<Map<String, dynamic>> sentTemp = [];
    List<Map<String, dynamic>> recieveTemp = [];
    //? making a temp list of unique maps data to whom i have sent messages
    for (var data in sentChats!.docs) {
      bool alreadyThere = sentTemp.any((element) =>
          element['recieverId'] ==
          (data.data() as Map<String, dynamic>)['recieverId']);
      if (!alreadyThere) {
        sentTemp.add(data.data() as Map<String, dynamic>);
      }
    }
    log('count after loop is ${sentTemp.length.toString()}');
    //? making a temp list of unique maps data from whom i received mesages
    for (var data in receivedChats!.docs) {
      bool alreadyThere = recieveTemp.any((element) =>
          element['senderId'] ==
          (data.data() as Map<String, dynamic>)['senderId']);

      if (!alreadyThere) {
        recieveTemp.add(data.data() as Map<String, dynamic>);
      }
    }

    List<Map<String, dynamic>> combined = [];
    //? combining previous lists in new one
    combined = [...sentTemp, ...recieveTemp];
    //? now sorting all maps in combined list by converting time string in datetime object and comparing

    combined.sort(
      (a, b) {
        var time1 = DateTime.parse(a['time']);
        var time2 = DateTime.parse(b['time']);
        return time2.compareTo(time1);
      },
    );
    log('overall result ${combined.length}');
    sortedChats = combined;

    _uniqueChatsList.clear();
    //? now extracting all sender and receiver ids from sorted combined list
    for (var map in combined) {
      if (map['recieverId'] != _auth.currentUser!.uid) {
        _uniqueChatsList.add(map['recieverId']);
      }
      if (map['recieverId'] == _auth.currentUser!.uid) {
        _uniqueChatsList.add(map['senderId']);
      }
    }
    log('added items in unique list ${_uniqueChatsList.length}');
    //? combined list can have similar user ids like i sent a message to someone and also received a message from that person so previous combing approach can only put unique sets based on sender or receiver ids seperatly but when combined the list can contain same sender and receiver id so using set to throw out similar sender and receiver ids as combined list is already sorted with datetime so only old similar values will be thrown out preserving latest ones and using hashed set to maintain the order of ids from list to later extract because hashed set maintain order of values at time of putting

    LinkedHashSet<String> newSet = LinkedHashSet<String>.from(_uniqueChatsList);
    // // newSet!.addAll(_uniqueChatsList.toSet());
    log('items in set are ${newSet.length}');
    _uniqueChatsList.clear();
    _uniqueChatsList.addAll(newSet.toList());
    log('now final items in list ${_uniqueChatsList.length}');
    log('${_uniqueChatsList.toString()}');

    //_uniqueChatsList.clear();
    _chatsSet = finalSentChatsUserId.toSet();

    _chatsSet!.addAll(finalRecievedChatsUserId.toSet());

    // _uniqueChatsList = _chatsSet!.toList();

    finalSentChatsUserId.clear();
    finalRecievedChatsUserId.clear();
    receivedChats!.docs.clear();
    sentChats!.docs.clear();
    _chatsSet!.clear();

    return _uniqueChatsList;
  }

  Future<Map<String, String>> getUserFromDatabase(String userId) async {
    log('running get user from database');
    FirebaseAuth _auth = await FirebaseAuth.instance;
    db = await FirebaseFirestore.instance;
    var user = await db!
        .collection('registeredUsers')
        .where('userId', isEqualTo: userId)
        .get();

    if (user.docs.isNotEmpty) {
      Map<String, String> tempSelectedUserData = await {
        'userId': user.docs.first.data()['userId'],
        'userEmail': user.docs.first.data()['userEmail'],
        'userName': user.docs.first.data()['userName'],
        'userImageUrl': user.docs.first.data()['userImageUrl'],
        'prefLang': user.docs.first.data()['prefLang'],
      };
      selectedUserData = {
        'userId': tempSelectedUserData['userId']!,
        'userEmail': tempSelectedUserData['userEmail']!,
        'userName': tempSelectedUserData['userName']!,
        'userImageUrl': tempSelectedUserData['userImageUrl']!,
        'prefLang': tempSelectedUserData['prefLang']!
      };
      return tempSelectedUserData;
    }
    return selectedUserData;
    //log('Selected user data ${selectedUserData}'.toString());
  }

  Future<void> getUserChats(String otherUserId) async {
    log('running get user chats');
    FirebaseAuth _auth = await FirebaseAuth.instance;
    db = await FirebaseFirestore.instance;
    var sendFromMe = await db!
        .collection('messages')
        .where('senderId', isEqualTo: _auth.currentUser!.uid)
        .get();
    var recievedByMe = await db!
        .collection('messages')
        .where('recieverId', isEqualTo: _auth.currentUser!.uid)
        .get();
    List tempCombined = [];

    for (var doc in sendFromMe.docs) {
      var data = doc.data();
      tempCombined.add(data);
    }
    for (var doc in recievedByMe.docs) {
      var data = doc.data();
      tempCombined.add(data);
    }
    log('combined list = ${tempCombined.toString()}');
    log(tempCombined.length.toString());
  }
}
