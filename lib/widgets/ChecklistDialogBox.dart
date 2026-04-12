// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../controllers/api_controller.dart';
// import '../provider/provider.dart';
// import '../utilities/sizeconfig.dart';
// import '../utilities/utils.dart' show Utilities;
// import 'TextInputField.dart';
//
// class Checklistdialogbox extends ConsumerStatefulWidget {
//   Checklistdialogbox({super.key,this.checklist_rowid,this.checklist_title,
//   this.checklist_items,this.checklist_desc});
//
//   var checklist_rowid;
//   var checklist_title;
//   var checklist_desc;
//   var checklist_items;
//
//   @override
//   ConsumerState<Checklistdialogbox> createState() => _ChecklistdialogboxState();
// }
//
// class _ChecklistdialogboxState extends ConsumerState<Checklistdialogbox> {
//
//
//   TextEditingController _checkListName = TextEditingController();
//   TextEditingController _description = TextEditingController();
//   List<TextEditingController> _checkListItemControllers = [TextEditingController()];
//   List<TextEditingController?> _checkListItemdescControllers = [null];
//   bool isButtonDisabled = false;
//
//   final _formKey = GlobalKey<FormState>();
//
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     if(widget.checklist_rowid!=null){
//       _checkListName.text = widget.checklist_title;
//       _description.text=widget.checklist_desc;
//
//       _checkListItemControllers.clear();
//       _checkListItemdescControllers.clear();
//
//       for (var item in widget.checklist_items) {
//         final titleController = TextEditingController(text: item['title'] ?? '');
//         // print("titleController:------$titleController\n");
//         final descText = item['description'] ?? '';
//         // print("descTest:------------$descText\n");
//         final descController = descText.isNotEmpty ? TextEditingController(text: descText) : null;
//         // print("descController:-------------$descController\n");
//         _checkListItemControllers.add(titleController);
//         _checkListItemdescControllers.add(descController);
//       }
//
//     }
//     // print("This is the row id of the checklist:--------${widget.checklist_items}");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(5.0))
//             ),
//             backgroundColor: Colors.white,
//             title: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(widget.checklist_rowid==null?
//                   "Create CheckList" : "CheckList",
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 IconButton(
//                   splashRadius: 20,
//                   splashColor: Colors.transparent,
//                   hoverColor: Colors.transparent,
//                   icon: Icon(Icons.cancel_outlined),
//                   color: Colors.red,
//                   tooltip: 'Close',
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                 )              ],
//             ),
//             content: Form(
//               key: _formKey,
//               child: Container(
//                 height: SizeConfig.blockSizeVertical!*55,
//                 width: SizeConfig.blockSizeHorizontal!*25,
//                 // color: Colors.green,
//                 child: Column(
//                   children: [
//                     Expanded(
//                       child: SingleChildScrollView(
//                         child: Column(
//                           children: [
//                             Container(
//                               alignment: Alignment.center,
//                               padding: EdgeInsets.all(4.0),
//                               child: Column(
//                                 mainAxisAlignment:MainAxisAlignment.start,
//                                 crossAxisAlignment:CrossAxisAlignment.start,
//                                 children: [
//                                   Padding(
//                                     padding: EdgeInsets.all(8.0),
//                                     child: Container(
//                                       // color: Colors.green,
//                                       width: 300,
//                                       child: CustomTextInput(
//                                         inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^\s+'))],
//                                         controller: _checkListName,
//                                         textstyle: TextStyle(color: Colors.black, fontSize: 12),
//                                         maxLines: 1,
//                                         validator: true,
//                                         labelText: "Checklist Name",
//                                         labelStyle: TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.black
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsets.all(8.0),
//                                     child: SizedBox(
//                                       width: 300,
//                                       child: CustomTextInput(
//                                         inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^\s+'))],
//                                         controller: _description,
//                                         textstyle: TextStyle(color: Colors.black, fontSize: 12),
//                                         maxLines: 1,
//                                         validator: true,
//                                         labelText: "Description",
//                                         labelStyle: TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.black
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsets.all(8.0),
//                                     child: SingleChildScrollView(
//                                       scrollDirection: Axis.vertical,
//                                       child: Container(
//                                         // color: Colors.blue,
//                                         // height: _checkListItemControllers.length!=0 ? SizeConfig.blockSizeVertical!*18 : SizeConfig.blockSizeVertical!*1,
//                                         width: 300,
//                                         child: ListView.builder(
//                                           shrinkWrap: true,
//                                           itemCount: _checkListItemControllers.length,
//                                           itemBuilder: (context, index) {
//                                             // print("TExtttt:-----${_checkListItemControllers.length}");
//                                             return Container(
//                                               // height: SizeConfig.blockSizeVertical!*18,
//                                               // color: Colors.green,
//                                               margin: EdgeInsets.only(top: 12),
//                                               child: Column(
//                                                 children: [
//                                                   Row(
//                                                     children: [
//                                                       Expanded(
//                                                         child: TextFormField(
//                                                           inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^\s+'))],
//                                                           controller: _checkListItemControllers[index],
//                                                           maxLines: 1,
//                                                           style: TextStyle(
//                                                             fontSize: 12,
//                                                           ),
//                                                           onFieldSubmitted: (_) {
//                                                             if (_checkListItemControllers[index].text.trim().isNotEmpty) {
//                                                               setState((){
//                                                                 _checkListItemControllers.add(TextEditingController());
//                                                                 _checkListItemdescControllers.add(null);
//                                                               });}
//                                                           },
//                                                           decoration: InputDecoration(
//                                                               suffixIcon: Row(
//                                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                                 mainAxisSize: MainAxisSize.min,
//                                                                 children: [
//                                                                   IconButton(
//                                                                     // splashRadius: 16,
//                                                                     hoverColor:Colors.transparent,
//                                                                     focusColor:Colors.transparent,
//                                                                     splashColor:Colors.transparent,
//                                                                     icon: Icon(Icons.close, color: Colors.red,size: 15),
//                                                                     onPressed: () {
//                                                                       setState(() {
//                                                                         _checkListItemControllers.removeAt(index);
//                                                                         _checkListItemdescControllers.removeAt(index);
//                                                                       });
//                                                                     },
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                               enabledBorder: OutlineInputBorder(
//                                                                   borderRadius: BorderRadius.circular(5.0),
//                                                                   borderSide: BorderSide(
//                                                                     color: Color(0xffdddddd),
//                                                                     style: BorderStyle.solid,
//                                                                     width: 1,
//                                                                   )),
//                                                               border: OutlineInputBorder(),
//                                                               // hintText: 'Item ${index+1} title',
//                                                               labelText: "Item ${index+1} title",
//                                                               labelStyle: TextStyle(
//                                                                   fontSize: 12,
//                                                                   color: Colors.black
//                                                               )
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       if (_checkListItemdescControllers[index] == null)
//                                                         IconButton(
//                                                           tooltip: "Add description",
//                                                           hoverColor:Colors.transparent,
//                                                           focusColor:Colors.transparent,
//                                                           splashRadius: 20.0,
//                                                           splashColor:Colors.transparent,
//                                                           icon: Padding(
//                                                             padding: EdgeInsets.only(left: 14),
//                                                             child: Icon(Icons.add, color: Colors.green,size: 15),
//                                                           ),
//                                                           onPressed: () {
//                                                             setState((){
//                                                               _checkListItemdescControllers[index] = TextEditingController();
//                                                             });
//                                                           },
//                                                         ),
//                                                     ],
//                                                   ),
//                                                   if (_checkListItemdescControllers[index] != null)
//                                                     Padding(
//                                                       padding: EdgeInsets.only(top: 8 , bottom: 8),
//                                                       child: TextFormField(
//                                                         controller: _checkListItemdescControllers[index],
//                                                         maxLines: 2,
//                                                         style: TextStyle(
//                                                           fontSize: 12,
//                                                         ),
//                                                         decoration: InputDecoration(
//                                                             suffixIcon: IconButton(
//                                                               splashRadius: 18,
//                                                               hoverColor:Colors.transparent,
//                                                               splashColor:Colors.transparent,
//                                                               icon: Icon(Icons.close, color: Colors.red,size: 15),
//                                                               onPressed: () {
//                                                                 setState(() {
//                                                                   // _checkListItemdescControllers.removeAt(index);
//                                                                   _checkListItemdescControllers[index] = null;
//                                                                 });
//                                                               },
//                                                             ),
//                                                             enabledBorder: OutlineInputBorder(
//                                                                 borderRadius: BorderRadius.circular(5.0),
//                                                                 borderSide: BorderSide(
//                                                                   color: Color(0xffdddddd),
//                                                                   style: BorderStyle.solid,
//                                                                   width: 1,
//                                                                 )),
//                                                             border: OutlineInputBorder(),
//                                                             // hintText: 'Item ${index+1} title',
//                                                             labelText: "Item ${index+1} description",
//                                                             labelStyle: TextStyle(
//                                                                 fontSize: 12,
//                                                                 color: Colors.black
//                                                             )
//                                                         ),
//                                                       ),
//                                                     )
//                                                 ],
//                                               ),
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Container(
//                                     margin: EdgeInsets.only(top: 10),
//                                     width: SizeConfig.blockSizeHorizontal!*21,
//                                     child: TextButton.icon(
//                                       style: ButtonStyle(
//                                         shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
//                                       ),
//                                       onPressed: () {
//
//                                         if (_checkListItemControllers.isNotEmpty) {
//                                           final lastIndex = _checkListItemControllers.length - 1;
//                                           if (_checkListItemControllers[lastIndex].text.trim().isEmpty) {
//                                             ScaffoldMessenger.of(context).showSnackBar(
//                                               SnackBar(duration:Duration(seconds: 2),
//                                                   content: Text("Please fill the previous item before adding a new one")),
//                                             );
//                                             return;
//                                           }
//                                           // if (_checkListItemdescControllers[lastIndex] != null &&
//                                           //     _checkListItemdescControllers[lastIndex]!.text.trim().isEmpty) {
//                                           //   ScaffoldMessenger.of(context).showSnackBar(
//                                           //     SnackBar(content: Text("Please fill the description before adding a new one")),
//                                           //   );
//                                           //   return;
//                                           // }
//                                         }
//
//                                         setState((){
//                                           _checkListItemControllers.add(TextEditingController());
//                                           _checkListItemdescControllers.add(null);
//                                         });
//                                         // print("Text length:---------${_checkListItemControllers.length}");
//                                       },
//                                       icon: Icon(Icons.add,color: Colors.black,size: 16,),
//                                       label: Align(
//                                           alignment: Alignment.centerLeft,
//                                           child: Text('Add New Item',style: TextStyle(fontSize: 12,color: Colors.black),)),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Container(
//                       alignment: Alignment.center,
//                       padding: EdgeInsets.all(8.0),
//                       child: SizedBox(
//                         // height: 40,
//                         // width: 100,
//                         child: ElevatedButton(
//                           onPressed: isButtonDisabled ? null : () async{
//                             if (!_formKey.currentState!.validate()) return;
//
//                             if(_checkListItemControllers.isEmpty || (_checkListItemControllers[0].text.isEmpty && widget.checklist_rowid==null)){
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(duration:Duration(seconds: 2),
//                                     content: Text("Please add at least one item in checklist")),
//                               );
//                               return;
//                             }
//                             setState((){isButtonDisabled = true;});
//                             // List<Map<String, dynamic>> items = _checkListItemControllers
//                             //     .map((controller) => {
//                             //   "title": controller.text,
//                             //   "description": "",
//                             //   "id": Utilities().getRandomId(4)
//                             // }).toList();
//                             // print('Checklist successfully');
//                             List<Map<String, dynamic>> items = [];
//                             for (int i = 0; i < _checkListItemControllers.length; i++) {
//                               if(_checkListItemControllers[i].text.isEmpty){
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(duration:Duration(seconds: 2),
//                                       content: Text("Please fill item proper")),
//                                 );
//                                 setState((){isButtonDisabled = false;});
//                                 return;
//                               }
//                               items.add({
//                                 "title": _checkListItemControllers[i].text,
//                                 "description": _checkListItemdescControllers[i]?.text ?? "",
//                                 "id": Utilities().getRandomId(4)
//                               });
//                             }
//                             // _createChecklist();
//                             var response = widget.checklist_rowid==null ? await ApiController().createChecklist(
//                                 context: context,
//                                 checklist_title: _checkListName.text,
//                                 description: _description.text,checklist_items: items) :
//                             await ApiController().createChecklist(
//                                 context: context,
//                                 checklist_title: _checkListName.text,
//                                 description: _description.text,checklist_items: items,row_id: widget.checklist_rowid);
//
//
//                             // print("This is the response:-------$response");
//                             if(response['status']==0){
//                               setState((){
//                                 isButtonDisabled = false;
//                               });
//                               Navigator.pop(context);
//                               ref.watch(master_Provider).fetchChecklist();
//                             }
//                           },
//                           style: ButtonStyle(
//                             shape: WidgetStateProperty.all<
//                                 RoundedRectangleBorder
//                             >(
//                               RoundedRectangleBorder(
//                                 borderRadius:
//                                 BorderRadius.circular(5),
//                                 side: BorderSide(
//                                   color: Color(0xffffffff),
//                                 ),
//                               ),
//                             ),
//                             elevation: WidgetStateProperty.all(0),
//                             backgroundColor:
//                             WidgetStateProperty.all<Color>(
//                               Color(0xff3081c0),
//                             ),
//                             foregroundColor:
//                             WidgetStateProperty.all<Color>(
//                               Colors.white,
//                             ),
//                           ),
//                           child: widget.checklist_rowid==null ? Text(
//                             'Create',
//                             style: TextStyle(
//                               fontFamily: 'Roboto',
//                               fontSize: 12,
//                               // fontWeight: FontWeight.w400,
//                               color: Colors.white,
//                             ),
//                           ):Text(
//                             'Submit',
//                             style: TextStyle(
//                               fontFamily: 'Roboto',
//                               fontSize: 12,
//                               // fontWeight: FontWeight.w400,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         });
//   }
// }
