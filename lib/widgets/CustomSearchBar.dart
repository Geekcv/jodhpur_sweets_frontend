import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomSearchBar extends StatefulWidget {
  CustomSearchBar(
      {super.key,
        required this.controller,
        this.labelText,
        this.height,
        this.width,
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
        this.enabledBordercolor,
        this.readOnly = false,
        this.onChanged});
  TextEditingController controller;
  var labelText;
  var labelStyle;
  var auto_ValidateMode;
  var hintText;
  double? height;
  double? width;
  var maxLines;
  var readOnly;
  var inputFormatters;
  var maxLength;
  Widget? prefix;
  var suffixicon;
  var prefixicon;
  var decoration;
  bool? obscureText;
  var enabledBordercolor;
  Function? onChanged;
  bool validator;
  TextInputType? keyboardType;
  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
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
        style: TextStyle(color: Colors.black, fontSize: 12),
        decoration: InputDecoration(
            prefixIcon: widget.prefixicon,
            filled: true,
            contentPadding: EdgeInsets.all(10),
            fillColor: Color.fromARGB(255, 252, 252, 253),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color:Color(0xffdddddd),style: BorderStyle.solid,width: 1)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xff0084f7),style: BorderStyle.solid,width: 1)),
            labelText: widget.labelText,
            labelStyle: TextStyle(fontSize: 12),
            hintText: widget.hintText,
            hintStyle:TextStyle(fontSize: 12,fontWeight: FontWeight.w100)
        ),
        onChanged: widget.onChanged != null
            ? (value) {
          // print('dzvjkbshdvbjsdbv');
          // print(widget.onChanged(value));
          widget.onChanged!(value);
        }: null,
      ),
    );
  }
}
