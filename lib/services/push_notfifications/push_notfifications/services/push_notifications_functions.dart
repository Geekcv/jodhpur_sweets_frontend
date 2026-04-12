// import 'dart:convert';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:prosys_app_web/controllers/api_controller.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'local_notifications.dart';
//
// class PushNotificationsManager {
//   PushNotificationsManager._();
//
//   factory PushNotificationsManager() => _instance;
//
//   static final PushNotificationsManager _instance =
//       PushNotificationsManager._();
//
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   bool _initialized = false;
//
//   Future<void> init(context) async {
//     String? token = await getToken();
//     ;
//     if (!_initialized) {
//       // For iOS request permission first.
//       _firebaseMessaging.requestPermission();
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         // print("message--------");
//         // print(message.notification);
//         // print(message.notification!.title);
//         // print(message.notification!.android!.imageUrl);
//         // print(message.notification!.title);
//         // print(message.notification!.body);
//         // print(message.notification!.android!.imageUrl);
//         // print(message.notification!.android!.smallIcon);
//         if (message.notification!.android != null &&
//             message.notification!.android!.imageUrl != null) {
//           LocalPushNotificationsHelper().showLocalIMageNotification(
//               message.notification!.title,
//               message.notification!.body,
//               message.notification!.android!.smallIcon,
//               message.notification!.android!.imageUrl);
//         } else {
//           LocalPushNotificationsHelper().showLocalNotification(
//               message.notification!.title,
//               message.notification!.body,
//               'server access notificaiton');
//         }
//       });
//       // For testing purposes print the Firebase Messaging token
//       // token =
//       // print("FirebaseMessaging token: $token");
//
//       _initialized = true;
//     }
//     await setToken(context, token);
//   }
//
//   Future subscribeToTopic(topic) async {
//     await _firebaseMessaging.subscribeToTopic(topic);
//   }
//
//   Future unsubscribeToTopic(topic) async {
//     await _firebaseMessaging.unsubscribeFromTopic(topic);
//   }
//
//   Future setToken(context, token) async {
//     // print('token 65 === $token');
//     await ApiController.sendtoken(device_Id: token);
//   }
//
//   Future getUserLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     return (prefs.getString('user'));
//   }
//
//   Future getToken() async {
//     String? token = await _firebaseMessaging.getToken();
//     // print("FirebaseMessaging token: $token");
//     return token;
//   }
// }
