// ignore_for_file: prefer_interpolation_to_compose_strings, no_leading_underscores_for_local_identifiers, unnecessary_null_comparison, deprecated_member_use, unnecessary_brace_in_string_interps, unnecessary_new, sort_child_properties_last

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Utilities {
  List<String> getMonthlyReminderDates(int dayOfMonth, int remindDays) {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('dd-MM');
    List<String> reminderDates = [];
    List<int> monthsWith31Days = [1, 3, 5, 7, 8, 10, 12];
    if (dayOfMonth == 31) {
      for (int month in monthsWith31Days) {
        DateTime reminderDate = DateTime(now.year, month, dayOfMonth)
            .subtract(Duration(days: remindDays));
        reminderDates.add(formatter.format(reminderDate));
      }
      return reminderDates;
    } else {
      for (int month = 1; month <= 12; month++) {
        int daysInMonth = DateTime(now.year, month + 1, 0).day;
        if (dayOfMonth <= daysInMonth) {
          DateTime reminderDate = DateTime(now.year, month, dayOfMonth)
              .subtract(Duration(days: remindDays));
          reminderDates.add(formatter.format(reminderDate));
        }
      }
      return reminderDates;
    }
  }

  List<String> getYearlyReminderDates(dates, int remindBefore) {
    DateTime now = DateTime.now();
    DateFormat inputFormatter = DateFormat('dd-MM');
    DateFormat outputFormatter = DateFormat('dd-MM');
    List<String> reminderDates = [];

    for (String date in dates) {
      DateTime parsedDate = inputFormatter.parse(date);
      DateTime reminderDate =
          DateTime(now.year, parsedDate.month, parsedDate.day)
              .subtract(Duration(days: remindBefore));
      reminderDates.add(outputFormatter.format(reminderDate));
    }
    print('YearlyYearlyweeeeeklllll${reminderDates}');

    return reminderDates;
  }

  static openInBrowser(url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        // forceSafariVC: false,
        // forceWebView: false,
        // headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  String getDayOfMonthSuffix(int dayNum) {
    if (!(dayNum >= 1 && dayNum <= 31)) {
      throw Exception('Invalid day of month');
    }

    if (dayNum >= 11 && dayNum <= 13) {
      return 'th';
    }

    switch (dayNum % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  popup({message, context, messageinButton, onPressed}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("${message}"),
            actions: <Widget>[
              TextButton(
                child: Text("${messageinButton}"),
                onPressed: onPressed ??
                    () {
                      Navigator.of(context).pop();
                    },
              )
            ],
          );
        });
  }

  feetTocmConvertor(ft, [inch = 0]) {
    var cm = ft * 30.48 + inch * 2.54;
    return cm;
  }

  String getRandomString(length) {
    Random rnd = new Random();
    int min = 1111, max = 9999;
    int result = min + rnd.nextInt(max - min);
    return result.toString();
  }

  findAllIndexes(list, elementKey, elementValue) {
    var ind = list.indexWhere((el) => el[elementKey] == elementValue);
    if (ind != -1) {
      var indexes = [];
      for (var i = 0; i < list.length; i++) {
        if (list[i][elementKey] == elementValue) {
          indexes.add(i);
        }
      }
      return indexes;
    } else {
      return ind;
    }
  }

  List<int>? findEachChildIndex(node, String searchId) {
    if (node['id'] == searchId) {
      return []; // Return empty list if the current node has the matching ID
    }

    if (node.containsKey('ch')) {
      for (int i = 0; i < node['ch'].length; i++) {
        var child = node['ch'][i];
        var childResult = findEachChildIndex(child, searchId);

        if (childResult != null) {
          return [
            i,
            ...childResult
          ]; // Append the child index and the result from recursion
        }
      }
    }

    return null; // Return null if not found
  }

  calculateAge(birthDate, format) {
    var bDate =
        birthDate is String ? DateFormat(format).parse(birthDate) : birthDate;
    DateTime currentDate = DateTime.now();
    num age = currentDate.year - bDate.year;
    int month1 = currentDate.month;
    int month2 = bDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = bDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  calculateAgeYM(birthDate, format) {
    DateTime dob =
        birthDate is String ? DateFormat(format).parse(birthDate) : birthDate;
    DateTime currentDate = DateTime.now();
    int years = currentDate.year - dob.year;
    int months = currentDate.month - dob.month;

    // If the current month is earlier than the birth month, subtract one year
    if (months < 0) {
      years--;
      months += 12;
    }

    // If the current day is earlier than the birth day, adjust the months
    if (currentDate.day < dob.day) {
      months--;
      if (months < 0) {
        years--;
        months += 12;
      }
    }

    return {'years': years, 'months': months};
  }

  static List<int> generateRandomNumbers(int count, List tableData) {
    var max = tableData.length - 1;
    var min = 0;
    var random = Random();
    var uniqueNumbers = <int>{};

    while (uniqueNumbers.length < count) {
      uniqueNumbers.add(random.nextInt(max - min + 1) + min);
    }

    return uniqueNumbers.toList();
  }

  int getRandomNumber(mini, maxi) {
    Random rnd = new Random();
    int min = mini, max = maxi;
    int result = min + rnd.nextInt(max - min);
    return result;
  }

  String maskString(String input, String maskChar) {
    if (input.length <= 4) {
      return input;
    }

    String firstTwoChars = input.substring(0, 2);
    String lastTwoChars = input.substring(input.length - 2);
    String maskedChars = maskChar * (input.length - 4);

    return '$firstTwoChars$maskedChars$lastTwoChars';
  }

  static showDeleteConfirm(context, title, msg, btnText, func) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          // dialogContext = context;
          return AlertDialog(
            title: Text("$title"),
            content: Text("$msg"),
            actions: [
              TextButton(
                  onPressed: () {
                    func();

                    Navigator.of(context).pop();
                  },
                  child: Text("$btnText")),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Close"))
            ],
          );
        });
  }

  static copyToClipboard(context, content, msg) {
    Clipboard.setData(ClipboardData(text: content)).then((_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("$msg")));
    });
  }

  static showMessage(context, dialogtitle, dialogContent) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierColor: Color.fromARGB(99, 184, 184, 248),
      builder: (BuildContext contxt) {
        String title = dialogtitle;
        String message = dialogContent;
        String btnLabelCancel = "Ok";
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(contxt),
              child: Text(btnLabelCancel),
            )
            // BackButton(
            //   // key: Text(btnLabelCancel),
            //   onPressed: () => Navigator.pop(contxt),
            // ),
          ],
        );
      },
    );
  }

  static bool isTextEditingController(dynamic value) {
    return value is TextEditingController;
  }

  static dynamic removeTextEditingControllers(dynamic json) {
    // print("===========${json is Map}");
    if (json is Map<dynamic, dynamic>) {
      final newMap = <dynamic, dynamic>{};
      json.forEach((key, value) {
        bool isTextCtrl = isTextEditingController(value);
        // print("=============$key===============$isTextCtrl");
        if (!isTextCtrl) {
          newMap[key] = removeTextEditingControllers(value);
        }
      });
      return newMap;
    } else if (json is List) {
      return json.map((item) => removeTextEditingControllers(item)).toList();
    } else {
      return json;
    }
  }

  static showResponse(context, responseMsg) {
    final snackBar = new SnackBar(content: new Text(responseMsg));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  String getRandomId(length) {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();

    return DateTime.now().millisecondsSinceEpoch.toString() +
        "_" +
        String.fromCharCodes(Iterable.generate(
            length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  String getRandomStringId(length) {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();

    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  String generateRandomNumber(length) {
    const _chars = '1234567890';
    Random _rnd = Random();

    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  List sortList(list, compareObject, type) {
    if (type == 0) {
      return list.sort((n, o) => n[compareObject].compareTo(o[compareObject]));
    } else {
      return list.sort((n, o) => n[compareObject]
          .toLowerCase()
          .compareTo(o[compareObject].toLowerCase()));
    }
  }

  // launchWhatsapp(number, message) async {
  //   String url() {
  //     if (Platform.isIOS) {
  //       return "whatsapp://wa.me/$number/?text=${Uri.parse(message)}";
  //     } else {
  //       return "whatsapp://send?phone=$number&text=${Uri.parse(message)}";
  //     }
  //   }

  //   if (await canLaunch(url())) {
  //     await launch(url());
  //   } else {
  //     throw 'Could not launch ${url()}';
  //   }
  // }

  // openLink(String url) async {
  //   html.window.open(url, "_self");
  // }

  openWebBrowser(String url) async {
    var url_ = Uri.parse(url);
    try {
      if (await canLaunchUrl(url_)) {
        await launchUrl(url_);
      } else {
        throw 'Could not launch ${url}';
      }
    } catch (e) {
      // print('${e}iiiiiiiiiiiiiiiiiii');
    }
  }

  String? ytUrlToId(String url, {bool trimWhitespaces = true}) {
    assert(url.isNotEmpty, 'Url cannot be empty');
    if (url.contains("http") && (url.length == 11)) return url;
    if (trimWhitespaces) url = url.trim();

    for (var exp in [
      RegExp(
          r"^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(
          r"^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(r"^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$")
    ]) {
      Match match = exp.firstMatch(url) as Match;
      if (match != null && match.groupCount >= 1) return match.group(1);
    }

    return null;
  }

  String? getYoutubeThumbnail(String videoUrl) {
    // final Uri? uri = Uri.tryParse(videoUrl);
    // if (uri == null) {
    //   return null;
    // }
    // var videoId = ytUrlToId(videoUrl);
    return 'https://img.youtube.com/vi/PLoWowTlwbGXP0YacEZ3mwHeEfI-U8K-0x/0.jpg';
  }

  bool isNotBlank(String s) => s != null && s.trim().isNotEmpty;

  bool isEmpty(String s) => s == null || s.isEmpty;

  bool isNotEmpty(String s) => s != null && s.isNotEmpty;
}
