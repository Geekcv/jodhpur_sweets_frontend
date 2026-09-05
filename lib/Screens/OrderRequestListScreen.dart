import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants/static.dart';
import '../models/FetchOrderRequestModel.dart';
import '../provider/provider.dart';
import '../widgets/CustomDropDownSearch.dart';

class OrderRequestListScreen extends ConsumerStatefulWidget {
  const OrderRequestListScreen({super.key});

  @override
  ConsumerState<OrderRequestListScreen> createState() =>
      _OrderRequestListScreenState();
}

class _OrderRequestListScreenState extends ConsumerState<OrderRequestListScreen> {
  static const Color primaryNavy = Color(0xff0F172A);
  static const Color slateDark = Color(0xff334155);
  static const Color slateSub = Color(0xff64748B);
  static const Color bgCol = Color(0xffF8FAFC);
  static const Color borderCol = Color(0xffE2E8F0);

  // --- FILTER STATES ---
  String selectedFilter = "ALL"; // ALL, PENDING, ACCEPTED, REJECTED
  String searchQuery = "";
  bool isCardView = true;
  final TextEditingController _searchController = TextEditingController();

  final List<String> filterOptions = ["ALL", "PENDING", "ACCEPTED", "REJECTED"];

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
    final List<FetchOrderRequestModel> rawGroupList = masterProv.allOrdersOfCounterUser ?? [];
    final bool isLoading = masterProv.loading;

    final List<Map<String, dynamic>> processedGroups = [];

    for (var group in rawGroupList) {
      final List<OrderItemModel> items = group.requests ?? [];

      final filteredItems = items.where((item) {
        final status = (item.shopStatus ?? "PENDING").toString().toUpperCase();
        final sweetName = (item.sweetName ?? "").toString().toLowerCase();
        final reqOrder = (item.requestedOrder ?? "").toString().toLowerCase();
        final counterName = (item.counterName ?? "").toString().toLowerCase();
        final groupTime = (group.requestGroup ?? "").toString().toLowerCase();
        final query = searchQuery.toLowerCase();

        bool matchesFilter = (selectedFilter == "ALL") || (status == selectedFilter);
        bool matchesSearch = sweetName.contains(query) ||
            reqOrder.contains(query) ||
            counterName.contains(query) ||
            groupTime.contains(query);

        return matchesFilter && matchesSearch;
      }).toList();

      if (filteredItems.isNotEmpty) {
        processedGroups.add({
          'group': group,
          'items': filteredItems,
        });
      }
    }

