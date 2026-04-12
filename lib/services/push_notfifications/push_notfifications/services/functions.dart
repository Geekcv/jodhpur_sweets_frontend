// import 'dart:convert';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// class NotificationHandler {
// // create a seperate class to hold and use the notif data
// // class EventNotification {
// //   final int id;
// //   final String title;
// //   String body;
// //   final DateTime scheduledTime;
//
// //   EventNotification({
// //     required this.id,
// //     required this.title,
// //     required this.body,
// //     required this.scheduledTime,
// //     required String remark,
// //   });
// // }
//
// // create (after init state) a List which will map(index) the data of above class created
// // List<EventNotification> eventNotifications = [];
//
//   // initialise this class before using functions in initState
//   // like this "  var functionInstance = NotificationHandler();  " to be used a object
//
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   // ======================================================================================
//
//   Future<void> init() async {
//     final initializationSettingsAndroid =
//         AndroidInitializationSettings('ic_launcher');
//     final initializationSettingsIOS = DarwinInitializationSettings();
//     final initializationSettings = InitializationSettings(
//         android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//
//     // print('initttttt-Notifffffffttttttttttttt');
//     // print(initializationSettings);
//
//     // flutterLocalNotificationsPlugin.initialize(initializationSettings,
//     //     onSelectNotification: onSelectNotification);
//   }
//
//   // ======================================================================================
// // Future<void> setup() async {
// // const androidInitializationSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
// // const iosInitializationSetting = DarwinInitializationSettings();
// // const initSettings = InitializationSettings(android: androidSetting, iOS: iosSetting);
// // await _flutterLocalNotificationsPlugin.initialize(initSettings);
// // }
//   Future<void> scheduleNotification(
//       int id, String title, String body, DateTime scheduledTime) async {
//     // print("scheduledTime");
//     // print(title);
//     // print(body);
//     // print(scheduledTime);
//     final androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       id.toString(),
//       'channel_name',
//       importance: Importance.max,
//       priority: Priority.high,
//       icon: 'ic_launcher',
//     );
// //     DarwinNotificationDetails DarwinNotificationDetails({
// //   bool? presentAlert,
// //   bool? presentBadge,
// //   bool? presentSound,
// //   String? sound,
// //   int? badgeNumber,
// //   List<IOSNotificationAttachment>? attachments,
// //   String? subtitle,
// //   String? threadIdentifier,
// // })
//     final iOSPlatformChannelSpecifics = DarwinNotificationDetails();
//
//     final platformChannelSpecifics = NotificationDetails(
//         android: androidPlatformChannelSpecifics,
//         iOS: iOSPlatformChannelSpecifics);
//     Duration offsetTime = DateTime.now().timeZoneOffset;
//     tz.TZDateTime zonedTime = tz.TZDateTime.local(
//             scheduledTime.year,
//             scheduledTime.month,
//             scheduledTime.day,
//             scheduledTime.hour,
//             scheduledTime.minute)
//         .subtract(offsetTime);
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body, // Use the remark as the body
//       zonedTime,
//       platformChannelSpecifics,
//       payload: 'New Event',
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       androidScheduleMode: AndroidScheduleMode.exact,
//     );
//   }
//   // ======================================================================================
//
//   // call this function in setState
//   Future<void> deleteNotification(int id, eventNotifications) async {
//     await flutterLocalNotificationsPlugin.cancel(id);
//
//     eventNotifications.removeWhere((notification) => notification.id == id);
//   }
//   // ======================================================================================
//
//   Future<DateTime?> selectDateTimeContent(BuildContext context,
//       [eventNotifications]) async {
//     DateTime? pickedDateTime;
//
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2100),
//     );
//
//     if (pickedDate != null) {
//       final TimeOfDay? pickedTime = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//       );
//
//       if (pickedTime != null) {
//         pickedDateTime = DateTime(
//           pickedDate.year,
//           pickedDate.month,
//           pickedDate.day,
//           pickedTime.hour,
//           pickedTime.minute,
//         );
//       }
//     }
//
//     return pickedDateTime;
//   }
//
//   selectTimeContent(BuildContext context, [eventNotifications]) async {
//     TimeOfDay initialTime = TimeOfDay.now();
//     TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: initialTime,
//     );
//     // print("pickedTime======");
//     // print(pickedTime);
//     return pickedTime!.hour.toString() + ":" + pickedTime.minute.toString();
//   }
//
//   // ======================================================================================
//
//   // Future<void> editNotificationRemark(EventNotification notification) async {
//   //   final String? newRemark = await showDialog<String>(
//   //     context: context,
//   //     builder: (BuildContext context) {
//   //       String? remark = notification.body;
//   //       return AlertDialog(
//   //         title: Text('Edit Remark'),
//   //         content: TextField(
//   //           onChanged: (value) {
//   //             remark = value;
//   //           },
//   //           controller: TextEditingController(text: notification.body),
//   //           decoration: InputDecoration(
//   //             labelText: 'Remark',
//   //           ),
//   //         ),
//   //         actions: [
//   //           TextButton(
//   //             child: Text('Cancel'),
//   //             onPressed: () {
//   //               Navigator.of(context).pop();
//   //             },
//   //           ),
//   //           TextButton(
//   //             child: Text('Save'),
//   //             onPressed: () {
//   //               Navigator.of(context).pop(remark);
//   //             },
//   //           ),
//   //         ],
//   //       );
//   //     },
//   //   );
//
//   //   if (newRemark != null) {
//   //     setState(() {
//   //       notification.body = newRemark;
//   //     });
//   //   }
//   // }
// }
