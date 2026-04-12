import 'package:flutter/material.dart';

import 'colors.dart';

var headingTextStyle = TextStyle(
  color: headingColor,
  fontSize: 20,
  shadows: const <Shadow>[
    Shadow(
      offset: Offset(2.0, 2.0),
      blurRadius: 2.0,
      color: Color.fromARGB(100, 0, 0, 0),
    ),
  ],
);
var btnTextStyle = TextStyle(color: btnLabelColor, fontSize: 14);
var labelTextStyle = TextStyle(color: labelColor, fontSize: 14);
const baseTextStyle = TextStyle(color: baseColor, fontSize: 14);
const baseTextStyle1 = TextStyle(color: baseColor, fontSize: 16);
var appBarTitleStyle = TextStyle(color: appBarTitleColor, fontSize: 21);
const formHeadingStyle = TextStyle(color: baseColor, fontSize: 18);
const formSubheadingStyle = TextStyle(color: subHeadingColor, fontSize: 12);
const submitBtnTextStyle =
    TextStyle(color: bgColor, fontSize: 16, fontWeight: FontWeight.w600);
var listHeadingTextStyle = TextStyle(color: listHeadingColor, fontSize: 21);
var listSubHeadingTextStyle =
    TextStyle(color: listsubHeadingColor, fontSize: 14);