    return Scaffold(
      backgroundColor: bgCol,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;

          return Padding(
            padding: EdgeInsets.all(width < 600 ? 12 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Header Title & Subtitle
                const Text(
                  "Track Request",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: primaryNavy,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Track all your submitted orders",
                  style: TextStyle(fontSize: 12, color: slateSub, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 16),

                // Top Controls: Search Bar + Filter Dropdown + View Toggle Icons
                _buildControlHeader(width),
                const SizedBox(height: 16),

                // Content Section
                Expanded(
                  child: isLoading
                      ? buildShimmerEffectCard(context: context)
                      : processedGroups.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: processedGroups.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final groupData = processedGroups[index];
                      return _buildGroupCard(
                        groupData['group'] as FetchOrderRequestModel,
                        groupData['items'] as List<OrderItemModel>,
                        width,
                      );
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

  // ---------- TOP CONTROL ROW (Search + Dropdown + Icon View Switcher) ----------
  Widget _buildControlHeader(double width) {
    bool isSmallScreen = width < 700;

    Widget searchBar = SizedBox(
      width: isSmallScreen ? double.infinity : 300,
      height: 38,
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => searchQuery = val),
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          isDense: true,
          hintText: "Search sweet name, REQ ID...",
          hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          prefixIcon: const Icon(Icons.search, size: 16, color: slateSub),
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
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderCol),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xff2563EB)),
          ),
        ),
      ),
    );

    Widget filterDropdown = SizedBox(
      width: isSmallScreen ? double.infinity : 150,
      height: 38,
      child: CustomDropdownSearch<String>(
        items: filterOptions,
        selectedItem: selectedFilter,
        itemLabelBuilder: (v) {
          if (v == "ACCEPTED") return "Approved";
          if (v == "PENDING") return "Pending";
          if (v == "REJECTED") return "Rejected";
          return v ?? "Select Filter";
        },
        compareFn: (a, b) => a == b,
        onChanged: (v) {
          if (v != null) {
            setState(() => selectedFilter = v);
          }
        },
        hintText: "Filter Status",
      ),
    );

    Widget viewToggleIcons = Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderCol),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _iconToggleButton(
            icon: Icons.grid_view_rounded,
            isSelected: isCardView,
            onTap: () => setState(() => isCardView = true),
          ),
          const SizedBox(width: 2),
          _iconToggleButton(
            icon: Icons.view_list_rounded,
            isSelected: !isCardView,
            onTap: () => setState(() => isCardView = false),
          ),
        ],
      ),
    );

    if (isSmallScreen) {
      return Column(
        children: [
          searchBar,
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: filterDropdown),
              const SizedBox(width: 10),
              viewToggleIcons,
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        searchBar,
        const SizedBox(width: 12),
        filterDropdown,
        const SizedBox(width: 12),
        viewToggleIcons,
      ],
    );
  }

  Widget _iconToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected ? const Color(0xff2563EB) : slateSub,
        ),
      ),
    );
  }

  // ---------- EXPANDABLE REQUEST GROUP CARD CONTAINER ----------
  Widget _buildGroupCard(FetchOrderRequestModel groupHeader, List<OrderItemModel> items, double screenWidth) {
    bool isMobile = screenWidth < 700;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          childrenPadding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
          title: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // const Icon(Icons.folder_open_rounded, size: 16, color: Color(0xff2563EB)),
                      // const SizedBox(width: 6),
                      Text(
                        // "Group: ${groupHeader.requestGroup ?? '-'}",
                        "Request: ",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: primaryNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatFullDate(groupHeader.crOn),
                    style: const TextStyle(fontSize: 11, color: slateSub),
                  ),
                ],
              ),
              // Summary Counters
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _badgeChip("Total Items", "${groupHeader.totalRequests ?? items.length}", Colors.amber),
                  _badgeChip("Total Req Qty", "${groupHeader.totalRequestedQuantity ?? 0}", Colors.blue),
                  _badgeChip("Total Supplied", "${groupHeader.totalSuppliedQuantity ?? 0}", Colors.teal),
                  _badgeChip("Total Pending", "${groupHeader.totalPendingQuantity ?? 0}", Colors.orange),
                ],
              ),
            ],
          ),
          children: [
            const Divider(height: 16, color: borderCol),
            isCardView
                ? _buildGridCardLayout(items, screenWidth)
                : _buildListRowLayout(items, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _badgeChip(String label, String val, MaterialColor col) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: col.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: col.shade200),
      ),
      child: Text(
        "$label: $val",
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: col.shade800),
      ),
    );
  }

  // ---------- VIEW 1: RESPONSIVE GRID CARDS LAYOUT ----------
  Widget _buildGridCardLayout(List<OrderItemModel> items, double screenWidth) {
    int crossAxisCount = 1;
    if (screenWidth >= 1200) {
      crossAxisCount = 3;
    } else if (screenWidth >= 768) {
      crossAxisCount = 2;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 120, // Clean readable height
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final status = (item.shopStatus ?? "PENDING").toString().toUpperCase();

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xffF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.sweetName?.toString() ?? "-",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: primaryNavy),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _statusBadge(status),
                ],
              ),
              Text(
                "${item.requestedOrder ?? ''} • ${item.counterName ?? ''}",
                style: const TextStyle(fontSize: 11, color: slateSub, fontWeight: FontWeight.w500),
              ),
              const Divider(height: 8, color: Color(0xffE2E8F0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Qty: ${item.requestedQuantity ?? 0} ${item.unit ?? ''}",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: primaryNavy)),
                  Row(
                    children: [
                      Text("Supplied qty: ${item.suppliedQuantity ?? 0}",
                          style: TextStyle(fontSize: 10, color: Colors.teal.shade700, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      Text("Pending qty: ${item.pendingQuantity ?? 0}",
                          style: TextStyle(fontSize: 10, color: Colors.orange.shade800, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------- VIEW 2: RESPONSIVE LIST / ROW LAYOUT ----------
  Widget _buildListRowLayout(List<OrderItemModel> items, bool isMobile) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final status = (item.shopStatus ?? "PENDING").toString().toUpperCase();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xffF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderCol),
          ),
          child: isMobile
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.sweetName?.toString() ?? "-",
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: primaryNavy),
                    ),
                  ),
                  _statusBadge(status),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                "${item.requestedOrder ?? ''} • ${item.counterName ?? ''}",
                style: const TextStyle(fontSize: 11, color: slateSub),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Qty: ${item.requestedQuantity ?? 0} ${item.unit ?? ''}",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: primaryNavy)),
                  Text("Supplied: ${item.suppliedQuantity ?? 0}",
                      style: TextStyle(fontSize: 11, color: Colors.teal.shade700, fontWeight: FontWeight.w600)),
                  Text("Pending: ${item.pendingQuantity ?? 0}",
                      style: TextStyle(fontSize: 11, color: Colors.orange.shade800, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          )
              : Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.sweetName?.toString() ?? "-",
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: primaryNavy),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${item.requestedOrder ?? ''} • ${item.counterName ?? ''}",
                      style: const TextStyle(fontSize: 11, color: slateSub),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Qty: ${item.requestedQuantity ?? 0} ${item.unit ?? ''}",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: primaryNavy)),
                    Text("Supplied: ${item.suppliedQuantity ?? 0}",
                        style: TextStyle(fontSize: 11, color: Colors.teal.shade700, fontWeight: FontWeight.w600)),
                    Text("Pending: ${item.pendingQuantity ?? 0}",
                        style: TextStyle(fontSize: 11, color: Colors.orange.shade800, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              _statusBadge(status),
            ],
          ),
        );
      },
    );
  }

  // ---------- STATUS BADGE ----------
  Widget _statusBadge(String status) {
    Color bg = const Color(0xffFEF3C7);
    Color text = const Color(0xffD97706);

    if (status == "ACCEPTED" || status == "APPROVED") {
      bg = const Color(0xffDCFCE7);
      text = const Color(0xff16A34A);
    } else if (status == "REJECTED") {
      bg = const Color(0xffFEE2E2);
      text = const Color(0xffDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status == "ACCEPTED" ? "Approved" : (status == "PENDING" ? "Pending" : status),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: text),
      ),
    );
  }

  String _formatFullDate(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return "-";
    try {
      DateTime dt = DateTime.parse(dateStr.toString());
      // return DateFormat('yyyy-MM-dd HH:mm').format(dt);
      return DateFormat('dd-MM-yyyy hh:mm a').format(dt);
    } catch (e) {
      return dateStr.toString();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.search_off_rounded, size: 40, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No matching requests found",
            style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}