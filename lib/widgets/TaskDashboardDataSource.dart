// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// import '../constants/static.dart';
// import '../models/TaskStatusModel.dart';
//
// class TaskDataSource extends DataGridSource {
//   final BuildContext context;
//   TaskDataSource({
//     required this.context,
//     required List<TaskStatusModel> tasks,
//     required this.fetchMoreData,
//     required this.selectedRowIds,
//     this.onRowSelectionChanged,
//     this.showOutgoingTasks,
//     this.searchController,
//     required this.completedSelectedRowIds
//   }) {
//     _tasks = tasks;
//     _buildDataGridRows();
//   }
//
//   final void Function(String rowId, bool isSelected)? onRowSelectionChanged;
//   List<TaskStatusModel> get tasksList => _tasks;
//   final List<String> selectedRowIds;
//   final List<String> completedSelectedRowIds;
//   late List<TaskStatusModel> _tasks;
//   final Future<List<TaskStatusModel>> Function() fetchMoreData;
//   List<DataGridRow> _rows = [];
//   var showOutgoingTasks;
//   var searchController;
//
//
//
//
//   void _buildDataGridRows() {
//     _rows = _tasks.asMap().entries.map<DataGridRow>((entry) {
//       int index = entry.key;
//       TaskStatusModel task = entry.value;
//       // print("this is the task :---------------${task.toJson()}");
//
//       return DataGridRow(cells: [
//         DataGridCell(columnName: 'selectAll', value: ""),
//         DataGridCell(columnName: 'sno', value: "${index + 1}"),
//         DataGridCell(columnName: 'title', value: task.title ?? ""),
//         DataGridCell(columnName: 'description', value: task.description.isEmpty ? "-" : task.description),
//         DataGridCell(columnName: 'date', value: task.completion_date ?? ""),
//         DataGridCell(columnName: 'completedon', value: task.completedon ?? ""),
//         DataGridCell(columnName: 'department', value: task.created_by_department ?? ""),
//         DataGridCell(columnName: 'assignedBy', value: task.created_by ?? ""),
//         DataGridCell(columnName: 'assignedTo', value: task.assigned_to.join(", ")),
//         DataGridCell(columnName: 'type', value: task.task_type_title ?? ""),
//         DataGridCell(columnName: 'task_priority', value: task.task_priority ?? ""),
//         DataGridCell(columnName: 'task_category_name', value: task.task_category_name ?? "-"),
//         DataGridCell(columnName: 'status', value: task.status ?? ""),
//         DataGridCell(columnName: 'frequency', value: task.schedule_type ?? "-"),
//         DataGridCell(columnName: 'dueDays', value: task.due_days?.toString() ?? ""),
//       ]);
//     }).toList();
//   }
//
//
//
//
//   @override
//   List<DataGridRow> get rows => _rows;
//
//   @override
//   DataGridRowAdapter buildRow(DataGridRow row) {
//     int rowIndex = _rows.indexOf(row);
//     final TaskStatusModel task = _tasks[rowIndex];
//
//     // Get status value
//     String status = row.getCells().firstWhere((cell) => cell.columnName == 'status',
//       orElse: () => DataGridCell(columnName: 'status', value: ""),
//     ).value.toString().toLowerCase();
//
//     Color dotColor = Colors.transparent; // Default
//     if (status == "complete") {
//       dotColor = Colors.green;
//     } else if (status == "overdue") {
//       dotColor = Colors.red;
//     }
//
//     Color statusTextColor = Colors.black;
//     if (status == "complete") {
//       statusTextColor = Colors.green;
//     } else if (status == "overdue") {
//       statusTextColor = Colors.red;
//     }
//
//     return DataGridRowAdapter(
//       // color: task.is_outgoing == true ? Color(0xffFCE7D3) : rowIndex.isOdd ? Color(0xfff3f3f3) : Color(0xfff2f8fa),
//       color: (task.is_outgoing == true && showOutgoingTasks==true) ? Color(0xffFCE7D3) : (task.is_outgoing == false && showOutgoingTasks==true) ? Colors.white :
//       rowIndex.isOdd ? Color(0xfff3f3f3) : Color(0xfff2f8fa),
//       cells: row.getCells().map<Widget>((dataCell) {
//         if (dataCell.columnName == "selectAll" && task.status?.toLowerCase() != "complete") {
//           final id = task.row_id.toString();
//           final isChecked = selectedRowIds.contains(id);
//
//           return Container(
//             alignment: Alignment.center,
//             child: Checkbox(
//               checkColor: Colors.white,
//               activeColor: Colors.green,
//               hoverColor: Colors.transparent,
//               overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
//               value: isChecked,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//               onChanged: (bool? value) {
//                 if (value == true) {
//                   if (!selectedRowIds.contains(id)) selectedRowIds.add(id);
//                   onRowSelectionChanged?.call(id, true);
//                 } else {
//                   selectedRowIds.remove(id);
//                   onRowSelectionChanged?.call(id, false);
//                 }
//                 notifyListeners();
//               },
//             ),
//           );
//         }
//         if (dataCell.columnName == "selectAll" && task.status?.toLowerCase() == "complete") {
//           bool isChecked = completedSelectedRowIds.contains(task.row_id.toString());
//           return Container(
//             alignment: Alignment.center,
//             child: Checkbox(
//               checkColor: Colors.white,
//               activeColor: Colors.green,
//               hoverColor: Colors.transparent,
//               overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
//               value: !isChecked,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//               onChanged: (bool? value) {
//                 if (value == true) {
//                   completedSelectedRowIds.add(task.row_id.toString());
//                 } else {
//                   completedSelectedRowIds.remove(task.row_id.toString());
//                 }
//
//                 //  Force UI update and trigger onSelectionChanged manually
//                 notifyListeners();
//                 // if (onRowSelectionChanged != null) {
//                 //   onRowSelectionChanged!(task.row_id.toString(), value ?? false);
//                 // }
//               },
//             ),
//           );
//         }
//
//
//         if (dataCell.columnName == "sno") {
//           return Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                 child: Text(
//                   dataCell.value.toString(),
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ),
//               Container(
//                 width: 8,
//                 height: 8,
//                 margin: const EdgeInsets.only(left: 4),
//                 decoration: BoxDecoration(
//                   color: dotColor,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ],
//           );
//         }
//
//         if (dataCell.columnName == "frequency") {
//           return Row(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: Text(
//                   task.schedule_type ?? "-",
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ),
//               if (task.schedule_type != "Daily" &&
//                   task.task_type_title != "Normal")
//                 IconButton(
//                   hoverColor: Colors.transparent,
//                   tooltip: "Complete Till",
//                   icon: const Icon(Icons.arrow_right, size: 16.0, color: Colors.black),
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                   onPressed: () {
//                     showRecurringDetailsDialog(
//                       context,
//                       task.schedule_type ?? "",
//                       task.reminder_list ?? [],
//                     );
//                   },
//                 )
//             ],
//           );
//         }
//
//
//         if (dataCell.columnName == "assignedTo") {
//           return Row(
//             children: [
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: searchController == null ? Text(
//                     task.assigned_to.join(", ") ?? "-",
//                     style: const TextStyle(fontSize: 12,color: Colors.black),
//                     overflow: TextOverflow.ellipsis,
//                   ) : RichText(
//                     overflow: TextOverflow.ellipsis,
//                     text: TextSpan(
//                       style: const TextStyle(fontSize: 12,color: Colors.black),
//                       children: highlightTextOnSearching(
//                         task.assigned_to.join(", ") ?? "-",
//                         searchController.text,
//                         TextStyle(backgroundColor: Colors.yellow,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//                 IconButton(
//                   hoverColor: Colors.transparent,
//                   tooltip: "User Departments",
//                   icon: Icon(Icons.arrow_right, size: 16.0, color: Colors.black),
//                   // padding: EdgeInsets.zero,
//                   // constraints: const BoxConstraints(),
//                   onPressed: () {
//                     // print("this is the loginindeUserRole:-----$loggedInUserRole");
//                     // for(var i in task.assigned_to_details!){
//                     //   print(":---------------------${i.toJson()}");
//                     // }
//                     showDialog(
//                       context: context,
//                       builder: (_) => AlertDialog(
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                         insetPadding: EdgeInsets.zero,
//                         titlePadding: EdgeInsets.zero,
//                         contentPadding: EdgeInsets.zero,
//                         title:Container(
//                           alignment: Alignment.centerLeft,
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: Color(0xff6482AD),
//                             borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
//                           ),
//                           child: const Text("Assigned Users Department:", style: TextStyle(fontSize: 16,color: Colors.white)),
//                         ),
//                         content: Container(
//                           margin: EdgeInsets.only(top: 8),
//                           width: 350,
//                           height: 300,
//                           child: SingleChildScrollView(
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 SizedBox(
//                                   width: 300,
//                                   child: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: task.assigned_to_details!.map((item) {
//                                       return Container(
//                                         margin: const EdgeInsets.symmetric(vertical: 6),
//                                         padding: const EdgeInsets.all(10),
//                                         decoration: BoxDecoration(
//                                           color: Colors.blue.shade50,
//                                           borderRadius: BorderRadius.circular(8),
//                                           border: Border.all(color: Colors.blue.shade200),
//                                         ),
//                                         child: Row(
//                                           children: [
//                                             CircleAvatar(
//                                               radius: 16,
//                                               backgroundColor: Color(0xff81a0d3),
//                                               child: Text(
//                                                 item.name[0].toUpperCase(),
//                                                 style: TextStyle(
//                                                     fontSize: 14, color: Colors.white),
//                                               ),
//                                             ),
//                                             SizedBox(width: 10),
//                                             Column(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(item.name,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600)),
//                                                 SizedBox(height: 6),
//                                                 Text(item.department,style: TextStyle(fontSize: 10,color: Colors.black)),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     }).toList(),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: const Text("Close", style: TextStyle(fontSize: 14)),
//                           ),
//                         ],
//                       ),
//                     );
//                     },
//                 )
//             ],
//           );
//         }
//
//
//         return Container(
//           alignment: Alignment.centerLeft,
//           padding: const EdgeInsets.symmetric(horizontal: 8),
//           child: searchController == null ? Text(
//             dataCell.value.toString(),
//             style: TextStyle(
//               fontSize: 12,
//               color: dataCell.columnName == "status" ? statusTextColor : Colors.black,
//             ),
//           ) : RichText(
//             text: TextSpan(
//               style: TextStyle(fontSize: 12,
//                 color: dataCell.columnName == "status" ? statusTextColor : Colors.black,
//               ),
//               children: highlightTextOnSearching(
//                 dataCell.value.toString(),
//                 searchController.text,
//                 TextStyle(backgroundColor: Colors.yellow,
//                 ),
//               ),
//             ),
//           ),
//           // child: RichText(
//           //   text: TextSpan(
//           //     style: TextStyle(fontSize: 12,
//           //       color: dataCell.columnName == "status" ? statusTextColor : Colors.black,
//           //     ),
//           //     children: highlightTextOnSearching(
//           //       dataCell.value.toString(),
//           //       searchController.text,
//           //       TextStyle(backgroundColor: Colors.yellow,
//           //       ),
//           //     ),
//           //   ),
//           // ),
//         );
//       }).toList(),
//     );
//   }
//
//   @override
//   Future<void> handleLoadMoreRows() async {
//     final newItems = await fetchMoreData();
//     if (newItems.isNotEmpty) {
//       _tasks.addAll(newItems);
//       _buildDataGridRows();
//       notifyListeners();
//     }
//   }
//
//
//   // --- Show Dialog
//   void showRecurringDetailsDialog(BuildContext context, String scheduleType, List<dynamic> remindersList) {
//     List<dynamic> formattedList = [];
//
//     if (scheduleType.toLowerCase() == "weekly") {
//       formattedList = remindersList.map((e) => e.complete_till.toString()).toList();
//     } else if (scheduleType.toLowerCase() == "monthly" || scheduleType.toLowerCase() == "yearly") {
//       formattedList = remindersList.map((e) {
//         var completeTill = e.complete_till ?? "";
//         var parts = completeTill.split("-");
//         if (parts.length == 2) {
//           var day = parts[0];
//           var month = int.tryParse(parts[1]) ?? 0;
//           const monthNames = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
//             "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
//           if (month >= 1 && month <= 12) {
//             return "$day ${monthNames[month]}";
//           }
//         }
//         return completeTill;
//       }).toList();
//     } else if (scheduleType.toLowerCase() == "daily") {
//       formattedList = ["Daily"];
//     } else {
//       formattedList = remindersList.map((e) => e.complete_till.toString()).toList();
//     }
//
//     showDialog(
//       context: context,
//       builder: (_) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 350, maxHeight: 400),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 alignment: Alignment.centerLeft,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Color(0xff6482AD),
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
//                 ),
//                 child: const Text("Complete Till:", style: TextStyle(fontSize: 16,color: Colors.white)),
//               ),
//               const SizedBox(height: 12),
//               Flexible(
//                 child: SingleChildScrollView(
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 14),
//                     child: GridView.builder(
//                       shrinkWrap: true,
//                       itemCount: formattedList.length,
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 4,
//                         crossAxisSpacing: 10,
//                         mainAxisSpacing: 10,
//                         childAspectRatio: 2.5,
//                       ),
//                       itemBuilder: (context, index) {
//                         return Container(
//                           alignment: Alignment.center,
//                           decoration: BoxDecoration(
//                             color: scheduleType == "Daily"
//                                 ? null
//                                 : const Color.fromARGB(255, 245, 229, 227),
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
//                             child: Text(formattedList[index]),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Container(
//                 margin: const EdgeInsets.only(top: 12),
//                 alignment: Alignment.centerRight,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text("Close", style: TextStyle(fontSize: 14)),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
// }
