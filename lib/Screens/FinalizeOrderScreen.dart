// import 'package:flutter/material.dart';
//
// class FinalizeOrderScreen extends StatefulWidget {
//   final List<Map<String, dynamic>> selectedItems;
//   const FinalizeOrderScreen({super.key, required this.selectedItems});
//
//   @override
//   State<FinalizeOrderScreen> createState() => _FinalizeOrderScreenState();
// }
//
// class _FinalizeOrderScreenState extends State<FinalizeOrderScreen> {
//   String? selectedSupplier;
//   bool isLoading = false;
//
//   // Static Suppliers List
//   final List<String> suppliers = ["Jodhpur Dairy", "Sweets Wholesale RJ", "Sugar & Spice Co.", "Global Milk Traders"];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Create Final Order", style: TextStyle(color: Colors.black, fontSize: 16)),
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Colors.black),
//         elevation: 0.5,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text("1. CHOOSE SUPPLIER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
//                   const SizedBox(height: 10),
//                   DropdownButtonFormField<String>(
//                     decoration: InputDecoration(
//                       filled: true,
//                       fillColor: const Color(0xffF8FAFC),
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
//                     ),
//                     hint: const Text("Select Supplier"),
//                     value: selectedSupplier,
//                     items: suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
//                     onChanged: (v) => setState(() => selectedSupplier = v),
//                   ),
//                   const SizedBox(height: 30),
//                   const Text("2. REVIEW ITEMS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
//                   const SizedBox(height: 10),
//                   ...widget.selectedItems.map((item) => Card(
//                     elevation: 0,
//                     color: const Color(0xffF1F5F9),
//                     margin: const EdgeInsets.only(bottom: 8),
//                     child: ListTile(
//                       title: Text(item['sweet_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                       subtitle: Text("Quantity: ${item['quantity']} ${item['unit']}"),
//                       trailing: const Icon(Icons.check_circle, color: Colors.green, size: 18),
//                     ),
//                   )).toList(),
//                 ],
//               ),
//             ),
//           ),
//
//           // Bottom Bar
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
//             child: SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: (selectedSupplier == null || isLoading) ? null : () {
//                   setState(() => isLoading = true);
//                   // API Call Logic Here
//                   Future.delayed(const Duration(seconds: 2), () {
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Sent to Supplier Successfully!")));
//                   });
//                 },
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xff1A2B4C),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
//                 ),
//                 child: isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text("CONFIRM & SEND ORDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }