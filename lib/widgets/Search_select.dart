// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flutter/material.dart';

// import '../../constants/colors.dart';

// class SearchSelect extends StatefulWidget {
//   final items;

//   final label;
//   final padding;
//   final bool showLabel;
//   final selectedItem;
//   final width;
//   final iconArr;
//   final onChanged;
//   SearchableSelectList(
//       {this.selectedItem,
//       this.label,
//       this.padding,
//       this.iconArr,
//       this.showLabel = true,
//       this.items,
//       required this.onChanged,
//       this.width});
//   @override
//   _SearchSelectState createState() => _SearchSelectState();
// }

// class _SearchSelectState extends State<SearchSelect> {
//   @override
//   Widget build(BuildContext context) {
//   // print(widget.padding);
//     var options = [];
//     options = widget.items;
//     return Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (widget.showLabel)
//             Padding(
//               padding: widget.padding != null
//                   ? EdgeInsets.only(
//                       left: widget.padding,
//                       right: widget.padding,
//                       top: 8,
//                       bottom: 8)
//                   : const EdgeInsets.only(
//                       top: 8.0, bottom: 8, left: 20, right: 20),
//               child: Text(
//                 widget.label,
//                 // style: labelTextStyle,
//               ),
//             ),
//           Container(
//             color: rsTextFillColor,
//             margin: widget.padding != null
//                 ? EdgeInsets.only(left: widget.padding, right: widget.padding)
//                 : const EdgeInsets.only(left: 20, right: 20),
//             child: SizedBox(
//               height: 40,
//               width: widget.width ?? MediaQuery.of(context).size.width * .85,
//               child: DropdownSearch<String>(
//                   popupProps: PopupProps.menu(
//                     showSearchBox: true,
//                     itemBuilder: (context, item, isDisabled, isSelected) {
//                       return Container(
//                         width: widget.width ?? 230,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             SizedBox(
//                               width: widget.width != null
//                                   ? widget.width - 40
//                                   : 170,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Text(
//                                   "${item}",
//                                   // style: labelTextStyle.copyWith(fontSize: 16),
//                                 ),
//                               ),
//                             ),
//                             if (widget.iconArr != null &&
//                                 widget.iconArr.contains(item))
//                               Padding(
//                                 padding: const EdgeInsets.all(4.0),
//                                 child: Icon(
//                                   Icons.done,
//                                   color: Colors.green,
//                                   size: 20,
//                                 ),
//                               )
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                   // showIcon: false,
//                   items: (filter, LoadProps) => options.map((map) {
//                         // print(map['title']);
//                         return ('${map['title']}');
//                       }).toList(),
//                   selectedItem: widget.selectedItem,
//                   // key: widget.label,
//                   onChanged: widget.onChanged),
//             ),
//           ),
//         ]);
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:dropdown_search/dropdown_search.dart';

// class SearchableSelectList extends StatefulWidget {
//   final items;
//   final label;
//   final bool showLabel;
//   final selectedItem;
//   final width;
//   final Function(String?)? onChanged;
//   SearchableSelectList(
//       {this.selectedItem,
//       this.label,
//       this.showLabel = false,
//       this.items,
//       required this.onChanged,
//       this.width});
//   @override
//   _SearchableSelectListState createState() => _SearchableSelectListState();
// }
// class _SearchableSelectListState extends State<SearchableSelectList> {
//   @override
//   Widget build(BuildContext context) {
//     var options = [];
//     options = widget.items;
//     return Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (widget.showLabel)
//             Padding(
//               padding: const EdgeInsets.only(
//                   top: 8.0, bottom: 8, left: 20, right: 20),
//               child: Text(
//                 widget.label,
//                 // style: labelTextStyle,
//               ),
//             ),
//           Container(
//             // color: rsTextFillColor,
//             margin: const EdgeInsets.only(left: 20, right: 20),
//             child: SizedBox(
//               height: 40,
//               width: widget.width ?? MediaQuery.of(context).size.width * .85,
//               child: DropdownSearch<String>(
//                   // showIcon: false,
//                   showSearchBox: true,
//                   mode: Mode.MENU,
//                   items: options.map((map) {
//                     // print(map['title']);
//                     return ('${map['title']}');
//                   }).toList(),
//                   selectedItem: widget.selectedItem,
//                   hint: widget.label,
//                   onChanged: widget.onChanged),
//             ),
//           ),
//         ]);
//   }
// }