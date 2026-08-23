import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:js_order_website/Screens/LoginUserDetails.dart';
import '../constants/static.dart';
import '../provider/provider.dart';
import '../widgets/CustomDropDownSearch.dart';

class ExpireItemsScreen extends ConsumerStatefulWidget {
  const ExpireItemsScreen({super.key});

  @override
  ConsumerState<ExpireItemsScreen> createState() => _ExpireItemsScreenState();
}

class _ExpireItemsScreenState extends ConsumerState<ExpireItemsScreen> {
  static const Color primaryNavy = Color(0xff0F172A);
  static const Color slateDark = Color(0xff334155);
  static const Color bgCol = Color(0xffF8FAFC);
  static const Color borderCol = Color(0xffE2E8F0);
  static const Color dangerRed = Color(0xffDC2626);

  String? selectedCounterId;
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initFlow();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initFlow() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(master_Provider).fetchCounter();

      final String role = LoginUserDetails.role?.toUpperCase() ?? "";
      final counters = ref.read(master_Provider).allCounters ?? [];

      if (role == 'SHOPADMIN' || role == 'SHOP_ADMIN') {
        if (counters.isNotEmpty) {
          selectedCounterId = counters.first.row_id.toString();
          ref.read(master_Provider).fetchExpireItems(params: {"counter_id": selectedCounterId});
        }
      } else {
        selectedCounterId = LoginUserDetails.counterId?.toString();
        if (selectedCounterId != null) {
          ref.read(master_Provider).fetchExpireItems(params: {"counter_id": selectedCounterId});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final masterProv = ref.watch(master_Provider);
    final counters = masterProv.allCounters ?? [];
    final rawExpiredItems = masterProv.expireItmesData ?? [];
    final isLoading = masterProv.loading;

    // --- SEARCH FILTER ---
    final filteredItems = rawExpiredItems.where((item) {
      final name = (item.sweet_name ?? "").toString().toLowerCase();
      final reason = (item.reason ?? "").toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      return name.contains(query) || reason.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: bgCol,
      body: SafeArea(
        child: LayoutBuilder(
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
                  // Top Header & Actions
                  _buildTopBar(width, counters),
                  const SizedBox(height: 26),


                  // Items Grid Content
                  Expanded(
                    child: isLoading
                        ? buildShimmerEffect(context: context)
                        : filteredItems.isEmpty
                        ? _buildEmptyState()
                        : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        mainAxisExtent: 120,
                      ),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        return _buildExpiredCard(filteredItems[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------- HEADER & SEARCH BAR ----------
  Widget _buildTopBar(double screenWidth, List counters) {
    final String role = LoginUserDetails.role?.toUpperCase() ?? "";
    bool isShopAdmin = (role == 'SHOPADMIN' || role == 'SHOP_ADMIN');

    String currentCounterName = "Assigned Counter";
    if (!isShopAdmin && selectedCounterId != null) {
      try {
        var current = counters.firstWhere((e) => e.row_id.toString() == selectedCounterId);
        currentCounterName = current.counter_name ?? "Assigned Counter";
      } catch (_) {
        currentCounterName = "Counter ID: $selectedCounterId";
      }
    }

    // --- Title Section ---
    Widget titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            const Text(
              "Expired Inventory",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: primaryNavy,
                letterSpacing: -0.5,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: dangerRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "EXPIRED",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: dangerRed,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        const Text(
          "Track items that have reached their shelf life",
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );

    // --- Search Bar Widget ---
    Widget searchWidget = SizedBox(
      width: screenWidth < 768 ? double.infinity : 260,
      height: 38,
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => searchQuery = val),
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          isDense: true,
          hintText: "Search item...",
          hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          prefixIcon: const Icon(Icons.search, size: 16, color: Colors.blueGrey),
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
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderCol),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderCol),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryNavy),
          ),
        ),
      ),
    );

    // --- Counter Selector Widget ---
    Widget counterSelector = isShopAdmin
        ? SizedBox(
      width: screenWidth < 768 ? double.infinity : 220,
      child: _dropdown("SELECT COUNTER", counters, (v) => v.counter_name, (v) {
        setState(() {
          selectedCounterId = v.row_id.toString();
        });
        ref.read(master_Provider).fetchExpireItems(params: {"counter_id": selectedCounterId});
      }),
    )
        : _infoBadge("Counter: $currentCounterName");

    // --- Mobile View (<768px) ---
    if (screenWidth < 768) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleSection,
          const SizedBox(height: 12),
          counterSelector,
          const SizedBox(height: 10),
          searchWidget,
        ],
      );
    }

    // --- Desktop/Tablet View (≥768px - Align Right Side) ---
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: titleSection),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            counterSelector,
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16), // Dropdown title baseline match
                searchWidget,
              ],
            ),
          ],
        ),
      ],
    );
  }


  // ---------- EXPIRED ITEM CARD ----------
  Widget _buildExpiredCard(dynamic item) {
    double lossAmount = double.tryParse(item.loss_amount?.toString() ?? "0") ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: dangerRed, width: 3.5)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Row 1: Item Name + Loss Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.sweet_name?.toString().toUpperCase() ?? "N/A",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: primaryNavy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: dangerRed.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: dangerRed.withOpacity(0.2)),
                    ),
                    child: Text(
                      "₹${lossAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: dangerRed,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 12, color: Color(0xffF1F5F9)),

              // Row 2: Metadata Details (Quantity, Counter, Expiry Date)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _metaBlock("QUANTITY", "${item.quantity ?? '0'}", isBold: true),
                  _metaBlock("EXPIRY DATE", _formatDate(item.expiry_date?.toString())),
                  _metaBlock("COUNTER", item.counter_name ?? "-", alignRight: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaBlock(String label, String value,
      {bool alignRight = false, bool isBold = false}) {
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
            fontSize: 11,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: slateDark,
          ),
        ),
      ],
    );
  }

  // ---------- HELPER DROPDOWNS & BADGES ----------
  Widget _dropdown(String label, List items, String Function(dynamic) labelBuilder, Function(dynamic) onSel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(label, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Colors.blueGrey)),
        // const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: CustomDropdownSearch<dynamic>(
            items: items,
            itemLabelBuilder: labelBuilder,
            compareFn: (a, b) => a.row_id.toString() == b.row_id.toString(),
            onChanged: (val) {
              if (val != null) {
                onSel(val);
              }
            },
            hintText: "Select Counter",
          ),
        ),
      ],
    );
  }

  Widget _infoBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderCol), // light slate border
        boxShadow: const [
          BoxShadow(
            color: Color(0x03000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Active Indicator Dot
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xff2563EB), // Professional Royal Blue
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              color: primaryNavy,
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == "null") return "-";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.event_busy_rounded, size: 40, color: Color(0xffCBD5E1)),
          SizedBox(height: 8),
          Text(
            "No Expired Items Found",
            style: TextStyle(color: Color(0xff64748B), fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}