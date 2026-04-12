import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextInput extends StatefulWidget {
  CustomTextInput(
      {super.key,
      required this.controller,
      this.labelText,
      this.height,
      this.maxLines,
      this.hintText,
      this.validator = false,
      this.inputFormatters,
      this.maxLength,
      this.keyboardType,
      this.prefixicon,
      this.decoration,
      this.prefix,
      this.suffixicon,
      this.labelStyle,
      this.obscureText,
      this.auto_ValidateMode,
      this.textstyle,
      this.enabledBordercolor,
      this.readOnly = false,
      this.onChanged});
  TextEditingController controller;
  var labelText;
  var labelStyle;
  var auto_ValidateMode;
  var hintText;
  double? height;
  var maxLines;
  var readOnly;
  var inputFormatters;
  var maxLength;
  Widget? prefix;
  var suffixicon;
  var prefixicon;
  var decoration;
  var textstyle;
  bool? obscureText;
  var enabledBordercolor;
  Function? onChanged;
  bool validator;
  TextInputType? keyboardType;
  @override
  State<CustomTextInput> createState() => _CustomTextInputState();
}

class _CustomTextInputState extends State<CustomTextInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: TextFormField(
        // cursorHeight: 30,
        inputFormatters: widget.inputFormatters,
        readOnly: widget.readOnly,
        // autovalidateMode: AutovalidateMode.onUserInteraction,
        autovalidateMode: widget.auto_ValidateMode,
        controller: widget.controller,
        textAlign: TextAlign.justify,
        obscureText: widget.obscureText ?? false,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        obscuringCharacter: '*',
        style: widget.textstyle ?? const TextStyle(color: Colors.black, fontSize: 12),
        decoration: InputDecoration(
            counter: Offstage(),
            prefix: widget.prefix,
            prefixIcon: widget.prefixicon,
            suffixIcon: widget.suffixicon,
            filled: true,
            contentPadding: const EdgeInsets.all(10),
            fillColor: const Color.fromARGB(255, 252, 252, 253),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: BorderSide(
                  color: widget.enabledBordercolor != null
                      ? widget.enabledBordercolor
                      : Color(0xffdddddd),
                  style: BorderStyle.solid,
                  width: 1,
                )),
            errorMaxLines: 1,
            errorStyle: const TextStyle(fontSize: .01),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide(
                  color: Color(0xff0084f7),
                  style: BorderStyle.solid,
                  width: 1,
                )),
            errorBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(
                  color: Colors.red,
                  style: BorderStyle.solid,
                )),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide(
                  color: Color(0xff0084f7),
                  style: BorderStyle.solid,
                  width: 1,
                )),
            labelText: widget.labelText,
            // labelStyle:
            //     const TextStyle(color: Color.fromARGB(255, 100, 100, 100)),
            labelStyle: widget.labelStyle,
            hintText: widget.hintText,
            hintStyle:
                TextStyle(color: const Color.fromARGB(255, 180, 180, 180))),
        onChanged: widget.onChanged != null
            ? (value) {
                // print('dzvjkbshdvbjsdbv');
                // print(widget.onChanged(value));
                widget.onChanged!(value);
              }
            : null,
        validator: widget.validator
            ? (value) {
                if (widget.maxLength != null &&
                    widget.maxLength != value?.length) {
                  return "Required *";
                }
                if (value == null || value.isEmpty) {
                  return "Required *";
                } else {
                  return null;
                }
              }
            : null,
      ),
    );
  }
}
