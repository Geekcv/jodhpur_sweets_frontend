// import 'package:flutter/material.dart';
//
// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});
//
//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }
//
// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: const Color(0xffF7C948), // Wahi Yellow Theme
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Stack(
//         children: [
//           /// 1. Background Header (Matching Login Screen)
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             height: size.height * 0.49,
//             child: Container(
//               decoration: const BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage("assets/images/login_bg.png"),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               child: Container(
//                 color: Colors.black.withOpacity(0.3), // Dark overlay for text clarity
//               ),
//             ),
//           ),
//
//           /// 2. Screen Title
//           Positioned(
//             top: size.height * 0.15,
//             left: 30,
//             right: 30,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 Text(
//                   "Forgot\nPassword?",
//                   style: TextStyle(
//                     fontSize: 38,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     height: 1.2,
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   "Don't worry! It happens. Please enter the mobile number associated with your account.",
//                   style: TextStyle(color: Colors.white70, fontSize: 16),
//                 ),
//               ],
//             ),
//           ),
//
//           /// 3. Reset Card
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               height: size.height * 0.55,
//               width: double.infinity,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
//                 boxShadow: [
//                   BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5)
//                 ],
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
//               child: Column(
//                 children: [
//                   /// Lottie animation ya Icon ke liye space
//                   Container(
//                     height: 80,
//                     width: 80,
//                     decoration: BoxDecoration(
//                       color: const Color(0xffCA2621).withOpacity(0.1),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(Icons.lock_reset_rounded, size: 50, color: Color(0xffCA2621)),
//                   ),
//
//                   const SizedBox(height: 40),
//
//                   /// Mobile Input
//                   _buildInputField(
//                     label: "Mobile Number",
//                     hint: "Enter registered number",
//                     icon: Icons.phone_android_outlined,
//                   ),
//
//                   const SizedBox(height: 40),
//
//                   /// Gradient Reset Button
//                   Container(
//                     width: double.infinity,
//                     height: 55,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(15),
//                       gradient: const LinearGradient(
//                         colors: [Color(0xffE12E29), Color(0xffCA2621)],
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xffCA2621).withOpacity(0.3),
//                           blurRadius: 5,
//                           offset: const Offset(0, 3),
//                         )
//                       ],
//                     ),
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.transparent,
//                         shadowColor: Colors.transparent,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                       ),
//                       onPressed: () {
//                         // OTP logic yahan aayegi
//                       },
//                       child: const Text(
//                         "SEND OTP",
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
//                       ),
//                     ),
//                   ),
//
//                   const Spacer(),
//
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text("Remember password?", style: TextStyle(color: Colors.grey.shade600)),
//                       TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: const Text("Login", style: TextStyle(color: Color(0xffCA2621), fontWeight: FontWeight.bold)),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInputField({required String label, required String hint, required IconData icon}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
//         const SizedBox(height: 10),
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.grey.shade50,
//             borderRadius: BorderRadius.circular(15),
//             border: Border.all(color: Colors.grey.shade200),
//           ),
//           child: TextField(
//             keyboardType: TextInputType.phone,
//             decoration: InputDecoration(
//               hintText: hint,
//               hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
//               prefixIcon: Icon(icon, color: const Color(0xffCA2621)),
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.symmetric(vertical: 15),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }