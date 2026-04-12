// import 'package:flutter/material.dart';
//
// import '../models/FetchCategories.dart';
// import '../utilities/sizeconfig.dart';
//
// class CategoriesFilterDialogBox extends StatefulWidget {
//   CategoriesFilterDialogBox({super.key,
//     required this.items,
//     required this.getSelectedCategories,
//     required this.preselectedValues,
//     required this.onClearFilter,});
//
//   List<FetchCategories> items;
//   var preselectedValues;
//   Function getSelectedCategories;
//   Function onClearFilter;
//
//   @override
//   State<CategoriesFilterDialogBox> createState() => _CategoriesFilterDialogBoxState();
// }
//
// class _CategoriesFilterDialogBoxState extends State<CategoriesFilterDialogBox> {
//
//   var selectedCategories = [];
//   List<FetchCategories> temp_items = [];
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
//     selectedCategories = List.from(widget.preselectedValues ?? []);
//   }
//
//   Widget _buildSelectAllCheckbox() {
//     return CheckboxListTile(
//       controlAffinity: ListTileControlAffinity.leading,
//       value: selectedCategories.length == widget.items.length && widget.items.isNotEmpty,
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
//             selectedCategories = widget.items.map((e) => e.row_id).toList();
//           } else {
//             selectedCategories.clear();
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
//           hintText: "Search Category",
//           labelText: "Search Category",
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
//               return item.category_name!.toLowerCase().contains(value.toLowerCase());
//             }).toList();
//           }
//           setState(() {});
//         },
//       ),
//     );
//   }
//
//
//   Widget _buildCategoriesList() {
//     return ListView.builder(
//       itemCount: widget.items.length,
//       itemBuilder: (context, index) {
//         bool exists = selectedCategories.contains(widget.items[index].row_id);
//         return CheckboxListTile(
//           controlAffinity: ListTileControlAffinity.leading,
//           value: exists,
//           title: Text("${widget.items[index].category_name}",
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: exists ? FontWeight.w600 : FontWeight.w400,
//             ),
//           ),
//           onChanged: (bool? value) {
//             setState(() {
//               if (value == true) {
//                 selectedCategories.add(widget.items[index].row_id);
//               } else {
//                 selectedCategories.remove(widget.items[index].row_id);
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
//           Text("Categories"),
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
//             Expanded(child: _buildCategoriesList()),
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
//             widget.getSelectedCategories(selectedCategories);
//             Navigator.pop(context);
//           },
//           child: Text("Ok"),
//         ),
//       ],
//     );
//   }
// }
