import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "../utilities/sizeconfig.dart";

class DropDownForCompliance extends StatefulWidget {
  final String name;

  Function? onTextInputChanged;
  Function? onDropInputChanged;
  var  menuMaxHeight;
  bool ignoring;
  List dropList;
  var validate;
  var selectedValue;
  DropDownForCompliance({
    this.menuMaxHeight,
    this.ignoring = false,
    required this.name,
    required this.dropList,
    this.onTextInputChanged,
    required this.onDropInputChanged,
    this.validate,
    this.selectedValue
  });

  @override
  State<DropDownForCompliance> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<DropDownForCompliance> {
  TextEditingController controller = TextEditingController();
  var selectedTitle;

  @override
  Widget build(BuildContext context) {
    // String? selectedValue = widget.selectedValue;

    var selectedValue = widget.dropList
        .map((item) => item['value'].toString())
        .contains(widget.selectedValue?.toString())
        ? widget.selectedValue?.toString()
        : null;
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Padding(padding: EdgeInsets.only(left: 58)),
          // if (widget.name != '')
          //   Text(
          //     widget.name,
          //     textAlign: TextAlign.right,
          //     style: TextStyle(
          //       fontSize: 12,
          //       fontWeight: FontWeight.w700,
          //       fontFamily: 'Roboto',
          //       color: Color(0xff110303),
          //     ),
          //   ),
          IgnorePointer(
              ignoring: widget.ignoring,
              child: DropdownButtonFormField(
                menuMaxHeight: widget.menuMaxHeight,
                validator: widget.validate ? (value) {
                  if (value == null || value.toString().isEmpty) {
                    return "Required *";
                  } else {
                    return null;
                  }
                }: null,
                value: selectedValue,
                dropdownColor: Colors.white,
                style: const TextStyle(
                  color: Color(0xff0d0d0d),
                  overflow: TextOverflow.ellipsis,
                ),
                isExpanded: true,
                hint: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff0d0d0d),
                    ),
                  ),
                ),
                items: widget.dropList.map((items) {
                  // print('cccccccccccc${items}');
                  return DropdownMenuItem(
                      value: items['value'].toString(),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          items['title'].toString(),
                          style: const TextStyle(color: Color(0xff0d0d0d)),
                        ),
                      ));
                }).toList(),
                onChanged: (value) {
                  selectedValue = value;
                  widget.onDropInputChanged!(value);
                  setState(() {});
                },
                decoration: InputDecoration(
                  filled: true,
                  contentPadding: const EdgeInsets.all(10),
                  fillColor: const Color.fromARGB(255, 252, 252, 253),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: const BorderSide(
                        color: Color(0xffdddddd),
                        style: BorderStyle.solid,
                        width: 1,
                      )),
                  errorMaxLines: 1,
                  errorStyle: const TextStyle(fontSize: .1),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      borderSide: BorderSide(
                        color: Colors.white,
                        style: BorderStyle.solid,
                        width: 2,
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
                  labelStyle: const TextStyle(color: Color(0xff0d0d0d)),
                ),
                // validator: (value) {
                //   if (value == null) {
                //     return 'Please select role';
                //   }
                // }
              )),
        ]);
  }
}
