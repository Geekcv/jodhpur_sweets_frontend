// // ignore_for_file: unnecessary_null_comparison
//
// import 'dart:io';
//
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:prosys_app_web/utilities/utils.dart';
// // import 'package:flutter_native_timezone/flutter_native_timezone.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
//
// import 'package:http/http.dart' as http;
//
// class LocalPushNotificationsHelper {
//   // LocalPushNotificationsHelper() {
//   //   tz.initializeDatabase([]);
//   // }
//   Future _onSelectNotification(String payload) async {
//     // print("selected");
//   }
//
//   Future _onDidReceiveLocalNotification(
//       int id, String title, String body, String payload) async {
//     // print("recieved");
//   }
//
//   Future<void> showLocalNotification(title, body, payload) async {
//     var id = int.parse(Utilities().getRandomString(4));
//     await LocalPushNotificationsManager()
//         .showNotification(id, title, body, payload);
//   }
//
//   Future<void> showLocalIMageNotification(title, body, urlIcon, urlImg) async {
//     var id = int.parse(Utilities().getRandomString(4));
//     await LocalPushNotificationsManager()
//         .showImageNotification(id, title, body, urlIcon, urlImg);
//   }
//
//   Future<void> showOngoingLocalNotification(title, body, payload) async {
//     var id = int.parse(Utilities().getRandomString(4));
//     await LocalPushNotificationsManager()
//         .showOngoingNotification(id, title, body, payload);
//   }
//
//   Future<void> sheduleLocalNotification(
//       title, body, payload, DateTime date) async {
//     // final scheduledDate = tz.TZDateTime.from(date, tz.local);
//     // print("time----------");
//     // print(date);
//     LocalPushNotificationsManager()
//         .init(_onSelectNotification, _onDidReceiveLocalNotification);
//     var id = int.parse(Utilities().getRandomString(4));
//     await LocalPushNotificationsManager()
//         .scheduleNotification(id, title, body, payload, date, true);
//   }
// }
//
// class LocalPushNotificationsManager {
//   static const CHANNEL_ID = 'ftis';
//   static const CHANNEL_NAME = 'ftis android';
//   static const CHANNEL_DESCRIPTION =
//       'ftis local notfication channel for android';
//
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   static LocalPushNotificationsManager? _localNotification;
//
//   LocalPushNotificationsManager._createInstance();
//   // ignore: empty_constructor_bodies
//   factory LocalPushNotificationsManager() {
//     if (_localNotification == null) {
//       _localNotification = LocalPushNotificationsManager._createInstance();
//       _localNotification!._initialize();
//     }
//     return _localNotification!;
//   }
//   var _onSelectNotification, _onDidReceiveLocalNotification;
//   void init(onSelectNotification, onDidReceiveLocalNotification) {
//     if (this._onSelectNotification == null) {
//       this._onSelectNotification = onSelectNotification;
//     }
//     if (this._onDidReceiveLocalNotification == null) {
//       this._onDidReceiveLocalNotification = onDidReceiveLocalNotification;
//     }
//   }
//
//   Future<void> _initialize() async {
//     tz.initializeTimeZones();
//
//     // tz.initializeDatabase([]);
//     // var locations = tz.timeZoneDatabase.locations;
//     // print("locations--------");
//     // print(locations);
//     // for (var i = 0; i < locations.length; i++) {
//     // // print('locations[i]---------');
//     // // print(locations[i]);
//     // }
//     AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     DarwinInitializationSettings initializationSettingsIOS =
//         DarwinInitializationSettings(
//       requestAlertPermission: true,
//     );
//
//     InitializationSettings initializationSettings = InitializationSettings(
//         android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
//
//     await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onDidReceiveBackgroundNotificationResponse:
//             _onDidReceiveLocalNotification);
//   }
//
//   Future<void> showNotification(id, title, body, payload) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       CHANNEL_ID,
//       CHANNEL_NAME,
//       // CHANNEL_DESCRIPTION,
//       importance: Importance.max,
//       priority: Priority.high,
//       icon: '@mipmap/ic_launcher',
//     );
//     const DarwinNotificationDetails iOSPlatformChannelSpecifics =
//         DarwinNotificationDetails();
//     const NotificationDetails platformChannelSpecifics = NotificationDetails(
//         android: androidPlatformChannelSpecifics,
//         iOS: iOSPlatformChannelSpecifics);
//     await _flutterLocalNotificationsPlugin
//         .show(id, title, body, platformChannelSpecifics, payload: payload);
//   }
//
//   Future<String> _downloadAndSaveFile(String url, String fileName) async {
//     final Directory directory = await getApplicationDocumentsDirectory();
//     final String filePath = '${directory.path}/$fileName';
//     final http.Response response = await http.get(Uri.parse(url));
//     final File file = File(filePath);
//     await file.writeAsBytes(response.bodyBytes);
//     return filePath;
//   }
//
//   Future<void> showImageNotification(id, title, body, urlIcon, urlImg) async {
//     final String largeIconPath =
//         urlIcon != null ? await _downloadAndSaveFile(urlIcon, 'largeIcon') : "";
//     final String bigPicturePath =
//         await _downloadAndSaveFile(urlImg, 'bigPicture');
//     final BigPictureStyleInformation bigPictureStyleInformation =
//         BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath),
//             largeIcon: largeIconPath.isNotEmpty
//                 ? FilePathAndroidBitmap(largeIconPath)
//                 : null,
//             contentTitle: title,
//             htmlFormatContentTitle: true,
//             summaryText: body,
//             htmlFormatSummaryText: true);
//     final AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(CHANNEL_ID, CHANNEL_NAME,
//             // CHANNEL_DESCRIPTION,
//             importance: Importance.max,
//             priority: Priority.high,
//             styleInformation: bigPictureStyleInformation);
//     final NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
//     await _flutterLocalNotificationsPlugin.show(
//         id, title, body, platformChannelSpecifics);
//   }
//
//   Future<void> showOngoingNotification(id, title, body, payload) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       CHANNEL_ID,
//       CHANNEL_NAME,
//       // CHANNEL_DESCRIPTION,
//       importance: Importance.max,
//       priority: Priority.high,
//       ongoing: true,
//       icon: '@mipmap/ic_launcher',
//     );
//     const DarwinNotificationDetails iOSPlatformChannelSpecifics =
//         DarwinNotificationDetails();
//     const NotificationDetails platformChannelSpecifics = NotificationDetails(
//         android: androidPlatformChannelSpecifics,
//         iOS: iOSPlatformChannelSpecifics);
//     await _flutterLocalNotificationsPlugin
//         .show(id, title, body, platformChannelSpecifics, payload: payload);
//   }
//
//   Future<void> scheduleNotification(
//       id, title, body, payload, date, ongoing) async {
//     // print("date----------$date");
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       CHANNEL_ID,
//       CHANNEL_NAME,
//       // CHANNEL_DESCRIPTION,
//       importance: Importance.max,
//       priority: Priority.high,
//       icon: '@mipmap/ic_launcher',
//     );
//     const DarwinNotificationDetails iOSPlatformChannelSpecifics =
//         DarwinNotificationDetails();
//     const NotificationDetails platformChannelSpecifics = NotificationDetails(
//         android: androidPlatformChannelSpecifics,
//         iOS: iOSPlatformChannelSpecifics);
//     // int dateMilliSeconds = date.toUtc().millisecondsSinceEpoch;
//     await _flutterLocalNotificationsPlugin.zonedSchedule(id, title, body,
//         tz.TZDateTime.from(date, tz.local), platformChannelSpecifics,
//         payload: payload,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//         androidScheduleMode: AndroidScheduleMode.exact);
//   }
//
//   Future<void> cancelNotification(id) async {
//     await _flutterLocalNotificationsPlugin.cancel(id);
//   }
//
//   Future<void> cancelAllNotification() async {
//     await _flutterLocalNotificationsPlugin.cancelAll();
//   }
//
//   Future<void> repeatNotification(id, title, body, payload) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       CHANNEL_ID,
//       CHANNEL_NAME,
//       // CHANNEL_DESCRIPTION,
//       importance: Importance.max,
//       priority: Priority.high,
//       icon: '@mipmap/ic_launcher',
//     );
//     const DarwinNotificationDetails iOSPlatformChannelSpecifics =
//         DarwinNotificationDetails();
//     const NotificationDetails platformChannelSpecifics = NotificationDetails(
//         android: androidPlatformChannelSpecifics,
//         iOS: iOSPlatformChannelSpecifics);
//     await _flutterLocalNotificationsPlugin.periodicallyShow(
//         id, title, body, RepeatInterval.daily, platformChannelSpecifics,
//         payload: payload, androidScheduleMode: AndroidScheduleMode.exact);
//   }
//
//   Future<List<PendingNotificationRequest>> getPendingNotifications() async {
//     return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
//   }
// }
