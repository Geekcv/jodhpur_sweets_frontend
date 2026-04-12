// ignore_for_file: file_names

import 'package:shared_preferences/shared_preferences.dart';

enum CalledPrefereences {
  setString,
  setBool,
  setInt,
  getString,
  getBool,
  getInt,
  removeKey,
  removeAll,
  checkContainsKey
}

class AppSharedPreferences {
  AppSharedPreferences._privateConstructor();

  static final AppSharedPreferences instance =
      AppSharedPreferences._privateConstructor();

  accessSharedPreferences(String key, var value, function) {
    switch (function) {
      case CalledPrefereences.setString:
        setStringValue(key, value);
        break;
      case CalledPrefereences.getString:
        getStringValue(key);
        break;
      case CalledPrefereences.setInt:
        setIntValue(key, value);
        break;
      case CalledPrefereences.getInt:
        getIntValue(key);
        break;
      case CalledPrefereences.setBool:
        setBoolValue(key, value);
        break;
      case CalledPrefereences.getBool:
        getBoolValue(key);
        break;
      case CalledPrefereences.checkContainsKey:
        containsKey(key);
        break;
      case CalledPrefereences.removeAll:
        removeAll();
        break;
      case CalledPrefereences.removeKey:
        removeValue(key);
        break;
    }
  }

  setStringValue(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  Future<String?> getStringValue(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // print("ttttttttttttttttt$prefs");
    return prefs.getString(key);
  }

  setBoolValue(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  Future<bool?> getBoolValue(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  setIntValue(String key, int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }

  Future<int?> getIntValue(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  Future<bool> containsKey(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  removeValue(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  removeAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}
