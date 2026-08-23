import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants/static.dart';
import '../provider/provider.dart';

class OrderRequestListScreen extends ConsumerStatefulWidget {
  const OrderRequestListScreen({super.key});

  @override
  ConsumerState<OrderRequestListScreen> createState() =>
      _OrderRequestListScreenState();
}

class _OrderRequestListScreenState
    extends ConsumerState<OrderRequestListScreen> {
  static const Color primaryNavy = Color(0xff0F172A);
  static const Color slateDark = Color(0xff334155);
  static const Color bgCol = Color(0xffF8FAFC);
  static const Color borderCol = Color(0xffE2E8F0);
  static const Color cardBg = Colors.white;

  // --- FILTER STATES ---
  String selectedTab = "ALL"; // ALL, PENDING, APPROVED, REJECTED
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(master_Provider).fetchOrderRequest();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final masterProv = ref.watch(master_Provider);
    final List<dynamic> rawOrders = masterProv.allOrdersOfCounterUser ?? [];
    final bool isLoading = masterProv.loading;

    // --- APPLY FILTERS ---
    final filteredOrders = rawOrders.where((order) {
      final status = (order.status ?? "PENDING").toString().toUpperCase();
      final sweetName = (order.sweet_name ?? "").toString().toLowerCase();
      final counterName = (order.counter_name ?? "").toString().toLowerCase();
      final String query = searchQuery.toLowerCase();

      bool matchesTab = (selectedTab == "ALL") || (status == selectedTab);
      bool matchesSearch =
          sweetName.contains(query) || counterName.contains(query);

      return matchesTab && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: bgCol,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;

          int crossAxisCount = 1;
          if (width >= 1280) {
            crossAxisCount = 4;
          } else if (width >= 900) {
            crossAxisCount = 3;
          } else if (width >= 600) {
            crossAxisCount = 2;
          }

          return Padding(
            padding: EdgeInsets.all(width < 600 ? 12 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title + Search Bar on Right
                _buildHeaderWithSearch(rawOrders.length, width),
                const SizedBox(height: 16),

                // Modern Segmented Status Bar
                _buildSegmentedTabs(rawOrders),
                const SizedBox(height: 16),

                // Dynamic Cards Grid
                Expanded(
                  child: isLoading
                      ? buildShimmerEffectCard(context: context)
                      : filteredOrders.isEmpty
                      ? _buildEmptyState()
                      : GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      mainAxisExtent: 160,
                    ),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(
                          filteredOrders[index], index + 1);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------- HEADER WITH INTEGRATED RIGHT SEARCH BAR ----------
  Widget _buildHeaderWithSearch(int totalCount, double screenWidth) {
    Widget titleWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Order Requests",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: primaryNavy,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: primaryNavy.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "$totalCount Total",
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: primaryNavy,
            ),
          ),
        ),
      ],
    );

    Widget searchWidget = SizedBox(
      width: screenWidth < 600 ? double.infinity : 340,
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => searchQuery = val),
        style: const TextStyle(fontSize: 11),
        decoration: InputDecoration(
          isDense: true,
          hintText: "Search item...",
          hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
          prefixIcon: const Icon(Icons.search, size: 15, color: Colors.blueGrey),
          suffixIcon: searchQuery.isNotEmpty
              ? InkWell(
            onTap: () {
              _searchController.clear();
              setState(() => searchQuery = "");
            },
            child: const Icon(Icons.clear, size: 14, color: Colors.grey),
          )
              : null,
          filled: true,
          fillColor: cardBg,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: borderCol),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: borderCol),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: primaryNavy),
          ),
        ),
      ),
    );

    if (screenWidth < 600) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          const SizedBox(height: 12),
          searchWidget,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        titleWidget,
        searchWidget,
      ],
    );
  }

  // ---------- MODERN SEGMENTED STATUS TAB BAR ----------
  Widget _buildSegmentedTabs(List<dynamic> allOrders) {
    int getCount(String tabStatus) {
      if (tabStatus == "ALL") return allOrders.length;
      return allOrders
          .where((o) =>
      (o.status ?? "PENDING").toString().toUpperCase() == tabStatus)
          .length;
    }

    final tabs = [
      {'key': 'ALL', 'label': 'All Requests', 'color': primaryNavy},
      {'key': 'PENDING', 'label': 'Pending', 'color': const Color(0xffD97706)},
      {'key': 'APPROVED', 'label': 'Approved', 'color': const Color(0xff16A34A)},
      {'key': 'REJECTED', 'label': 'Rejected', 'color': const Color(0xffDC2626)},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xffF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderCol),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: tabs.map((tab) {
            String key = tab['key'] as String;
            String label = tab['label'] as String;
            Color themeColor = tab['color'] as Color;
            bool isSelected = selectedTab == key;
            int count = getCount(key);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => selectedTab = key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected ? primaryNavy : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? themeColor.withOpacity(0.12)
                                  : Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "$count",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? themeColor : Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ---------- MODERN & CLEAN DATA CARD ----------
  Widget _buildOrderCard(dynamic order, int index) {
    String status = (order.status ?? "PENDING").toString().toUpperCase();

    Color baseColor;
    if (status == "APPROVED") {
      baseColor = const Color(0xff16A34A);
    } else if (status == "REJECTED") {
      baseColor = const Color(0xffDC2626);
    } else {
      baseColor = const Color(0xffD97706);
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderCol),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: baseColor, width: 3.5)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Row 1: Item Name & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      order.sweet_name?.toString().toUpperCase() ?? "N/A",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: primaryNavy,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _statusBadge(status, baseColor),
                ],
              ),

              const Divider(height: 14, color: Color(0xffF1F5F9)),

              // Row 2: Metadata Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _metaBlock(
                    "QUANTITY",
                    "${order.quantity ?? '0'} ${order.unit ?? ''}",
                    valueColor: primaryNavy,
                    isBold: true,
                  ),
                  _metaBlock(
                    "COUNTER NAME",
                    order.counter_name ?? "-",
                    alignRight: true,
                  ),
                ],
              ),

              // Row 3: Footer Timestamp
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xffF8FAFC),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 11, color: Colors.blueGrey),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(order.cr_on?.toString()),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: slateDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaBlock(String label, String value,
      {bool alignRight = false,
        Color valueColor = slateDark,
        bool isBold = false}) {
    return Column(
      crossAxisAlignment:
      alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status, Color baseColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: baseColor.withOpacity(0.2)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: baseColor,
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == "null") return "-";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.search_off_rounded, size: 38, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            "No matching requests found",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}