import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:js_order_website/Screens/AddCategoryScreen.dart';
import 'package:js_order_website/Screens/AddCounterScreen.dart';
import 'package:js_order_website/Screens/AddDepartmentScreen.dart';
import 'package:js_order_website/Screens/AddInventoryScreen.dart';
import 'package:js_order_website/Screens/AddShopScreen.dart';
import 'package:js_order_website/Screens/AddSupplierScreen.dart';
import 'package:js_order_website/Screens/ExpireItemsScreen.dart';
import 'package:js_order_website/Screens/LoginUserDetails.dart';
import 'package:js_order_website/Screens/OrderRequestListScreen.dart';
import 'package:js_order_website/controllers/api_controller.dart';
import '../provider/provider.dart';
import 'ChalanListScreen.dart';
import 'CounterOrderRequestScreen.dart';
import 'DashboardOverview.dart';
import 'AddProductScreen.dart';
import 'FinalizeOrderScreen.dart';
import 'NotificationScreen.dart';
import 'ProfileScreen.dart';
import 'ShopAdminOrderRequestsScreen.dart';
import 'StockHistoryScreen.dart';
import 'SupplierOrdersScreen.dart';
import 'TrackOwnOrdersShopAdminScreen.dart';

class MainDashboard extends ConsumerStatefulWidget {
  const MainDashboard({super.key});

