// import 'package:flutter/material.dart';
//
// import '../models/fetchDepartment_model.dart';
// import '../utilities/sizeconfig.dart';
//
// class Departmentfilterdialogbox extends StatefulWidget {
//   Departmentfilterdialogbox({super.key,
//     required this.items,
//     required this.getSelectedDepartments,
//     required this.preselectedValues,
//     required this.onClearFilter,});
//
//     List<FetchDepartment_Model> items;
//     var preselectedValues;
//     Function getSelectedDepartments;
//     Function onClearFilter;
//
//   @override
//   State<Departmentfilterdialogbox> createState() => _DepartmentfilterdialogboxState();
// }
//
// class _DepartmentfilterdialogboxState extends State<Departmentfilterdialogbox> {
//
//   var selectedDepartments = [];
//   List<FetchDepartment_Model> temp_items = [];
//   bool selectAll = false;
//
//   @override
//   void initState() {
//     super.initState();
//     // print("This si the items:-------------${widget.items}");
//     // for(var i=0;i<widget.items.length;i++){
//     //   print("this is the data :-----------${widget.items[i].toJson()}");
//     // }
//     temp_items = List.from(widget.items);
//     selectedDepartments = List.from(widget.preselectedValues ?? []);
//   }
//
//   Widget _buildSelectAllCheckbox() {
//     return CheckboxListTile(
//       controlAffinity: ListTileControlAffinity.leading,
//       value: selectedDepartments.length == widget.items.length && widget.items.isNotEmpty,
//       title: Text(
//         'Select All',
//         style: TextStyle(
//           fontSize: 14,
//           fontWeight: selectAll ? FontWeight.w600 : FontWeight.w400,
//         ),
//       ),
//       onChanged: (bool? value) {
//         setState(() {
//           selectAll = value ?? false;
//           if (value == true) {
//             selectedDepartments = widget.items.map((e) => e.row_Id).toList();
//           } else {
//             selectedDepartments.clear();
//           }
//         });
//       },
//     );
//   }
//
//   Widget _buildSearchField() {
//     return Container(
//       height: 40,
//       child: TextField(
//         decoration: InputDecoration(
//           hintText: "Search department",
//           labelText: "Search department",
//           prefixIcon: Icon(Icons.search),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(5),
//           ),
//         ),
//         onChanged: (value) {
//           if (value.isEmpty) {
//             widget.items = List.from(temp_items);
//           } else {
//             widget.items = temp_items.where((item) {
//               return item.department_name!.toLowerCase().contains(value.toLowerCase());
//             }).toList();
//           }
//           setState(() {});
//         },
//       ),
//     );
//   }
//
//
//   Widget _buildDepartmentList() {
//     return ListView.builder(
//       itemCount: widget.items.length,
//       itemBuilder: (context, index) {
//         bool exists = selectedDepartments.contains(widget.items[index].row_Id);
//         return CheckboxListTile(
//           controlAffinity: ListTileControlAffinity.leading,
//           value: exists,
//           title: Text("${widget.items[index].department_name}",
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: exists ? FontWeight.w600 : FontWeight.w400,
//             ),
//           ),
//           onChanged: (bool? value) {
//             setState(() {
//               if (value == true) {
//                 selectedDepartments.add(widget.items[index].row_Id);
//               } else {
//                 selectedDepartments.remove(widget.items[index].row_Id);
//               }
//             });
//           },
//         );
//       },
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text("Departments"),
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(5),
//               border: Border.all(
//                   color: Colors.blue.shade200
//               ),
//             ),
//             child: TextButton.icon(
//               onPressed: ()async{
//                 if (widget.preselectedValues != null && widget.preselectedValues.isNotEmpty) {
//                   await widget.onClearFilter();
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(duration: Duration(seconds: 1),content: Text("Filter cleared successfully")),
//                   );
//                 } else {
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(duration: Duration(seconds: 1),content: Text("No filter to clear"),
//                     ),
//                   );
//                 }
//               },
//               icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.blue),
//               label: const Text("Clear Filter", style: TextStyle(color: Colors.blue, fontSize: 13)),
//             ),
//           ),
//           // PopupMenuButton<String>(
//           //   icon: Icon(Icons.more_vert),
//           //   onSelected: (value) {
//           //     if (value == "clear") {
//           //       widget.onClearFilter();
//           //       Navigator.pop(context);
//           //       ScaffoldMessenger.of(context).showSnackBar(
//           //         SnackBar(duration:Duration(seconds: 1), content: Text("Filter cleared")),
//           //       );
//           //     }
//           //   },
//           //   itemBuilder: (context) => [
//           //     PopupMenuItem(
//           //       value: "clear",
//           //       child: Text("Clear Filter",style: TextStyle(fontSize: 14),),
//           //     ),
//           //   ],
//           // ),
//         ],
//       ),
//       content: Container(
//         width: SizeConfig.blockSizeHorizontal! * 40,
//         height: SizeConfig.blockSizeHorizontal! * 25,
//         child: Column(
//           children: [
//             _buildSearchField(),
//             if (widget.items.length > 1)
//             _buildSelectAllCheckbox(),
//             Expanded(child: _buildDepartmentList()),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: (){
//             Navigator.pop(context);
//           },
//           child: Text("Close"),
//         ),
//         TextButton(
//           onPressed: () {
//             widget.getSelectedDepartments(selectedDepartments);
//             Navigator.pop(context);
//           },
//           child: Text("Ok"),
//         ),
//       ],
//     );
//   }
// }
