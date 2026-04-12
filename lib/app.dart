import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:js_order_website/Screens/LoginScreen.dart';
import 'package:js_order_website/Screens/MainDashboard.dart';
import 'package:js_order_website/Screens/SplashScreen.dart';
import 'package:js_order_website/controllers/api_controller.dart';
import '../provider/provider.dart';
import 'Screens/LoginUserDetails.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getloggedInUser();
    });
  }

  bool? isLoggedIn;
  String? role;

  getloggedInUser() async {
    var token = await ApiController.getloggedinUserToken();
    var role = await ApiController.getloggedInUserRole();
    var uId = await ApiController.getloggedInUserId(); // Add this in ApiController
    var cId = await ApiController.getloggedInCounterId();
    var sId = await ApiController.getloggedInShopId(); // Add this in ApiController
    var supId = await ApiController.getloggedInSupplierId(); // Add this in ApiController

    if (token != null && token.isNotEmpty) {
      LoginUserDetails.loadDataFromStorage(
        t: token,
        r: role ?? "",
        uId: uId,
        cId: cId,
        sId: sId,
        supId: supId,
      );

      setState(() => isLoggedIn = true);
    } else {
      setState(() => isLoggedIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(isLoggedIn == null){
      return Scaffold(
        backgroundColor: Colors.white,
      );
    }
    // return isLoggedIn! && role==null ? LoginScreen() : isLoggedIn! && role=="super-admin" ? Superadminhomepage() : UserLogin();
    return isLoggedIn == false ? LoginScreen() : MainDashboard();
  }
}
