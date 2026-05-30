import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:js_order_website/Screens/LoginUserDetails.dart';
import 'package:js_order_website/Screens/MainDashboard.dart';
import 'package:js_order_website/services/api_services.dart';
import '../constants/static.dart';
import '../controllers/api_controller.dart';
import '../widgets/CustomTextField.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool isLoading = false;

  final TextEditingController mobilenumber = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    mobilenumber.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 900;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: isDesktop
              ? Row(children: [
            // LEFT: PURE IMAGE (No Card/Box)
            Expanded(flex: 5, child: _buildBrandingSide(size, true)),
            // RIGHT: CLEAN FORM (No Card/Box)
            Expanded(flex: 5, child: _buildLoginForm(size, true)),
          ])
              : SingleChildScrollView(
            child: Column(children: [
              _buildBrandingSide(size, false),
              _buildLoginForm(size, false),
            ]),
          ),
        ),
      ),
    );
  }

  /// LEFT SIDE: Branding and Image (Full Height)
  Widget _buildBrandingSide(Size size, bool isDesktop) {
    return Container(
      height: isDesktop ? double.infinity : size.height * 0.4,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/login_bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: isDesktop ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Text("Welcome to", style: TextStyle(fontSize: isDesktop ? 24 : 16, color: Colors.white, fontWeight: FontWeight.w300)),
            Text(
              "Jodhpur Sweets",
              style: TextStyle(fontSize: isDesktop ? 52 : 32, color: Colors.white, fontWeight: FontWeight.bold, height: 1.1),
            ),
            const SizedBox(height: 20),
            if(isDesktop)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xff1A2B4C), borderRadius: BorderRadius.circular(8)),
              child: const Text("Authentic Taste Since 1991", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  /// RIGHT SIDE: Pure White Form Area
  Widget _buildLoginForm(Size size, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 100 : 30, vertical: 60),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Login", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Color(0xff1E293B))),
          const SizedBox(height: 10),
          Text("Please enter your account details to continue.", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
          const SizedBox(height: 50),

          CustomTextField(
            controller: mobilenumber,
            label: "Mobile Number",
            hint: "Enter your phone number",
            prefixIcon: Icons.phone_android_rounded,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
          ),
          const SizedBox(height: 25),
          CustomTextField(
            controller: password,
            label: "Password",
            hint: "Enter your password",
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
          ),
          const SizedBox(height: 45),

          _buildLoginButton(),

          const SizedBox(height: 40),
          const Center(child: Text("Version 4.0.0", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1))),
        ],
      ),
    );
  }

  /// PROMINENT LOGIN BUTTON
  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff243B6B), // Halka light blue top par
              Color(0xff1A2B4C), // Aapka main dark blue bottom par
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff1A2B4C).withOpacity(0.4),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: isLoading ? null : _handleLogin,
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1))
            : const Text("LOGIN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
      ),
    );
  }

  Future<void> _handleLogin() async {
    String mobile = mobilenumber.text.trim();
    String pass = password.text.trim();

    if (mobile.isEmpty || pass.isEmpty) {
      showToast(context: context,msg: "Please enter all details",color: Colors.red);
      return;
    }
    if (mobile.length != 10) {
      showToast(context: context,msg: "Enter a valid 10-digit mobile number",color: Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      var respons = await ApiService().userLogin(mobilenumber: mobile, password: pass);
      if (respons['status'] == 0) {
        var data = respons['data'];

        await ApiController.setLoggedInAppUserToken(data['token']);
        await ApiController.setLoggedInUserRole(data['role']);
        await ApiController.setLoggedInUserId(data['user_id']);
        await ApiController.setLoggedInShopId(data['shop_id']);
        await ApiController.setLoggedInCounterId(data['counter_id']);
        await ApiController.setLoggedInSupplierId(data['supplier_id']);

        LoginUserDetails.storeUserData(respons);

        mobilenumber.clear();
        password.clear();

        if (mounted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainDashboard())
          );
        }
      }
      else {
        showToast(context: context,msg: respons['msg'], color: Colors.red);
        // Utilities.showResponse(context, respons['msg']);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}