  @override
  ConsumerState<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends ConsumerState<MainDashboard> with TickerProviderStateMixin {

  late AnimationController _rotationController;
  int _selectedIndex = 0;
  bool _isSidebarVisible = true; // Sidebar toggle ke liye
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  final List<String> _titles = [
    "Dashboard",        // 0
    "Create Order",     // 1
    "Inventory",        // 2
    "Profile",          // 3
    "Add Sweet",        // 4
    "Add Shop",         // 5
    "Add Counter",      // 6
    "Add Dept",         // 7
    "Add Category",     // 8
    "Add Supplier",     // 9
    "Counter Requests",   // 10
    "Order Received",     // 11
    "Finalize Order",   // 12
    "Stock History",    // 13
    "Order Request",    // 14
    "Dispatch Chalans", // 15
    "My Orders", // 16
    "Expiry Items", // 17
    "Notifications",    // 18 <--- YE ADD KARNA HAI
  ];


  static const Color sideBarColor = Color(0xff1A2B4C);
  static const Color accentColor = Color(0xffD4AF37);

  @override
  void initState() {
    super.initState();
    // print("Login:-------------${LoginUserDetails.role}");
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(master_Provider).fetchNotification();
    });

  }



  // Function to change index from child (DashboardOverview)
  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width >= 1100;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xffF8FAFC),
      // Mobile ke liye drawer, Desktop par toggleable sidebar
      drawer: !isDesktop ? _buildSidebar(isDrawer: true) : null,
      body: Row(
        children: [
          if (isDesktop && _isSidebarVisible) _buildSidebar(isDrawer: false),
          Expanded(
            child: Column(
              children: [
                _buildProfessionalAppBar(!isDesktop || !_isSidebarVisible),
                Expanded(
                  child: Container(
                    // padding: const EdgeInsets.all(20),
                    child: _getScreen(_selectedIndex),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _getScreen(int index) {
    switch (index) {
      case 0: return DashboardOverview(onMenuSelect: changeTab);
      case 1: return const CounterOrderRequestScreen(); // Counter User wali
      case 2: return const AddInventoryScreen();
      case 3: return const ProfileScreen();

    // Master Console (Admin)
      case 4: return const AddProductScreen();
      case 5: return const AddShopScreen();
      case 6: return const AddCounterScreen();
      case 7: return const AddDepartmentScreen();
      case 8: return const AddCategoryScreen();
      case 9: return const AddSupplierScreen();

    // NEW SCREENS FOR ROLES
      case 10: return const ShopAdminOrderRequestsScreen(); // fe_or_details (Shop Admin)
      case 11: return const SupplierOrdersScreen();     // fe_my_ord (Supplier)
      // case 12: return const FinalizeOrderScreen(selectedItems: []); // cr_final_order
      case 13: return const StockHistoryScreen();       // fet_stock_his

      case 14: return const OrderRequestListScreen();       // fet_stock_his

      case 15: return const ChalanListScreen();

      case 16: return const TrackOwnOrdersShopAdminScreen();

      case 17: return const ExpireItemsScreen();

      case 18: return const NotificationScreen(); // Nayi Notification Screen

      default: return DashboardOverview(onMenuSelect: changeTab);
    }
  }



  Widget _buildSidebar({required bool isDrawer}) {
    return Container(
      width: 250,
      // margin: EdgeInsets.all(isDrawer ? 0 : 15),
      decoration: BoxDecoration(
        color: sideBarColor,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
      ),
      child: Column(
        children: [
          _buildLogoHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _sidebarItem(0, Icons.dashboard_rounded, "Dashboard"),

                // Agar Counter User hai toh hi Order Create dikhe
                if (LoginUserDetails.role == 'COUNTER_USER')
                  _sidebarItem(1, Icons.add_box_outlined, "Create Order"),

                if (LoginUserDetails.role == 'COUNTER_USER')
                  _sidebarItem(14, Icons.receipt_long_rounded, "Track Requests"),

                // Shop Admin ke liye Pending Requests
                if (LoginUserDetails.role == 'SHOP_ADMIN')
                  _sidebarItem(10, Icons.pending_actions_rounded, "Counter Requests"),


                if (LoginUserDetails.role == 'SHOP_ADMIN')
                  _sidebarItem(16, Icons.pending_actions_rounded, "Track Orders"),

                if (LoginUserDetails.role == 'SHOP_ADMIN' || LoginUserDetails.role == 'COUNTER_USER')
                  _sidebarItem(17, Icons.event_busy, "Expiry items"),



                if (LoginUserDetails.role != 'SUPPLIER')
                  _sidebarItem(13, Icons.analytics_outlined, "Stock History"),

                // Supplier ke liye uske orders
                if (LoginUserDetails.role == 'SUPPLIER')
                  _sidebarItem(11, Icons.receipt_long_rounded, "Order Received"),

                if (LoginUserDetails.role == 'SHOP_ADMIN' || LoginUserDetails.role == 'COUNTER_USER')
                _sidebarItem(2, Icons.inventory_2_rounded, "Inventory"),

                // Sidebar ki list mein ye add karo (Scrollable area ke andar)
                if (LoginUserDetails.role != 'COUNTER_USER')
                  _sidebarItem(15, Icons.local_shipping_rounded, "View Chalans"),

                _sidebarItem(3, Icons.person_rounded, "My Profile"),
              ],
            ),
          ),
          // Expanded(
          //   child: ListView(
          //     padding: const EdgeInsets.symmetric(horizontal: 10),
          //     children: [
          //       _sidebarItem(0, Icons.dashboard_customize_rounded, "Dashboard"),
          //       _sidebarItem(1, Icons.add_box_rounded, "Add Sweet"),
          //       _sidebarItem(8, Icons.layers_rounded, "Sweet Master"),
          //       _sidebarItem(2, Icons.store_mall_directory_rounded, "Add Shop"),
          //       _sidebarItem(3, Icons.point_of_sale_rounded, "Counter"),
          //       _sidebarItem(4, Icons.account_tree_rounded, "Department"),
          //       _sidebarItem(5, Icons.category_rounded, "Category"),
          //       _sidebarItem(6, Icons.local_shipping_rounded, "Suppliers"),
          //       _sidebarItem(7, Icons.manage_accounts_rounded, "Profile"),
          //       _sidebarItem(9, Icons.manage_accounts_rounded, "Inventory"),
          //       _sidebarItem(10, Icons.manage_accounts_rounded, "Create Order"),
          //     ],
          //   ),
          // ),
          // PREMIUM LOGOUT BUTTON
          _buildLogoutButton(),
          // const SizedBox(height: 20),
        ],
      ),
    );
  }





  Widget _buildLogoHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          // Orbit Effect using RotationTransition on a single Container
          RotationTransition(
            turns: _rotationController,
            child: Container(
              padding: const EdgeInsets.all(6), // Border ki thickness yahan se control hogi
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    accentColor.withOpacity(0.1), // Faint Gold
                    accentColor,                 // Sharp Gold
                    accentColor.withOpacity(0.1), // Faint Gold
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: RotationTransition(
                turns: ReverseAnimation(_rotationController), // Image ko seedha rakhne ke liye reverse rotation
                child: Container(
                  height: 85,
                  width: 85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 2), // Inner white ring
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      "assets/images/images.jpeg",
                      fit: BoxFit.cover, // Poora fill karne ke liye cover best hai
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Brand Identity
          const Text(
            "JODHPUR",
            style: TextStyle(
              color: Colors.white60,
              fontSize: 10,
              letterSpacing: 5,
              fontWeight: FontWeight.w300,
            ),
          ),

          // Shimmering Text Logic
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: const [accentColor, Colors.white, accentColor],
                  stops: [
                    (_rotationController.value - 0.3).clamp(0.0, 1.0),
                    _rotationController.value,
                    (_rotationController.value + 0.2).clamp(0.0, 1.0),
                  ],
                ).createShader(bounds),
                child: const Text(
                  "SWEETS",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    letterSpacing: 2,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          // Minimalist Gold Line
          Container(
            height: 2,
            width: 55,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }


  Widget _sidebarItem(int index, IconData icon, String title) {
    bool isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: InkWell(
        onTap: () {
          setState(() => _selectedIndex = index);
          if (_scaffoldKey.currentState!.isDrawerOpen) Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            // Selected state: Elegant Gold Gradient with Soft Edge
            gradient: isSelected ? LinearGradient(
              colors: [
                accentColor.withOpacity(0.09),
                accentColor.withOpacity(0.02),
              ],
            ) : null,
            borderRadius: BorderRadius.circular(6),
            border: isSelected ? Border(left: BorderSide(color: accentColor, width: 2)) : const Border(left: BorderSide(color: Colors.transparent, width: 4)),
          ),
          child: Row(
            children: [
              Icon(icon,color: isSelected ? accentColor : Colors.white30, size: 16),
              const SizedBox(width: 15),
              Text(title,
                style: TextStyle(color: isSelected ? Colors.white : Colors.white60,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400, fontSize: 14, letterSpacing: 0.5),
              ),
              const Spacer(),
              if (isSelected)
              Icon(Icons.check_circle, color: accentColor.withOpacity(0.7), size: 14),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () async{
          await ApiController.logOut(context);
          setState(() {});
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            children: [
              // Icon with Glow
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.power_settings_new_rounded, // Modern Logout Icon
                  color: Colors.redAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Sign Out",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.2),
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildProfessionalAppBar(bool showMenuButton) {
    // Date format for a premium feel
    String formattedDate = DateFormat('EEEE, dd MMM').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // 1. Sidebar Toggle Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                if (showMenuButton && MediaQuery.of(context).size.width < 1100) {
                  _scaffoldKey.currentState!.openDrawer();
                } else {
                  setState(() => _isSidebarVisible = !_isSidebarVisible);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                // decoration: BoxDecoration(
                //   color: sideBarColor.withOpacity(0.05),
                //   borderRadius: BorderRadius.circular(10),
                // ),
                child: Icon(
                  !showMenuButton ? Icons.menu_open_rounded : Icons.menu_rounded,
                  color: sideBarColor,
                  size: 22,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // 2. Title & Dynamic Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  _titles[_selectedIndex] ?? "Overview",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff1E293B),
                      // letterSpacing: -0.5
                  )
              ),
              Text(
                formattedDate,
                style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w500),
              ),
            ],
          ),

          const Spacer(),

          Consumer(
            builder: (context, ref, child) {
              final masterProv = ref.watch(master_Provider);

              // Yahan fix hai: Pehle check karo null toh nahi, fir string ko int mein badlo
              var rawUnread = masterProv.allNotifications?.unread;
              int unreadCount = 0;

              if (rawUnread != null) {
                unreadCount = int.tryParse(rawUnread.toString()) ?? 0;
              }

              return Stack(
                alignment: Alignment.center,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() => _selectedIndex = 18);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: unreadCount > 0
                              ? Colors.blue.withOpacity(0.05)
                              : Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          unreadCount > 0
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_none_rounded,
                          color: unreadCount > 0 ? Colors.blue : Colors.blueGrey,
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  // Badge tabhi dikhao jab count sach mein 0 se bada ho
                  if (unreadCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          unreadCount > 9 ? "9+" : "$unreadCount",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          SizedBox(width: 18),

          // 4. Premium Profile Section
          InkWell(
            onTap:() {
              setState(() {
                _selectedIndex=3;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                // Deep Navy (Sidebar match) ke liye subtle glass effect
                color: accentColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accentColor.withOpacity(0.2), // Light indigo border
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pulsing Active Dot (Premium Signal)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: accentColor, // Pulsing dot color
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // The Role Text
                  Text(
                    "${LoginUserDetails.role?.replaceAll('_', ' ')}",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: accentColor, // Chamakta hua Indigo/Cyan
                      letterSpacing: 1.2, // Pro spacing
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Minimal Avatar (First Letter only)
                  Container(
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [accentColor, accentColor.withOpacity(0.7)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        LoginUserDetails.role?[0].toUpperCase() ?? "U",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}