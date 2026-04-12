import 'dart:async';
import 'package:flutter/material.dart';
import 'package:js_order_website/Screens/DashboardOverview.dart';
import 'package:js_order_website/app.dart';
import 'LoginScreen.dart';
import 'MainDashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // 1. Logo ko fade-in karne ke liye animation start karein
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // 2. 3 seconds baad automatic Login Screen par bhej dein
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        // MaterialPageRoute(builder: (context) => const LoginScreen()),
        // MaterialPageRoute(builder: (context) => const MainDashboard()),
        MaterialPageRoute(builder: (context) => const App()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF7C948),
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(seconds: 2), // 2 second ka smooth fade
          opacity: _opacity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 150,
                width: 150,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5)
                  ],
                  image: DecorationImage(
                    image: AssetImage("assets/images/images.jpeg"), // Logo path
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "JODHPUR SWEETS",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Color(0xffCA2621),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}