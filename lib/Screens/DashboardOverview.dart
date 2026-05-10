import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:js_order_website/controllers/api_controller.dart';
import 'package:js_order_website/utilities/sizeconfig.dart';
import '../constants/static.dart';
import '../models/DashboardAccordingToRoleModel.dart';
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
  dynamic dashboardData;

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
    try {
      // Role ke hisaab se humein result milega (jo ki hamara model hoga)
      var res = await ApiController.fetchDashboardAccordingToRole(role: role,context: context);

      if (res != null && mounted) {
        setState(() {
          // Yahan verify karein ki kya result hamare kisi defined model ka instance hai
          if (res is AdminDashboardModel || res is ShopDashboardModel || res is CounterDashboardModel || res is SupplierDashboardModel) {

            dashboardData = res;
            print("Dashboard data assigned for role: $role");
          } else {
            // Agar koi raw data wapas aaya (fallback)
            dashboardData = res;
          }
        });
      }
    } catch (e) {
      print("Error fetching dashboard data: $e");
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
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
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
                          if (role == 'ADMIN')
                          buildDashboardUI(isMobile),
                          if (role == 'SHOP_ADMIN')
                          buildShopDashboardResponsive(dashboardData),
                          if (role == 'COUNTER_USER')
                          buildCounterDashboardResponsive(dashboardData),
                          if (role == 'SUPPLIER')
                          buildSupplierDashboardResponsive(dashboardData)
                        ],
                      ),
                    ),
                
                    // Scrollable Bottom Section (List)
                    // Expanded(
                    //   child: SingleChildScrollView(
                    //     physics: const BouncingScrollPhysics(),
                    //     padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                    //     child: _buildOrderListSection(),
                    //   ),
                    // ),
                  ],
                ),
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









