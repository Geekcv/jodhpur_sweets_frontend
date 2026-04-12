import 'package:flutter/material.dart';
import 'package:js_order_website/utilities/sizeconfig.dart';

var buttonStyle = ButtonStyle(
  shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
      side: const BorderSide(color: Color(0xffffffff)))),
  elevation: WidgetStateProperty.all(0),
  backgroundColor: WidgetStateProperty.all<Color>(const Color(0xff3081c0)),
  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
);
var barrierColor = const Color.fromARGB(62, 8, 8, 8);
List<String> weekDays = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday"
];
InputDecoration input_field_dec = InputDecoration(
  filled: true,
  contentPadding: EdgeInsets.all(10.0),
  fillColor: Color(0xfff7f7f7),
  enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
        color: const Color.fromARGB(255, 87, 86, 86),
        style: BorderStyle.solid,
        // width: SizeConfig
        //         .blockSizeHorizontal! *
        //     0.10,
      )),
  errorMaxLines: 1,
  errorStyle: TextStyle(fontSize: 11),
  border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
        color: const Color.fromARGB(255, 87, 86, 86),
        style: BorderStyle.solid,
        width: SizeConfig.blockSizeHorizontal! * 0.10,
      )),
  errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(3)),
      borderSide: BorderSide(
        color: Colors.red,
        style: BorderStyle.solid,
      )),
  focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
        color: const Color.fromARGB(255, 87, 86, 86),
        style: BorderStyle.solid,
        width: SizeConfig.blockSizeHorizontal! * 0.10,
      )),
);
