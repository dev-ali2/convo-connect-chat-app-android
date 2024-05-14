// import 'dart:developer';

// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:flutter/material.dart';

// class Notifications {
//   Future<void> initNotification(BuildContext context) async {
//     await AwesomeNotifications().initialize(
//         null,
//         [
//           NotificationChannel(
//               channelKey: 'Messages',
//               channelName: 'Messages',
//               channelDescription: 'Channel to display messages',
//               criticalAlerts: true,
//               defaultColor: Theme.of(context).colorScheme.primary,
//               enableVibration: true,
//               icon: 'Assets/images/trans_app_icon.png',
//               groupSort: GroupSort.Desc,
//               importance: NotificationImportance.Max,
//               locked: true,
//               playSound: true),
//         ],
//         channelGroups: [
//           NotificationChannelGroup(
//               channelGroupKey: 'High Importance', channelGroupName: 'Chats')
//         ],
//         debug: true);
//     AwesomeNotifications().isNotificationAllowed().then((value) async {
//       if (!value) {
//         AwesomeNotifications().requestPermissionToSendNotifications();
//       }
//     });
//     await AwesomeNotifications().setListeners(
//         onActionReceivedMethod: onActionReceivedMethod,
//         onNotificationCreatedMethod: onNotificationCreatedMethod,
//         onNotificationDisplayedMethod: onNotificationDisplayedMethod,
//         onDismissActionReceivedMethod: onDismissActionReceivedMethod);
//   }

//   Future<void> onActionReceivedMethod(ReceivedAction action) async {
//     final payload = action.payload ?? {};
//     if (payload['navigate'] == true) {}
//     log('onActionReceivedMethod');
//   }

//   Future<void> onNotificationCreatedMethod(
//       ReceivedNotification notification) async {
//     log('onNotificationCreateMethod');
//   }

//   Future<void> onNotificationDisplayedMethod(
//       ReceivedNotification notification) async {
//     log('onNotificationDisplayedMethod');
//   }

//   Future<void> onDismissActionReceivedMethod(ReceivedAction action) async {
//     log('onDismissActionReceivedMethod');
//   }
// }
