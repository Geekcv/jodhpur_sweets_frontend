import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../controllers/api_controller.dart';
import '../utilities/sizeconfig.dart';

class SearchDropdownInImportData extends StatefulWidget {
  final Function(String?) onChanged;
  var selectedDepartmentId;

  SearchDropdownInImportData({
    super.key,
    required this.onChanged,
    required this.selectedDepartmentId
  });

  @override
  State<SearchDropdownInImportData> createState() => _SearchDropdownInImportDataState();
}

class _SearchDropdownInImportDataState extends State<SearchDropdownInImportData> {

  List? _departments = [];
  // String selectedDepartment = '';
  fetchDept() async {
    // var resp = await ApiController().fetchDepartment();
    // if (resp != false) {
    //   if(mounted){
    //     setState(() {
    //       for (var i = 0; i < resp.length; i++) {
    //         if (resp[i].department_name != '') {
    //           _departments?.add({
    //             "title": resp[i].department_name,
    //             "value": resp[i].row_Id,
    //           });
    //         }
    //       }
    //     });
    //   }
    // } else {
    //   return [];
    // }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDept();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      enabled: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a department';
        }
        return null;
      },
      items: (filter, loadProps) {
        return _departments!.map((dept) => dept['title'].toString()).toList();
      },
      selectedItem: widget.selectedDepartmentId != null
          ? _departments!
          .firstWhere(
            (dept) => dept['value'] == widget.selectedDepartmentId,
        orElse: () => {'title': 'Select Department'},
      )['title']
          : null,
      onChanged: (value) {
        final selected = _departments!.firstWhere(
              (dept) => dept['title'] == value,
          orElse: () => {'value': null},
        );
        final selectedId = selected['value'];
        widget.onChanged(selectedId); // notify parent
        setState(() {});
      },
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          hintText: "Select Department",
          hintStyle: TextStyle(
            fontSize: 12,
            color: Color(0xff0d0d0d),
          ),
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
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(
                color: Color(0xff0084f7),
                style: BorderStyle.solid,
                width: 1,
              )),
          labelStyle: TextStyle(color: Color(0xff0d0d0d)),
        ),
      ),
      popupProps: PopupProps.menu(fit: FlexFit.loose,
        // constraints: BoxConstraints(),
        constraints: _departments!.length > 5 ?BoxConstraints.tightFor(height: SizeConfig.blockSizeHorizontal!*28) : BoxConstraints(),
        showSearchBox: true,
          searchFieldProps: TextFieldProps(
            textInputAction: TextInputAction.done,
            style: const TextStyle(fontSize: 12),
            onSubmitted: (text) {
              try {
                final selected = _departments!.firstWhere((e) => e['title'].toString().toLowerCase().contains(text.toLowerCase()));
                final selectedId = selected['value'];
                widget.onChanged(selectedId); // notify parent
                Navigator.of(context).pop();
                setState(() {});
              } catch (e) {
                print("No match found");
              }
            },
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
              hintText: 'Search',
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: const BorderSide(color: Color(0xffdddddd)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: const BorderSide(color: Color(0xff0084f7)),
              ),
            ),
          ),
        // itemBuilder: (context, item, isDisabled, isSelected) {
        //   return Padding(
        //     padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        //     child: Text(
        //       item.toString(),
        //       style: TextStyle(
        //         fontSize: 16,
        //         color: isDisabled ? Colors.grey : (isSelected ? Colors.blue : Colors.black),
        //       ),
        //     ),
        //   );
        // }
      ),
      suffixProps: const DropdownSuffixProps(
        dropdownButtonProps : DropdownButtonProps(
          iconOpened:Icon(Icons.arrow_drop_up, size: 24,color: Colors.black),
          iconClosed:Icon(Icons.arrow_drop_down, size: 24,color: Colors.black87),
        ),
      ),
    );
  }
}