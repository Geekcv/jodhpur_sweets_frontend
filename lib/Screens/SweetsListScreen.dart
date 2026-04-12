// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:js_order_website/config/config.dart';
// import '../provider/provider.dart';
//
// class SweetsListScreen extends ConsumerStatefulWidget {
//   const SweetsListScreen({super.key});
//
//   @override
//   ConsumerState<SweetsListScreen> createState() => _SweetsListScreenState();
// }
//
// class _SweetsListScreenState extends ConsumerState<SweetsListScreen> {
//   static const Color primaryDark = Color(0xff2C3E50);
//   static const Color accentGold = Color(0xffC5A059);
//   static const Color bgGrey = Color(0xffF4F7FA);
//
//   @override
//   void initState() {
//     super.initState();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(master_Provider).fetchSweets();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final masterProv = ref.watch(master_Provider);
//     final sweets = masterProv.allSweets;
//     final size = MediaQuery.of(context).size;
//
//     // Responsive columns calculation
//     int crossAxisCount = size.width > 1200 ? 4 : (size.width > 800 ? 3 : 2);
//
//     return Scaffold(
//       backgroundColor: bgGrey,
//       // appBar: AppBar(
//       //   title: const Text("Sweet Masterpieces", style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold)),
//       //   backgroundColor: Colors.white,
//       //   elevation: 0,
//       //   actions: [
//       //     IconButton(onPressed: () => setState(() {}), icon: const Icon(Icons.refresh, color: accentGold))
//       //   ],
//       // ),
//       body: masterProv.loading
//           ? const Center(child: CircularProgressIndicator(color: accentGold))
//           : sweets.isEmpty
//           ? _buildEmptyState()
//           : GridView.builder(
//         padding: const EdgeInsets.all(20),
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: crossAxisCount,
//           crossAxisSpacing: 20,
//           mainAxisSpacing: 20,
//           childAspectRatio: 0.85, // Card ki height adjust karne ke liye
//         ),
//         itemCount: sweets.length,
//         itemBuilder: (context, index) {
//           return _buildSweetCard(sweets[index]);
//         },
//       ),
//     );
//   }
//
//   Widget _buildSweetCard(var sweet) {
//     // Yahan apna Base URL daalein jahan images save hain
//     const String baseUrl = url;
//
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 1. Image Area with Price Tag
//           Stack(
//             children: [
//               ClipRRect(
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//                 child: Container(
//                   height: 160,
//                   width: double.infinity,
//                   color: bgGrey,
//                     child: sweet.image_url != null && sweet.image_url.toString().isNotEmpty
//                         ? Image.network(
//                       // Yahan ensure karo ki double slash na bane
//                       "${serverUrlMedia.endsWith('/') ? serverUrlMedia : '$serverUrlMedia/'}${sweet.image_url.toString().startsWith('/') ? sweet.image_url.toString().substring(1) : sweet.image_url}",
//                       fit: BoxFit.cover,
//                       errorBuilder: (c, e, s) {
//                         print("Image Load Error: $e"); // Debugging ke liye
//                         return const Icon(Icons.bakery_dining, size: 50, color: Colors.grey);
//                       },
//                       loadingBuilder: (context, child, loadingProgress) {
//                         if (loadingProgress == null) return child;
//                         return const Center(
//                           child: CircularProgressIndicator(strokeWidth: 2, color: accentGold),
//                         );
//                       },
//                     )
//                         : const Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey),
//                 ),
//               ),
//               Positioned(
//                 top: 12, right: 12,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   decoration: BoxDecoration(color: accentGold, borderRadius: BorderRadius.circular(10)),
//                   child: Text("₹${sweet.price}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
//                 ),
//               ),
//             ],
//           ),
//
//           // 2. Details Area
//           Padding(
//             padding: const EdgeInsets.all(15),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(sweet.category_name.toString().toUpperCase(),
//                     style: const TextStyle(color: accentGold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
//                 const SizedBox(height: 5),
//                 Text(sweet.sweet_name, maxLines: 1, overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryDark)),
//                 const SizedBox(height: 8),
//
//                 // Info Row (Shelf Life & Dept)
//                 Row(
//                   children: [
//                     const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
//                     const SizedBox(width: 4),
//                     Text("${sweet.shelf_life_days} Days", style: const TextStyle(fontSize: 11, color: Colors.grey)),
//                     const Spacer(),
//                     const Icon(Icons.business_outlined, size: 14, color: Colors.grey),
//                     const SizedBox(width: 4),
//                     Text(sweet.department_name, style: const TextStyle(fontSize: 11, color: Colors.grey)),
//                   ],
//                 ),
//
//                 const Divider(height: 25),
//
//                 // Description
//                 Text(sweet.description ?? "No description available",
//                     maxLines: 2, overflow: TextOverflow.ellipsis,
//                     style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
//           const SizedBox(height: 15),
//           const Text("No Sweets Found!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
//         ],
//       ),
//     );
//   }
// }