//////////////////////// when admin login //////////////////////////////////////
  Widget buildDashboardUI(bool isMobile) {
    if (dashboardData == null) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Stats Grid
          _buildAdminStatsGrid(isMobile),

          const SizedBox(height: 24),

          _buildChartAndRecentOrders(),
        ],
      ),
    );
  }

  Widget _buildAdminStatsGrid(bool isMobile) {
    final summary = dashboardData?.summary.isNotEmpty == true ? dashboardData!.summary.first : null;
    if (summary == null) return const SizedBox();

    // Har stat ke liye custom theme colors (gradient ke liye)
    List<Map<String, dynamic>> adminStats = [
      {
        "title": "TOTAL SHOPS", "val": summary.totalShops,
        "color": const Color(0xff3B82F6), "bg": const Color(0xffEFF6FF), "icon": Icons.storefront
      },
      {
        "title": "ACTIVE USERS", "val": summary.totalUsers,
        "color": const Color(0xff10B981), "bg": const Color(0xffECFDF5), "icon": Icons.people_alt
      },
      {
        "title": "SUPPLIERS", "val": summary.totalSuppliers,
        "color": const Color(0xff6366F1), "bg": const Color(0xffEEF2FF), "icon": Icons.local_shipping
      },
      {
        "title": "TOTAL ORDERS", "val": summary.totalOrders,
        "color": const Color(0xffF59E0B), "bg": const Color(0xffFFFBEB), "icon": Icons.shopping_bag
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: adminStats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 2.3 : 3.2,
      ),
      itemBuilder: (context, index) {
        final stat = adminStats[index];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: stat['color'].withOpacity(0.2), width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04), // Opacity kam ki
                blurRadius: 6, // Blur kam kiya
                offset: const Offset(0, 2), // Offset upar shift kiya
              )
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Icon ke liye premium circular background
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      // Gradient background for depth
                      gradient: LinearGradient(
                        colors: [
                          stat['bg'], // Light tint
                          stat['bg'].withOpacity(0.5), // More subtle fade
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      // Extra thin border for crisp edges
                      border: Border.all(
                        color: stat['color'].withOpacity(0.15),
                        width: 1.0,
                      ),
                      // Soft inner glow look
                      boxShadow: [
                        BoxShadow(
                          color: stat['color'].withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      stat['icon'],
                      size: 20, // Size thoda increase kiya, icon zyada clear dikhega
                      color: stat['color'],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat['title'],
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: stat['color'].withOpacity(0.8), letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${stat['val']}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xff1E293B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildChartAndRecentOrders() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2, // Chart ko thoda zyada space
          child: Container(
            height: SizeConfig.blockSizeVertical!*52,
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ORDERS TREND", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey)),
                const SizedBox(height: 16),
                Expanded(child: _buildOrderTrendChart()),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            height: SizeConfig.blockSizeVertical! * 52,
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Total Items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("RECENT ORDERS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                      child: Text("Total: ${dashboardData?.recentOrders.length ?? 0}", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 0.5, color: Colors.black12),
                const SizedBox(height: 8),

                // List Area
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: dashboardData?.recentOrders.length ?? 0,
                    separatorBuilder: (_, __) => const Divider(height: 16, thickness: 0.5, color: Colors.black12),
                    itemBuilder: (context, index) {
                      final order = dashboardData!.recentOrders[index];
                      final String serialNo = (index + 1).toString();

                      return Row(
                        children: [
                          // Serial Number Box
                          // Serial Number Box (Premium Look)
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white, // Background clean white
                              borderRadius: BorderRadius.circular(8), // Thoda aur round
                              border: Border.all(
                                color: Colors.blueAccent.withOpacity(0.2), // Light blue border
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              "${serialNo}",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.blueAccent, // Blue text for better contrast
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Order Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Item/Sweet Name (Prominent)
                                Text(
                                  "${order.sweets ?? 'No Items'}",
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xff1E293B)
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                // Shop Name & Counter (Subtext)
                                Text(
                                  "Shop: ${order.shop_name ?? 'N/A'} | Counter: ${order.counter_name ?? 'N/A'}",
                                  style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Status Badge
                          _buildStatusBadge(order.status.toString()),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

// Isse apni class mein kahi bhi rakhein
  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;

    // Status ke hisaab se colors set karein
    switch (status.toUpperCase()) {
      case 'DISPATCHED':
        color = const Color(0xff059669); // Green
        bgColor = const Color(0xff10B981);
        break;
      case 'ACCEPTED':
        color = const Color(0xff2563EB); // Blue
        bgColor = const Color(0xff3B82F6);
        break;
      case 'PENDING':
        color = const Color(0xffD97706); // Amber/Orange
        bgColor = const Color(0xffF59E0B);
        break;
      case 'REJECTED':
        color = const Color(0xffDC2626); // Red
        bgColor = const Color(0xffEF4444);
        break;
      default:
        color = const Color(0xff64748B); // Grey
        bgColor = const Color(0xff94A3B8);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }

  Widget _buildOrderTrendChart() {
    final trendData = dashboardData?.orderTrend ?? [];
    if (trendData.isEmpty) {
      return const Center(child: Text("No Data", style: TextStyle(fontSize: 10, color: Colors.grey)));
    }

    // maxY ko calculate karte waqt 1 add karein taaki chart thoda upar se khali rahe (clean look)
    final double maxYValue = trendData.map((e) => double.tryParse(e.count.toString()) ?? 0.0)
        .fold(0.0, (a, b) => a > b ? a : b) + 1.0;

    final List<BarChartGroupData> barGroups = trendData.asMap().entries.map<BarChartGroupData>((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: double.tryParse(e.value.count.toString()) ?? 0,
            color: const Color(0xff6366F1),
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxYValue,
              color: Colors.grey.shade100, // Background bar color
            ),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        maxY: maxYValue,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xff1E293B),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              // Full Date Formatting
              final date = DateTime.tryParse(trendData[groupIndex].date.toString());
              // Pure Date: DD-MM-YYYY format
              final dateStr = date != null
                  ? "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}"
                  : "N/A";

              return BarTooltipItem(
                "$dateStr\n",
                const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                      text: "Orders: ${rod.toY.toInt()}",
                      style: const TextStyle(color: Colors.white70, fontSize: 10)
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < trendData.length) {
                    final date = DateTime.tryParse(trendData[value.toInt()].date.toString());

                    // DD-MM-YYYY format
                    final formattedDate = date != null
                        ? "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}"
                        : "";

                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                          formattedDate,
                          style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w600)
                      ),
                    );
                  }
                  return const SizedBox();
                },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1, // Integer constraint
              reservedSize: 30,
              getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: Colors.grey)
              ),
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade200),
  );
















  /////////////////////////////////when shop admin lgoin ////////////////////////////////////////////////////////


  Widget buildShopDashboardResponsive(ShopDashboardModel dashboardData) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 800; // Tablet/Web dono ke liye 800 threshold

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Stats Grid
            _buildShopStatsGrid(dashboardData, constraints.maxWidth < 600),
            const SizedBox(height: 24),

            // 2. Chart + Out of Stock (Top Row)
            isMobile
                ? _buildDashboardColumn(dashboardData)
                : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chart (Wide area)
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 350,
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("ORDERS TREND", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 16),
                        Expanded(child: _buildOrderTrendChartDynamic(dashboardData.orderTrend)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Out of Stock (Side me)
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 350,
                    child: _buildInventoryList("OUT OF STOCK", dashboardData.outOfStock),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            // 3. Low Stock + Expiry Alerts (Bottom Row)
            if (!isMobile)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildInventoryList("LOW STOCK", dashboardData.lowStock)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInventoryList("EXPIRY ALERTS", dashboardData.expiryAlerts)),
                ],
              ),

            const SizedBox(height: 40),
          ],
        );
      },
    );
  }

