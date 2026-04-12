import 'package:flutter/material.dart';
import 'package:js_order_website/controllers/api_controller.dart';
import '../constants/static.dart';
import '../models/DashboardModel.dart';

class DashboardOverview extends StatefulWidget {
  final Function(int) onMenuSelect;
  const DashboardOverview({super.key, required this.onMenuSelect});

  @override
  State<DashboardOverview> createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<DashboardOverview> {
  static const Color sideBarColor = Color(0xff1A2B4C);
  static const Color accentColor = Color(0xffD4AF37);

  bool _isExpanded = false;
  bool _isLoading = true;
  DashboardModel? dashboardData;
  var role;

  @override
  void initState() {
    super.initState();
    _initDashboard();
  }



  _initDashboard() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    await getLoginUserRole();
    await fetchDashboardData();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  getLoginUserRole() async {
    role = await ApiController.getloggedInUserRole();
    if (mounted) setState(() {});
  }

  fetchDashboardData() async {
    var res = await ApiController.fetchDashboard();
    if (res != null && mounted) {
      setState(() => dashboardData = res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 800;

        return Scaffold(
          backgroundColor: const Color(0xffF4F7FA),
          body: _isLoading
              ? buildShimmerEffect(context: context)
              : Stack( // <--- Stack is the top-level container
            children: [
              // LAYER 1: MAIN SCROLLABLE CONTENT (Background Layer)
              Column(
                children: [
                  // Fixed Top Section (Header + Stats)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(25, 25, 25, isMobile ? 15 : 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderInfo(),
                        const SizedBox(height: 25),
                        _buildStatsGrid(isMobile),
                      ],
                    ),
                  ),

                  // Scrollable Bottom Section (List)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                      child: _buildOrderListSection(),
                    ),
                  ),
                ],
              ),

              // LAYER 2: MASTER CONSOLE (Floating Layer - Top Most)
              // Only visible for ADMIN and on Desktop. Mobile handled differently if needed.
              if (role == 'ADMIN' || role == 'SHOP_ADMIN' && !isMobile)
                Positioned(
                  top: 25,
                  right: 25,
                  child: _buildFloatingDropdown(210),
                ),
            ],
          ),
        );
      },
    );
  }

  // --- IDENTITY HEADER ---
  Widget _buildHeaderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("JODHPUR SWEETS",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: sideBarColor, letterSpacing: 1)),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1), // Light green tint
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.withOpacity(0.2), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    role?.toString().replaceAll('_', ' ').toUpperCase() ?? 'SYSTEM',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- SLEEK STATS GRID ---
  Widget _buildStatsGrid(bool isMobile) {
    var cards = dashboardData?.cards;
    if (cards == null) return const SizedBox();

    List<Widget> stats = [];
    if (role == 'ADMIN') {
      stats = [
        _miniCard("TOTAL SHOPS", "${cards.totalShops ?? 0}", Icons.storefront, Colors.blue),
        _miniCard("TOTAL USERS", "${cards.totalUsers ?? 0}", Icons.badge_outlined, Colors.purple),
        _miniCard("SUPPLIERS", "${cards.totalSuppliers ?? 0}", Icons.local_shipping, Colors.indigo),
        _miniCard("LOW STOCK", "${cards.lowStockItems ?? 0}", Icons.analytics, Colors.orange),
      ];
    } else if (role == 'SHOP_ADMIN') {
      stats = [
        _miniCard("COUNTERS", "${cards.totalCounters ?? 0}", Icons.point_of_sale, Colors.teal),
        _miniCard("STOCK", "${cards.totalStock ?? 0}", Icons.inventory, Colors.blue),
        _miniCard("PENDING", "${cards.pendingRequests ?? 0}", Icons.pending_actions, Colors.orange),
        _miniCard("CRITICAL", "${cards.lowStockItems ?? 0}", Icons.report_problem, Colors.red),
      ];
    } else if (role == 'COUNTER_USER') {
      stats = [
        _miniCard("MY STOCK", "${cards.availableStock ?? 0}", Icons.storage, Colors.blue),
        _miniCard("MY REQUESTS", "${cards.myRequests ?? 0}", Icons.history, Colors.teal),
        _miniCard("PENDING", "${cards.pendingRequests ?? 0}", Icons.timer, Colors.orange),
        _miniCard("LOW STOCK", "${cards.lowStockItems ?? 0}", Icons.warning_amber, Colors.red),
      ];
    } else {
      stats = [
        _miniCard("TOTAL ORDERS", "${cards.totalOrders ?? 0}", Icons.inventory_2_rounded, Colors.blue), // Neutral & Professional
        _miniCard("PENDING ORDERS", "${cards.pendingOrders ?? 0}", Icons.pending_actions_rounded, Colors.orange), // Waiting State
        _miniCard("ACCEPTED", "${cards.acceptedOrders ?? 0}", Icons.assignment_turned_in_rounded, Colors.indigo), // Process Started
        _miniCard("DISPATCHED", "${cards.dispatchedOrders ?? 0}", Icons.local_shipping_rounded, Colors.green), // Final Success State
      ];
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 4,
      crossAxisSpacing: 15,
      mainAxisSpacing: 10,
      childAspectRatio: isMobile ? 1.8 : 2.9,
      children: stats,
    );
  }

  // Individual Card with Tap functionality
  Widget _miniCard(String title, String value, IconData icon, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => print("Clicked on $title"),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: sideBarColor),
                        overflow: TextOverflow.ellipsis),
                    Text(title,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- DYNAMIC LIST SECTION ---
  Widget _buildOrderListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("LIVE ACTIVITY LOG",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey)),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 15,
          itemBuilder: (context, index) => _orderTile(index),
        ),
      ],
    );
  }

  Widget _orderTile(int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => print("Order $index selected"),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 8, color: accentColor),
              const SizedBox(width: 15),
              const Expanded(
                child: Text("Batch Update: Fresh Sweets Dispatch #402",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: sideBarColor)),
              ),
              Text("${index + 1}m ago", style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right, size: 16, color: Colors.black12),
            ],
          ),
        ),
      ),
    );
  }

  // --- MASTER CONSOLE (NO CHANGES TO YOUR ORIGINAL DESIGN) ---
  Widget _buildFloatingDropdown(double width) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width,
      decoration: BoxDecoration(
        color: sideBarColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: accentColor, size: 16),
                  const SizedBox(width: 10),
                  const Text("Master Console",style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              alignment: Alignment.topCenter,
              heightFactor: _isExpanded ? 1.0 : 0.0,
              curve: Curves.easeInOut,
              child: Container(
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white10))),
                child: Column(
                  children: [
                    // Sirf ADMIN ko dikhega
                    if (role == 'ADMIN')
                      _dropdownSubItem("Add Shop", Icons.store_outlined, 5),


                    if (role == 'ADMIN' || role == 'SHOP_ADMIN')
                      _dropdownSubItem("Add Department", Icons.account_tree_outlined, 7),

                    if (role == 'ADMIN' || role == 'SHOP_ADMIN')
                      _dropdownSubItem("Add Category", Icons.category_outlined, 8),


                    // ADMIN aur SHOP_ADMIN dono ko dikhega
                    if (role == 'ADMIN' || role == 'SHOP_ADMIN')
                      _dropdownSubItem("Add Counter", Icons.badge_outlined, 6),


                    if (role == 'ADMIN' || role == 'SHOP_ADMIN')
                      _dropdownSubItem("Add Sweet", Icons.add_circle_outline, 4),


                    // Sirf ADMIN ko dikhega (Supplier management shop admin ka kaam nahi hai)
                    if (role == 'ADMIN')
                      _dropdownSubItem("Add Supplier", Icons.local_shipping_outlined, 9),

                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownSubItem(String title, IconData icon, int index) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: Icon(icon, color: accentColor, size: 16),
      title: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      onTap: () {
        setState(() => _isExpanded = false);
        widget.onMenuSelect(index);
      },
    );
  }
}