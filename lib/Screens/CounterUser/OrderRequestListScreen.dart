import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../constants/static.dart';
import '../../models/FetchOrderRequestModel.dart';
import '../../provider/provider.dart';
import '../../widgets/CustomDropDownSearch.dart';

class OrderRequestListScreen extends ConsumerStatefulWidget {
  const OrderRequestListScreen({super.key});

  @override
  ConsumerState<OrderRequestListScreen> createState() =>
      _OrderRequestListScreenState();
}

class _OrderRequestListScreenState
    extends ConsumerState<OrderRequestListScreen> {
  // Modern Slate & Indigo Enterprise Palette
  static const Color primaryNavy = Color(0xff0F172A);
  static const Color slateDark = Color(0xff334155);
  static const Color slateSub = Color(0xff64748B);
  static const Color bgCol = Color(0xffF8FAFC);
  static const Color borderCol = Color(0xffE2E8F0);

  // --- FILTER STATES (UNCHANGED) ---
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
    final List<FetchOrderRequestModel> rawGroupList =
        masterProv.allOrdersOfCounterUser ?? [];
    final bool isLoading = masterProv.loading;

    // --- YOUR EXACT FILTER & SEARCH LOGIC (UNCHANGED) ---
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

        bool matchesFilter =
            (selectedFilter == "ALL") || (status == selectedFilter);
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
            padding: EdgeInsets.all(width < 600 ? 12 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title Section
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
                  "Track all your submitted orders in real-time",
                  style: TextStyle(
                      fontSize: 12,
                      color: slateSub,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 16),

                // Top Controls: Search Bar + Filter Dropdown + View Switcher
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
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 14),
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
      width: isSmallScreen ? double.infinity : 280,
      height: 38,
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => searchQuery = val),
        style: const TextStyle(fontSize: 12, color: primaryNavy),
        decoration: InputDecoration(
          isDense: true,
          hintText: "Search sweet name, REQ ID...",
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xff94A3B8)),
          prefixIcon: const Icon(Icons.search, size: 16, color: slateSub),
          suffixIcon: searchQuery.isNotEmpty
              ? InkWell(
            onTap: () {
              _searchController.clear();
              setState(() => searchQuery = "");
            },
            child: const Icon(Icons.clear, size: 14, color: slateSub),
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
            borderSide: const BorderSide(color: Color(0xff2563EB), width: 1.5),
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
  Widget _buildGroupCard(FetchOrderRequestModel groupHeader,
      List<OrderItemModel> items, double screenWidth) {
    bool isMobile = screenWidth < 700;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderCol),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding:
          const EdgeInsets.only(left: 14, right: 14, bottom: 14),
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
                      const Icon(Icons.receipt_long_rounded,
                          size: 15, color: Color(0xff2563EB)),
                      const SizedBox(width: 6),
                      Text(
                        "Request #${groupHeader.requestGroup ?? '-'}",
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: primaryNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatFullDate(groupHeader.crOn),
                    style: const TextStyle(
                        fontSize: 11,
                        color: slateSub,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              // Compact Summary Chips
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _badgeChip(
                      "Items",
                      "${groupHeader.totalRequests ?? items.length}",
                      const Color(0xffF1F5F9),
                      const Color(0xff334155)),
                  _badgeChip(
                      "Req Qty",
                      "${groupHeader.totalRequestedQuantity ?? 0}",
                      const Color(0xffEFF6FF),
                      const Color(0xff1D4ED8)),
                  _badgeChip(
                      "Supplied",
                      "${groupHeader.totalSuppliedQuantity ?? 0}",
                      const Color(0xffCCFBF1),
                      const Color(0xff0F766E)),
                  _badgeChip(
                      "Pending",
                      "${groupHeader.totalPendingQuantity ?? 0}",
                      const Color(0xffFEF3C7),
                      const Color(0xffB45309)),
                ],
              ),
            ],
          ),
          children: [
            const Divider(height: 12, color: borderCol),
            const SizedBox(height: 4),
            isCardView
                ? _buildGridCardLayout(items, screenWidth)
                : _buildListRowLayout(items, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _badgeChip(
      String label, String val, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        "$label: $val",
        style: TextStyle(
            fontSize: 9.5, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }

  // ---------- VIEW 1: RESPONSIVE COMPACT CARD GRID (NO OVERFLOW/OVERSIZING) ----------
  Widget _buildGridCardLayout(List<OrderItemModel> items, double screenWidth) {
    int crossAxisCount =
    screenWidth >= 1200 ? 3 : (screenWidth >= 768 ? 2 : 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth =
            (constraints.maxWidth - ((crossAxisCount - 1) * 12)) /
                crossAxisCount;

        return Align(
          alignment: Alignment.topLeft,
          child: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            spacing: 12,
            runSpacing: 12,
            children: items.map((item) {
              final String shopStatus =
              (item.shopStatus ?? "PENDING").toString().toUpperCase();
              final String supplierStatus =
              (item.supplierStatus ?? "PENDING").toString().toUpperCase();
              final bool hasReorders =
                  item.reorderOrders != null && item.reorderOrders!.isNotEmpty;

              // --- SAFE NUMBER PARSING (FIX FOR TYPE ERROR) ---
              final num reorderSupplied =
                  num.tryParse(item.reorderSuppliedQuantity?.toString() ?? '0') ?? 0;
              final num cancelledQty =
                  num.tryParse(item.cancelledQuantity?.toString() ?? '0') ?? 0;

              return SizedBox(
                width: cardWidth,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderCol, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x04000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Header Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.sweetName?.toString() ?? "-",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: primaryNavy,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${item.requestedOrder ?? ''} • ${item.counterName ?? ''}",
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: slateSub,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          // if (item.orderType != null)
                          //   Container(
                          //     padding: const EdgeInsets.symmetric(
                          //         horizontal: 6, vertical: 2),
                          //     decoration: BoxDecoration(
                          //       color: const Color(0xffF1F5F9),
                          //       borderRadius: BorderRadius.circular(4),
                          //     ),
                          //     child: Text(
                          //       item.orderType.toString(),
                          //       style: const TextStyle(
                          //           fontSize: 8.5,
                          //           fontWeight: FontWeight.w600,
                          //           color: Color(0xff475569)),
                          //     ),
                          //   ),
                          if (item.final_status != null) ...[
                            (() {
                              final statusStr = item.final_status.toString().toUpperCase().trim();
                              Color bgCol = const Color(0xffF1F5F9);
                              Color textCol = const Color(0xff475569);

                              switch (statusStr) {
                                case "COMPLETED":
                                  bgCol = const Color(0xffDCFCE7); // Light Green
                                  textCol = const Color(0xff15803D); // Dark Green
                                  break;
                                case "CANCELLED":
                                  bgCol = const Color(0xffFEE2E2); // Light Red
                                  textCol = const Color(0xffB91C1C); // Dark Red
                                  break;
                                case "REORDER_PENDING":
                                  bgCol = const Color(0xffFFEDD5); // Light Amber
                                  textCol = const Color(0xffC2410C); // Dark Amber
                                  break;
                                case "PARTIAL":
                                  bgCol = const Color(0xffFEF3C7); // Light Yellow
                                  textCol = const Color(0xffB45309); // Dark Yellow
                                  break;
                                case "PENDING":
                                default:
                                  bgCol = const Color(0xffE0F2FE); // Light Blue
                                  textCol = const Color(0xff0369A1); // Dark Blue
                                  break;
                              }

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: bgCol,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  statusStr,
                                  style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
                                      color: textCol),
                                ),
                              );
                            })(),
                          ],
                        ],
                      ),

                      const SizedBox(height: 8),

                      // 2. Status Chips
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          _buildCompactBadge("Shop: $shopStatus",
                              _getStatusTextColor(shopStatus), _getStatusBgColor(shopStatus)),
                          _buildCompactBadge("Supplier: $supplierStatus",
                              _getStatusTextColor(supplierStatus), _getStatusBgColor(supplierStatus)),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // 3. Compact Quantities Overview Box
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xffF8FAFC),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xffF1F5F9)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: _metricCell("Req Qty",
                                        "${item.requestedQuantity ?? 0} ${item.unit ?? ''}")),
                                Expanded(
                                    child: _metricCell("Supplied",
                                        "${item.suppliedQuantity ?? 0} ${item.unit ?? ''}")),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: _metricCell(
                                    "Pending",
                                    "${item.remainingQuantity ?? item.pendingQuantity ?? 0} ${item.unit ?? ''}",
                                    isWarning: true,
                                  ),
                                ),
                                // Safe comparison using parsed num values
                                if (reorderSupplied > 0)
                                  Expanded(
                                    child: _metricCell("Reorder Sup.",
                                        "$reorderSupplied ${item.unit ?? ''}"),
                                  )
                                else if (cancelledQty > 0)
                                  Expanded(
                                    child: _metricCell("Cancelled",
                                        "$cancelledQty ${item.unit ?? ''}",
                                        isDanger: true),
                                  )
                                else
                                  const Expanded(child: SizedBox.shrink()),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 4. Nested Reorders Section
                      if (hasReorders) ...[
                        const SizedBox(height: 8),
                        Text(
                          "Reorders (${item.reorderOrders!.length}):",
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: slateSub),
                        ),
                        const SizedBox(height: 4),
                        ...item.reorderOrders!.map((reorder) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "#${reorder.orderNumber ?? 'Reorder'}",
                                  style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: slateDark),
                                ),
                                Text(
                                  "Req: ${reorder.requestedQuantity} | Sup: ${reorder.suppliedQuantity}",
                                  style: const TextStyle(
                                      fontSize: 9, color: slateSub),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
  // ---------- VIEW 2: RESPONSIVE LIST / ROW LAYOUT ----------
  Widget _buildListRowLayout(List<OrderItemModel> items, bool isMobile) {
    Widget buildFinalStatusBadge(dynamic rawStatus) {
      if (rawStatus == null) return const SizedBox.shrink();
      final statusStr = rawStatus.toString().toUpperCase().trim();
      Color bgCol = const Color(0xffF1F5F9);
      Color textCol = const Color(0xff475569);

      switch (statusStr) {
        case "COMPLETED":
          bgCol = const Color(0xffDCFCE7);
          textCol = const Color(0xff15803D);
          break;
        case "CANCELLED":
          bgCol = const Color(0xffFEE2E2);
          textCol = const Color(0xffB91C1C);
          break;
        case "REORDER_PENDING":
          bgCol = const Color(0xffFFEDD5);
          textCol = const Color(0xffC2410C);
          break;
        case "PARTIAL":
          bgCol = const Color(0xffFEF3C7);
          textCol = const Color(0xffB45309);
          break;
        case "PENDING":
        default:
          bgCol = const Color(0xffE0F2FE);
          textCol = const Color(0xff0369A1);
          break;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bgCol,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          statusStr,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: textCol,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final String shopStatus =
        (item.shopStatus ?? "PENDING").toString().toUpperCase();
        final String supplierStatus =
        (item.supplierStatus ?? "PENDING").toString().toUpperCase();
        final bool hasReorders =
            item.reorderOrders != null && item.reorderOrders!.isNotEmpty;

        final num reorderSupplied =
            num.tryParse(item.reorderSuppliedQuantity?.toString() ?? '0') ?? 0;
        final num cancelledQty =
            num.tryParse(item.cancelledQuantity?.toString() ?? '0') ?? 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xffE2E8F0), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isMobile) ...[
                // --- MOBILE LAYOUT ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.sweetName?.toString() ?? "-",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: primaryNavy,
                        ),
                      ),
                    ),
                    buildFinalStatusBadge(item.final_status),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "${item.requestedOrder ?? ''} • ${item.counterName ?? ''}",
                  style: const TextStyle(fontSize: 11, color: slateSub),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildCompactBadge("Shop: $shopStatus",
                        _getStatusTextColor(shopStatus), _getStatusBgColor(shopStatus)),
                    _buildCompactBadge("Supplier: $supplierStatus",
                        _getStatusTextColor(supplierStatus), _getStatusBgColor(supplierStatus)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metricCell("Req Qty",
                        "${item.requestedQuantity ?? 0} ${item.unit ?? ''}"),
                    _metricCell("Supplied",
                        "${item.suppliedQuantity ?? 0} ${item.unit ?? ''}"),
                    _metricCell(
                      "Pending",
                      "${item.remainingQuantity ?? item.pendingQuantity ?? 0} ${item.unit ?? ''}",
                      isWarning: true,
                    ),
                    if (reorderSupplied > 0)
                      _metricCell("Reorder Sup.", "$reorderSupplied ${item.unit ?? ''}")
                    else if (cancelledQty > 0)
                      _metricCell("Cancelled", "$cancelledQty ${item.unit ?? ''}", isDanger: true),
                  ],
                ),
              ] else ...[
                // --- DESKTOP / TABLET PERFECT TABLE-LIKE ROW ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Col 1: Name & Order ID
                    SizedBox(
                      width: 180,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.sweetName?.toString() ?? "-",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "${item.requestedOrder ?? ''} • ${item.counterName ?? ''}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: slateSub,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Col 2: Status Badges Block
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildFinalStatusBadge(item.final_status),
                        const SizedBox(width: 8),
                        _buildCompactBadge(
                          "Shop: $shopStatus",
                          _getStatusTextColor(shopStatus),
                          _getStatusBgColor(shopStatus),
                        ),
                        const SizedBox(width: 6),
                        _buildCompactBadge(
                          "Supplier: $supplierStatus",
                          _getStatusTextColor(supplierStatus),
                          _getStatusBgColor(supplierStatus),
                        ),
                      ],
                    ),

                    const Spacer(), // Space pushes metrics evenly to the right side

                    // Col 3: Metric Cells Perfectly Grid-Aligned
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 90,
                          child: _metricCell("Req Qty",
                              "${item.requestedQuantity ?? 0} ${item.unit ?? ''}"),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 90,
                          child: _metricCell("Supplied",
                              "${item.suppliedQuantity ?? 0} ${item.unit ?? ''}"),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 90,
                          child: _metricCell(
                            "Pending",
                            "${item.remainingQuantity ?? item.pendingQuantity ?? 0} ${item.unit ?? ''}",
                            isWarning: true,
                          ),
                        ),
                        if (reorderSupplied > 0) ...[
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 90,
                            child: _metricCell("Reorder Sup.",
                                "$reorderSupplied ${item.unit ?? ''}"),
                          ),
                        ] else if (cancelledQty > 0) ...[
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 90,
                            child: _metricCell("Cancelled",
                                "$cancelledQty ${item.unit ?? ''}",
                                isDanger: true),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],

              // Reorders nested list if present
              if (hasReorders) ...[
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xffF1F5F9)),
                const SizedBox(height: 6),
                ...item.reorderOrders!.map((reorder) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Reorder #${reorder.orderNumber ?? ''}",
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: slateDark,
                          ),
                        ),
                        Text(
                          "Req: ${reorder.requestedQuantity} | Sup: ${reorder.suppliedQuantity}",
                          style: const TextStyle(fontSize: 9.5, color: slateSub),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
  // ---------- HELPER COMPONENTS ----------
  Widget _buildCompactBadge(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 8.5, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }

  Widget _metricCell(String label, String value,
      {bool isWarning = false, bool isDanger = false}) {
    Color valColor = primaryNavy;
    if (isWarning) valColor = const Color(0xffD97706);
    if (isDanger) valColor = const Color(0xffDC2626);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 8.5, color: slateSub)),
        Text(
          value,
          style: TextStyle(
              fontSize: 10.5, fontWeight: FontWeight.w700, color: valColor),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _getStatusBgColor(status),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status == "ACCEPTED" || status == "APPROVED"
            ? "Approved"
            : (status == "PENDING" ? "Pending" : status),
        style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: _getStatusTextColor(status)),
      ),
    );
  }

  Color _getStatusBgColor(String status) {
    if (status == "ACCEPTED" || status == "APPROVED") {
      return const Color(0xffDCFCE7);
    } else if (status == "REJECTED") {
      return const Color(0xffFEE2E2);
    }
    return const Color(0xffFEF3C7);
  }

  Color _getStatusTextColor(String status) {
    if (status == "ACCEPTED" || status == "APPROVED") {
      return const Color(0xff16A34A);
    } else if (status == "REJECTED") {
      return const Color(0xffDC2626);
    }
    return const Color(0xffD97706);
  }

  String _formatFullDate(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return "-";
    try {
      DateTime dt = DateTime.parse(dateStr.toString());
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
          Icon(Icons.search_off_rounded, size: 40, color: slateSub),
          SizedBox(height: 10),
          Text(
            "No matching requests found",
            style: TextStyle(
                color: slateSub, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}