// Mobile ke liye vertical list
  Widget _buildDashboardColumn(ShopDashboardModel data) {
    return Column(
      children: [
        const Text("ORDERS TREND", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 10),
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: _buildOrderTrendChartDynamic(data.orderTrend),
        ),
        const SizedBox(height: 16),
        _buildInventoryList("OUT OF STOCK", data.outOfStock),
        const SizedBox(height: 16),
        _buildInventoryList("LOW STOCK", data.lowStock),
        const SizedBox(height: 16),
        _buildInventoryList("EXPIRY ALERTS", data.expiryAlerts),
      ],
    );
  }

  // Stats Grid for Shop
  Widget _buildShopStatsGrid(ShopDashboardModel data, bool isMobile) {
    final summary = data.summary.isNotEmpty ? data.summary.first : Summary();

    final List<Map<String, dynamic>> shopStats = [
      {"title": "ORDERS", "val": summary.totalOrders, "color": Colors.blue, "bg": const Color(0xffEFF6FF), "icon": Icons.shopping_basket},
      {"title": "PENDING", "val": summary.pending, "color": Colors.orange, "bg": const Color(0xffFFFBEB), "icon": Icons.hourglass_empty},
      {"title": "APPROVED", "val": summary.approved, "color": Colors.green, "bg": const Color(0xffECFDF5), "icon": Icons.check_circle},
      {"title": "REJECTED", "val": summary.rejected, "color": Colors.red, "bg": const Color(0xffFEF2F2), "icon": Icons.cancel},
    ];

    return buildGenericStatsGrid(items: shopStats, isMobile: isMobile);
  }

  // Inventory List Widget
  Widget _buildInventoryList(String title, List<InventoryItem> items) {
    return Container(
      height: SizeConfig.blockSizeVertical! * 52, // Same height as Orders
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  // Premium Gradient
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade100, Colors.grey.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Chota sa status indicator (dot)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Total: ${items.length}",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.blueGrey.shade800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 8, thickness: 0.5, color: Colors.black12),

          // List Area
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 16, thickness: 0.5, color: Colors.black12),
              itemBuilder: (context, index) {
                final item = items[index];

                // Date Parsing
                final expiry = DateTime.tryParse(item.expiryDate.toString());
                final formattedExpiry = expiry != null
                    ? "${expiry.day.toString().padLeft(2, '0')}-${expiry.month.toString().padLeft(2, '0')}-${expiry.year}"
                    : "N/A";

                return Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xffEFF6FF), // Soft blue tint
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "${index + 1}", // 01, 02 format (looks professional)
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xff3B82F6), // Accent blue
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.sweetName ?? "Unknown Item", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xff1E293B))),
                          const SizedBox(height: 2),
                          Text("Expire: $formattedExpiry | Quantity: ${item.quantity}", style: const TextStyle(fontSize: 9, color: Colors.grey)),
                        ],
                      ),
                    ),
                    // Min/Max indicator (Optional: sirf visual ke liye)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          const Text(
                              "MIN/MAX:",
                              style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)
                          ),
                          const SizedBox(width: 4),
                          Text(
                              "${item.minStock}/${item.maxStock}",
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xff334155))
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildOrderTrendChartDynamic(List<ChartData> trendData) {
    if (trendData.isEmpty) return const Center(child: Text("No Data Available"));

    final double maxCount = trendData.map((e) => double.tryParse(e.count.toString()) ?? 0.0)
        .fold(0.0, (a, b) => a > b ? a : b);
    final double maxYValue = (maxCount + 1).ceilToDouble();

    return BarChart(
      BarChartData(
        // gridData: const FlGridData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xffEAF4FF), // very light blue
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1), // Light Grey Bottom Border
            left: BorderSide(color: Color(0xFFF1F5F9), width: 1),   // Light Grey Left Border
            top: BorderSide.none,
            right: BorderSide.none,
          ),
        ),
        maxY: maxYValue,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xff1E293B),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = DateTime.tryParse(trendData[groupIndex].date.toString());
              final dateStr = date != null ? "${date.day}/${date.month}/${date.year}" : "N/A";
              return BarTooltipItem("$dateStr\nOrders: ${rod.toY.toInt()}",
                  const TextStyle(color: Colors.white, fontSize: 11));
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < trendData.length) {
                  final date = DateTime.tryParse(trendData[value.toInt()].date.toString());
                  return Padding(padding: const EdgeInsets.only(top: 8),
                      child: Text(date != null ? "${date.day}/${date.month}" : "", style: const TextStyle(fontSize: 8)));
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 1)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: trendData.asMap().entries.map((e) {
          return BarChartGroupData(x: e.key, barRods: [
            BarChartRodData(
              toY: double.tryParse(e.value.count.toString()) ?? 0,
              color: const Color(0xff6366F1),
              width: 16,
              borderRadius: BorderRadius.circular(4),
            )
          ]);
        }).toList(),
      ),
    );
  }


  Widget buildGenericStatsGrid({required List<Map<String, dynamic>> items,required bool isMobile,}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      // Generic function mein gridDelegate ko aise update kar dein
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        // Responsive Ratio: Mobile pe thoda bada, Desktop pe thoda chota
        childAspectRatio: isMobile ? 2.4 : 3.8,
      ),
      itemBuilder: (context, index) {
        final stat = items[index];
        final Color color = stat['color'];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.2), width: 0.8),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [stat['bg'], stat['bg'].withOpacity(0.5)]),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.15), width: 1.0),
                  ),
                  child: Icon(stat['icon'], size: 18, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stat['title'], style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: color.withOpacity(0.8), letterSpacing: 0.5)),
                      Text("${stat['val']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xff1E293B))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }










  /////////////////////////////////when Counter User lgoin ////////////////////////////////////////////////////////

  Widget buildCounterDashboardResponsive(CounterDashboardModel data) {
    return LayoutBuilder(builder: (context, constraints) {
      // Agar screen width 800 se kam hai, toh mobile manenge
      bool isMobile = constraints.maxWidth < 800;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCounterStatsGrid(data, isMobile),
            const SizedBox(height: 24),

            // ROW 1: Chart & Requests
            isMobile
                ? Column(children: [
              _buildStockMovementChartWrapper(data.stockMovement),
              const SizedBox(height: 16),
              _buildRequestList("LATEST REQUESTS", data.requests),
            ])
                : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildStockMovementChartWrapper(data.stockMovement)),
                const SizedBox(width: 16),
                Expanded(child: _buildRequestList("LATEST REQUESTS", data.requests)),
              ],
            ),

            const SizedBox(height: 16),

            // ROW 2: Inventory & Expiry Alerts
            isMobile
                ? Column(children: [
              _buildInventoryList("INVENTORY", data.inventory),
              const SizedBox(height: 16),
              _buildInventoryList("EXPIRY ALERTS", data.expiryAlerts),
            ])
                : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildInventoryList("INVENTORY", data.inventory)),
                const SizedBox(width: 16),
                Expanded(child: _buildInventoryList("EXPIRY ALERTS", data.expiryAlerts)),
              ],
            ),
          ],
        ),
      );
    });
  }


  Widget _buildStockMovementChartWrapper(List<ChartData> movementData) {
    if (movementData.isEmpty) return const Center(child: Text("No Data Available"));

    final double maxCount = movementData.map((e) => double.tryParse(e.count.toString()) ?? 0.0)
        .fold(0.0, (a, b) => a > b ? a : b);

    // 1. MaxY ko thoda aur space dein taaki bar top se touch na ho
    final double maxYValue = (maxCount * 1.1).ceilToDouble();

    // 2. Interval ko 5 hisson mein baantein
    final double interval = (maxYValue / 5).ceilToDouble();

    return Container(
      height: SizeConfig.blockSizeVertical! * 45,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("STOCK MOVEMENT",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxYValue,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xff1E293B),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final data = movementData[groupIndex];
                      return BarTooltipItem("${data.transaction_type}\nQty: ${rod.toY.toInt()}",
                          const TextStyle(color: Colors.white, fontSize: 11));
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(movementData[value.toInt()].transaction_type,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40, // Number bada hone par jagah di
                      interval: interval > 0 ? interval : 1,
                      getTitlesWidget: (value, meta) {
                        // 3. Values ko short format mein dikhayein (e.g., 1k, 2k)
                        String text = value >= 1000 ? "${(value / 1000).toStringAsFixed(1)}k" : value.toInt().toString();
                        return Text(text, style: const TextStyle(fontSize: 9));
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: interval),
                borderData: FlBorderData(show: false),
                barGroups: movementData.asMap().entries.map((e) {
                  final double val = double.tryParse(e.value.count.toString()) ?? 0.0;
                  // 4. IN ke liye Green, OUT ke liye Red
                  final Color barColor = e.value.transaction_type.toString().toUpperCase() == "OUT"
                      ? Colors.redAccent : e.value.transaction_type.toString().toUpperCase() == 'ADJUST' ? Colors.blue
                      : const Color(0xff10B981);

                  return BarChartGroupData(x: e.key, barRods: [
                    BarChartRodData(
                      toY: val,
                      color: barColor,
                      width: 25,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    )
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterStatsGrid(CounterDashboardModel data, bool isMobile) {
    final summary = data.summary.isNotEmpty ? data.summary.first : Summary();

    final List<Map<String, dynamic>> counterStats = [
      {"title": "TOTAL ITEMS", "val": summary.totalItems, "color": Colors.indigo, "bg": const Color(0xffEEF2FF), "icon": Icons.inventory_2},
      {"title": "ACTIVE REQ", "val": data.requests.length, "color": Colors.blue, "bg": const Color(0xffEFF6FF), "icon": Icons.list_alt},
    ];

    return buildGenericStatsGrid(items: counterStats, isMobile: isMobile);
  }

// 2. Updated Request List (Premium Design)
  Widget _buildRequestList(String title, List<RequestItem> requests) {
    return Container(
      height: SizeConfig.blockSizeVertical! * 45,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title, requests.length),
          const SizedBox(height: 12),
          const Divider(height: 8, thickness: 0.5, color: Colors.black12),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 8),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const Divider(height: 16, thickness: 0.5, color: Colors.black12),
              itemBuilder: (context, index) {
                final req = requests[index];
                return Row(
                  children: [
                    _buildSerialNumber(index),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Quantity Section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // Left alignment ke liye zaroori hai
                            children: [
                              Text(
                                req.sweet_name,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800, // Bold for name
                                    color: Color(0xff1E293B)
                                ),
                              ),
                              const SizedBox(height: 2), // Dono ke beech thodi jagah
                              Text(
                                "Qty: ${req.quantity}",
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueGrey // Light color for secondary info
                                ),
                              ),
                            ],
                          ),

                          // Status Badge (Modern Pill Shape)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (req.status == "APPROVED" ? Colors.green : Colors.orange).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: (req.status == "APPROVED" ? Colors.green : Colors.orange).withOpacity(0.3)),
                            ),
                            child: Text(req.status.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: req.status == "APPROVED" ? Colors.green : Colors.orange
                                )),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

// Helper: Premium Header (Used in Inventory & Requests)
  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.grey.shade100, Colors.grey.shade200]),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white),
          ),
          child: Row(
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text("Total: $count", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade800)),
            ],
          ),
        ),
      ],
    );
  }

