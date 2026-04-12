// import 'package:flutter/material.dart';
// import 'package:prosys_app_web/models/fetchUser_model.dart';
// import '../utilities/sizeconfig.dart';
//
// class Assigntofilter extends StatefulWidget {
//   Assigntofilter({
//     super.key,
//     required this.items,
//     required this.getSelectedUsers,
//     required this.preselectedValues,
//     required this.onClearFilter,
//   });
//
//   List<FetchuserModel> items;
//   var preselectedValues;
//   Function getSelectedUsers;
//   Function onClearFilter;
//
//   @override
//   State<Assigntofilter> createState() => _AssigntofilterState();
// }
//
// class _AssigntofilterState extends State<Assigntofilter> {
//   var selectedUsers = [];
//   List<FetchuserModel> temp_items = [];
//   bool selectAll = false;
//
//   @override
//   void initState() {
//     super.initState();
//     temp_items = List.from(widget.items);
//     selectedUsers = List.from(widget.preselectedValues ?? []);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text("Teams"),
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(5),
//               border: Border.all(
//                 color: Colors.blue.shade200
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
//           //   onSelected: (value) async{
//           //     if (value == "clear") {
//           //       if (widget.preselectedValues != null && widget.preselectedValues.isNotEmpty) {
//           //         await widget.onClearFilter();
//           //           Navigator.pop(context);
//           //           ScaffoldMessenger.of(context).showSnackBar(
//           //             const SnackBar(duration: Duration(seconds: 1),content: Text("Filter cleared successfully")),
//           //           );
//           //       } else {
//           //         Navigator.pop(context);
//           //         ScaffoldMessenger.of(context).showSnackBar(
//           //           const SnackBar(duration: Duration(seconds: 1),content: Text("No filter to clear"),
//           //           ),
//           //         );
//           //       }
//           //     }
//           //     // if (value == "clear") {
//           //     //   widget.onClearFilter();
//           //     //   Navigator.pop(context);
//           //     //   ScaffoldMessenger.of(context).showSnackBar(
//           //     //     SnackBar(duration:Duration(seconds: 1), content: Text("Filter cleared")),
//           //     //   );
//           //     // }
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
//             Expanded(child: _buildUserList()),
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
//             widget.getSelectedUsers(selectedUsers);
//             Navigator.pop(context);
//           },
//           child: Text("Ok"),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSearchField() {
//     return Container(
//       height: 40,
//       child: TextField(
//         decoration: InputDecoration(
//           hintText: "Search Team",
//           labelText: "Search Team",
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
//               return item.name!.toLowerCase().contains(value.toLowerCase());
//             }).toList();
//           }
//           setState(() {});
//         },
//       ),
//     );
//   }
//
//   Widget _buildSelectAllCheckbox() {
//     return CheckboxListTile(
//       controlAffinity: ListTileControlAffinity.leading,
//       value: selectedUsers.length == widget.items.length && widget.items.isNotEmpty,
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
//             selectedUsers = widget.items.map((e) => e.row_Id).toList();
//           } else {
//             selectedUsers.clear();
//           }
//         });
//       },
//     );
//   }
//
//   Widget _buildUserList() {
//     return ListView.builder(
//       itemCount: widget.items.length,
//       itemBuilder: (context, index) {
//         bool exists = selectedUsers.contains(widget.items[index].row_Id);
//         return CheckboxListTile(
//           controlAffinity: ListTileControlAffinity.leading,
//           value: exists,
//           title: Text(
//             "${widget.items[index].name}",
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: exists ? FontWeight.w600 : FontWeight.w400,
//             ),
//           ),
//           onChanged: (bool? value) {
//             setState(() {
//               if (value == true) {
//                 selectedUsers.add(widget.items[index].row_Id);
//               } else {
//                 selectedUsers.remove(widget.items[index].row_Id);
//               }
//             });
//           },
//         );
//       },
//     );
//   }
// }
