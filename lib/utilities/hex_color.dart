// ignore_for_file: unused_local_variable, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexValue) {
    hexValue = hexValue.toUpperCase().replaceAll("#", "");
    var hexColor;
    if (hexValue.length == 6) {
      hexValue = "FF" + hexValue;
    }
    return int.parse(hexValue, radix: 16);
  }

  HexColor(final String hexValue) : super(_getColorFromHex(hexValue));
}