// Helper: Circular Serial Number
  Widget _buildSerialNumber(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 24, height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: const Color(0xffEFF6FF), borderRadius: BorderRadius.circular(4)),
      child: Text("${index + 1}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xff3B82F6))),
    );
  }










  /////////////////////////////////when Supplier lgoin ////////////////////////////////////////////////////////

  Widget buildSupplierDashboardResponsive(SupplierDashboardModel data) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 800;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. Stats Grid
            _buildSupplierStatsGrid(data, constraints.maxWidth < 600),
            const SizedBox(height: 24),

            // 2. Chart + Orders Row
            isMobile
                ? _buildSupplierDashboardColumn(data)
                : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chart
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 350,
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("ORDERS TREND", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 16),
                        Expanded(child: _buildOrderTrendChartDynamic(data.orderTrend)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Recent Orders
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 350,
                    child: _buildOrdersList("RECENT ORDERS", data.orders),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    });
  }

  Widget _buildSupplierDashboardColumn(SupplierDashboardModel data) {
    return Column(
      children: [
        const Text("ORDERS TREND",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 10),
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: _buildOrderTrendChartDynamic(data.orderTrend),
        ),
        const SizedBox(height: 16),
        // Yahan height set karna zaroori hai list ke liye
        SizedBox(
          height: 300,
          child: _buildOrdersList("RECENT ORDERS", data.orders),
        ),
      ],
    );
  }

  Widget _buildSupplierStatsGrid(SupplierDashboardModel data, bool isMobile) {
    final summary = data.summary.isNotEmpty ? data.summary.first : Summary();

    final List<Map<String, dynamic>> supplierStats = [
      {"title": "TOTAL ORDERS", "val": summary.totalOrders, "color": Colors.indigo, "bg": const Color(0xffEEF2FF), "icon": Icons.shopping_bag},
      {"title": "PENDING ITEMS", "val": data.pendingItems, "color": Colors.orange, "bg": const Color(0xffFFF7ED), "icon": Icons.pending_actions},
      {"title": "APPROVED", "val": summary.approved, "color": Colors.green, "bg": const Color(0xffECFDF5), "icon": Icons.check_circle},
      {"title": "UNVERIFIED CHALLANS", "val": data.unverifiedChalans, "color": Colors.red, "bg": const Color(0xffFEF2F2), "icon": Icons.assignment_late},
    ];

    return buildGenericStatsGrid(items: supplierStats, isMobile: isMobile);
  }

  Widget _buildOrdersList(String title, List<SupplierOrdersModel> orders) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section with Total Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey,
                    letterSpacing: 0.8
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "Total: ${orders.length}",
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Colors.blue
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5, color: Colors.black12),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.separated(
              itemCount: orders.length,
              separatorBuilder: (_, __) => const Divider(height: 16, thickness: 0.5, color: Colors.black12),
              itemBuilder: (context, index) {
                final order = orders[index];
                // Serial Number: 01, 02...
                final String serialNo = (index + 1).toString().padLeft(2, '0');

                return Row(
                  children: [
                    // Serial Number Container
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(serialNo, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blue)),
                    ),
                    const SizedBox(width: 12),

                    // Order Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Shop: ${order.shopName ?? 'N/A'}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xff1E293B))),
                          const SizedBox(height: 2),
                          Text("Counter: ${order.counters?.join(', ') ?? 'N/A'}",
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),

                    // Dynamic Status Badge
                    _buildStatusBadge(order.status ?? 'PENDING'),
                  ],
                );
              },
            ),
          ),
        ],
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