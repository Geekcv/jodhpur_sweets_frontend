import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../constants/static.dart';
import '../../controllers/api_controller.dart';
import '../../models/FetchShopModel.dart';
import '../../models/TrackOwnOrdersByShopAdminModel.dart';
import '../../provider/provider.dart';
import '../../widgets/CustomDropDownSearch.dart';
import '../../widgets/TextInputField.dart';
import '../LoginUserDetails.dart';

class TrackOwnOrdersShopAdminScreen extends ConsumerStatefulWidget {
  const TrackOwnOrdersShopAdminScreen({super.key});

  @override
  ConsumerState<TrackOwnOrdersShopAdminScreen> createState() =>
      _TrackOwnOrdersShopAdminScreenState();
}

class _TrackOwnOrdersShopAdminScreenState
    extends ConsumerState<TrackOwnOrdersShopAdminScreen> {
  String? shop_id;
  String selectedTab = "ALL";
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        if (LoginUserDetails.isAdmin) {
          await ref.read(master_Provider).fetchShop();
        }
        await ref
            .read(master_Provider)
            .trackOrderStatusShopAdminSendToSupplier();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy • hh:mm a').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  // --- HELPER TO GET ELIGIBLE ACTIONABLE ITEMS ---
  List<OrderItem> _getActionableItems(TrackOwnOrdersByShopAdminModel order) {
    if (order.items == null) return [];
    return order.items!.where((item) {
      String itemStat = (item.itemStatus ?? "PENDING").toString().toUpperCase();
      bool isPartialOrRejected =
          itemStat == "PARTIAL" || itemStat == "REJECTED";
      bool hasRemaining =
          item.remainingQuantity != null && item.remainingQuantity! > 0;
      bool isPendingAction = (item.remainingAction ?? "PENDING") == "PENDING";
      return isPartialOrRejected && hasRemaining && isPendingAction;
    }).toList();
  }

  // --- DIALOG FOR BULK REORDER / CANCEL WITH CHECKBOXES ---
  Future<void> _showBulkActionDialog({
    required TrackOwnOrdersByShopAdminModel order,
    required bool isReorder,
  }) async {
    final eligibleItems = _getActionableItems(order);
    if (eligibleItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No items available for this action."),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    Set<String> selectedItemIds =
    eligibleItems.map((e) => e.orderItemId.toString()).toSet();
    String dialogSearchQuery = "";

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            double screenWidth = MediaQuery.of(context).size.width;
            bool isMobile = screenWidth < 600;

            final visibleItems = eligibleItems.where((item) {
              final name = (item.sweetName ?? "").toLowerCase();
              return name.contains(dialogSearchQuery.toLowerCase());
            }).toList();

            bool isAllSelected = selectedItemIds.length == eligibleItems.length;

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              insetPadding: EdgeInsets.all(isMobile ? 12 : 24),
              child: Container(
                width: isMobile ? double.infinity : 600,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // DIALOG HEADER
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            bottom: BorderSide(color: Color(0xffE2E8F0))),
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isReorder
                                      ? const Color(0xffE0F2FE)
                                      : const Color(0xffFEE2E2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isReorder
                                      ? Icons.autorenew_rounded
                                      : Icons.cancel_outlined,
                                  color: isReorder
                                      ? const Color(0xff0284C7)
                                      : Colors.redAccent,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isReorder
                                        ? "Select Items to Reorder"
                                        : "Select Items to Cancel",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff0F172A),
                                    ),
                                  ),
                                  Text(
                                    "Order ID: #${order.orderId.toString().split('_').last}",
                                    style: const TextStyle(
                                        fontSize: 11, color: Color(0xff64748B)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close,
                                color: Color(0xff64748B)),
                          ),
                        ],
                      ),
                    ),

                    // SEARCH & SELECT ALL BAR
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Column(
                        children: [
                          if (eligibleItems.length > 5) ...[
                            SizedBox(
                              height: 38,
                              child: TextField(
                                onChanged: (val) => setDialogState(
                                        () => dialogSearchQuery = val),
                                decoration: InputDecoration(
                                  hintText: "Search item name...",
                                  hintStyle: const TextStyle(
                                      fontSize: 12, color: Color(0xff94A3B8)),
                                  prefixIcon: const Icon(Icons.search,
                                      size: 16, color: Color(0xff64748B)),
                                  contentPadding:
                                  const EdgeInsets.symmetric(vertical: 0),
                                  filled: true,
                                  fillColor: const Color(0xffF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xffE2E8F0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xffE2E8F0)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  setDialogState(() {
                                    if (isAllSelected) {
                                      selectedItemIds.clear();
                                    } else {
                                      selectedItemIds = eligibleItems
                                          .map((e) => e.orderItemId.toString())
                                          .toSet();
                                    }
                                  });
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: isAllSelected,
                                      activeColor: isReorder
                                          ? const Color(0xff0284C7)
                                          : Colors.redAccent,
                                      onChanged: (val) {
                                        setDialogState(() {
                                          if (val == true) {
                                            selectedItemIds = eligibleItems
                                                .map((e) =>
                                                e.orderItemId.toString())
                                                .toSet();
                                          } else {
                                            selectedItemIds.clear();
                                          }
                                        });
                                      },
                                    ),
                                    const Text(
                                      "Select All Items",
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xff334155)),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "${selectedItemIds.length} / ${eligibleItems.length} Selected",
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff0284C7)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, color: Color(0xffE2E8F0)),

                    // ITEM CHECKBOX LIST (OPTIMIZED FOR 100+ ITEMS)
                    Expanded(
                      child: visibleItems.isEmpty
                          ? const Center(
                        child: Text("No matching items found",
                            style: TextStyle(
                                color: Color(0xff94A3B8), fontSize: 13)),
                      )
                          : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: visibleItems.length,
                        separatorBuilder: (_, __) => const Divider(
                            height: 1, color: Color(0xffF1F5F9)),
                        itemBuilder: (context, idx) {
                          final item = visibleItems[idx];
                          final itemId = item.orderItemId.toString();
                          final isChecked =
                          selectedItemIds.contains(itemId);

                          String itemStat =
                          (item.itemStatus ?? "PENDING")
                              .toString()
                              .toUpperCase();

                          return CheckboxListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            activeColor: isReorder
                                ? const Color(0xff0284C7)
                                : Colors.redAccent,
                            value: isChecked,
                            onChanged: (val) {
                              setDialogState(() {
                                if (val == true) {
                                  selectedItemIds.add(itemId);
                                } else {
                                  selectedItemIds.remove(itemId);
                                }
                              });
                            },
                            title: Text(
                              item.sweetName ?? "-",
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff0F172A),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                "Ordered: ${item.quantity} ${item.unit} | Remaining: ${item.remainingQuantity ?? item.quantity} ${item.unit}",
                                style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xff64748B)),
                              ),
                            ),
                            secondary: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (itemStat == "REJECTED"
                                    ? Colors.red
                                    : Colors.amber.shade800)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                itemStat,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: itemStat == "REJECTED"
                                      ? Colors.redAccent
                                      : Colors.amber.shade900,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // DIALOG FOOTER
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xffF8FAFC),
                        border:
                        Border(top: BorderSide(color: Color(0xffE2E8F0))),
                        borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xffCBD5E1)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel",
                                style: TextStyle(color: Color(0xff64748B))),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isReorder
                                  ? const Color(0xff0284C7)
                                  : Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            onPressed: selectedItemIds.isEmpty
                                ? null
                                : () {
                              Navigator.pop(context);
                              if (isReorder) {
                                _submitBulkReorder(
                                    order, selectedItemIds.toList());
                              } else {
                                _submitBulkCancel(
                                    order, selectedItemIds.toList());
                              }
                            },
                            child: Text(
                              isReorder
                                  ? "Submit Reorder (${selectedItemIds.length})"
                                  : "Submit Cancel (${selectedItemIds.length})",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- API CALL FOR BULK REORDER ---
  Future<void> _submitBulkReorder(
      TrackOwnOrdersByShopAdminModel order, List<String> itemIds) async {
    var params = {
      "order_id": order.orderId.toString(),
      "items": itemIds.map((id) => {"order_item_id": id}).toList()
    };

    try {
      var res = await ApiController.reorderByShopAdmin(
          context: context, params: params);
      if (res != null && (res['status'] == 0 || res['status'] == "0")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  res['msg'] ?? "Reorder request submitted successfully")),
        );
        ref
            .read(master_Provider)
            .trackOrderStatusShopAdminSendToSupplier(
            params: shop_id != null ? {'shop_id': shop_id} : null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(res['msg'] ?? "Failed to reorder items"),
              backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error processing reorder: $e"),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  // --- API CALL FOR BULK CANCEL ---
  Future<void> _submitBulkCancel(
      TrackOwnOrdersByShopAdminModel order, List<String> itemIds) async {
    String finalOrderId = (order.parentOrderId != null &&
        order.parentOrderId.toString().isNotEmpty &&
        order.parentOrderId.toString() != "null")
        ? order.parentOrderId.toString()
        : order.orderId.toString();

    var params = {
      "order_id": finalOrderId,
      "items": itemIds.map((id) => {"order_item_id": id}).toList()
    };

    try {
      var res = await ApiController.cancelOrderByShopAdmin(
          context: context, params: params);
      if (res != null && (res['status'] == 0 || res['status'] == "0")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text(res['msg'] ?? "Selected items cancelled successfully")),
        );
        ref
            .read(master_Provider)
            .trackOrderStatusShopAdminSendToSupplier(
            params: shop_id != null ? {'shop_id': shop_id} : null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(res['msg'] ?? "Failed to cancel items"),
              backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error cancelling items: $e"),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = ref.watch(master_Provider);
    final shops = ref.watch(master_Provider).allShops ?? [];
    final rawOrders = orderProv.ownOrdersShopAdmin ?? [];
    bool isMobile = MediaQuery.of(context).size.width < 768;

    final filteredOrders = rawOrders.where((order) {
      final status = (order.orderStatus ?? "PENDING").toString().toUpperCase();
      final orderId = (order.orderId ?? "").toString().toLowerCase();
      final shopName = (order.shopName ?? "").toString().toLowerCase();
      final supplierName = (order.supplierName ?? "").toString().toLowerCase();
      final query = searchQuery.toLowerCase();

      bool matchesTab = (selectedTab == "ALL") || (status == selectedTab);
      bool matchesSearch = orderId.contains(query) ||
          shopName.contains(query) ||
          supplierName.contains(query) ||
          (order.items?.any((item) => (item.sweetName ?? "")
              .toString()
              .toLowerCase()
              .contains(query)) ??
              false);
      return matchesTab && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: orderProv.loading
          ? buildShimmerEffectCard(context: context)
          : LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          int crossAxisCount = width >= 1200 ? 3 : (width >= 750 ? 2 : 1);

          return Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderWithSearch(isMobile, shops, rawOrders),
                const SizedBox(height: 20),
                Expanded(
                  child: filteredOrders.isEmpty
                      ? _buildEmptyState()
                      : ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        mainAxisExtent: 440,
                      ),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        final actionableItems =
                        _getActionableItems(order);

                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _showOrderDetailsDialog(
                              context, order),
                          child: ModernOrderCard(
                            order: order,
                            actionableItemsCount:
                            actionableItems.length,
                            formattedDate:
                            formatDate(order.orderDate.toString()),
                            onTap: () => _showOrderDetailsDialog(
                                context, order),
                            onReorderAll: () => _showBulkActionDialog(
                                order: order, isReorder: true),
                            onCancelAll: () => _showBulkActionDialog(
                                order: order, isReorder: false),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderWithSearch(
      bool isMobile, List<FetchShopModel> shops, List<dynamic> rawOrders) {
    Widget titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Orders Tracking History",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xff0F172A),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Monitor order updates, bulk reorder pending quantities and manage fulfillments.",
          style: TextStyle(
            fontSize: 12.5,
            color: Color(0xff64748B),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );

    Widget searchBar = SizedBox(
      width: isMobile ? double.infinity : 240,
      height: 40,
      child: CustomTextInput(
        hintText: "Search order, item, shop...",
        controller: _searchController,
        maxLines: 1,
        keyboardType: TextInputType.text,
        onChanged: (val) => setState(() => searchQuery = val),
        prefixicon:
        const Icon(Icons.search_rounded, size: 18, color: Color(0xff64748B)),
        suffixicon: searchQuery.isNotEmpty
            ? InkWell(
          onTap: () {
            _searchController.clear();
            setState(() => searchQuery = "");
          },
          child: const Icon(Icons.cancel_rounded,
              size: 16, color: Color(0xff94A3B8)),
        )
            : null,
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleSection,
          const SizedBox(height: 16),
          if (LoginUserDetails.isAdmin) ...[
            _dropdownBoxForShop(shops, double.infinity),
            const SizedBox(height: 10),
          ],
          _buildOrderFilterDropdown(rawOrders, double.infinity),
          const SizedBox(height: 10),
          searchBar,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        titleSection,
        Row(
          children: [
            if (LoginUserDetails.isAdmin) ...[
              _dropdownBoxForShop(shops, 180),
              const SizedBox(width: 10),
            ],
            _buildOrderFilterDropdown(rawOrders, 170),
            const SizedBox(width: 10),
            searchBar,
          ],
        ),
      ],
    );
  }

  Widget _buildOrderFilterDropdown(
      List<dynamic> allOrders, double dropdownWidth) {
    final filterItems = [
      {'key': 'ALL', 'label': 'All Statuses'},
      {'key': 'PENDING', 'label': 'Pending'},
      {'key': 'ACCEPTED', 'label': 'Accepted'},
      {'key': 'DISPATCHED', 'label': 'Dispatched'},
    ];

    return SizedBox(
      width: dropdownWidth,
      height: 40,
      child: CustomDropdownSearch<Map<String, String>>(
        items: filterItems,
        showSearchBox: false,
        itemLabelBuilder: (item) => "${item['label']}",
        compareFn: (a, b) => a['key'] == b['key'],
        selectedItem: filterItems.firstWhere(
              (item) => item['key'] == selectedTab,
          orElse: () => filterItems.first,
        ),
        onChanged: (val) {
          if (val != null) setState(() => selectedTab = val['key']!);
        },
        hintText: "Select Status",
      ),
    );
  }

  Widget _dropdownBoxForShop(List<FetchShopModel> shop, double width) {
    FetchShopModel? currentSelected;
    if (shop_id != null && shop.any((s) => s.row_id.toString() == shop_id)) {
      currentSelected = shop.firstWhere((d) => d.row_id.toString() == shop_id);
    }

    return Container(
      width: width,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffCBD5E1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<FetchShopModel>(
          value: currentSelected,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              size: 20, color: Color(0xff64748B)),
          dropdownColor: Colors.white,
          hint: const Text("Select Shop",
              style: TextStyle(fontSize: 13, color: Color(0xff64748B))),
          items: shop.map((FetchShopModel item) {
            return DropdownMenuItem<FetchShopModel>(
              value: item,
              child: Text(
                item.shop_name ?? "-",
                style: const TextStyle(fontSize: 13, color: Color(0xff0F172A)),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (FetchShopModel? val) {
            if (val?.row_id.toString() == shop_id) return;
            setState(() => shop_id = val?.row_id.toString());
            if (shop_id != null) {
              ref
                  .read(master_Provider)
                  .trackOrderStatusShopAdminSendToSupplier(
                params: {'shop_id': shop_id},
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xffE2E8F0).withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_rounded,
                size: 48, color: Color(0xff94A3B8)),
          ),
          const SizedBox(height: 16),
          const Text("No Orders Found",
              style: TextStyle(
                  color: Color(0xff334155),
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text("Try adjusting search terms or status filters.",
              style: TextStyle(color: Color(0xff94A3B8), fontSize: 13)),
        ],
      ),
    );
  }

  // --- CLEAN WHITE MODERN ORDER DETAILS DIALOG ---
  void _showOrderDetailsDialog(
      BuildContext context, TrackOwnOrdersByShopAdminModel order) {
    String status = (order.orderStatus ?? "PENDING").toUpperCase();
    int activeStep =
    status == "DISPATCHED" ? 2 : (status == "ACCEPTED" ? 1 : 0);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        double screenWidth = MediaQuery.of(context).size.width;
        bool isMobile = screenWidth < 600;

        return Dialog(
          backgroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: EdgeInsets.all(isMobile ? 12 : 24),
          child: Container(
            width: isMobile ? double.infinity : 650,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // HEADER
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Color(0xffE2E8F0))),
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "ORDER #${order.orderId.toString().split('_').last}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'monospace',
                                      color: Color(0xff0F172A),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _pillBadge(
                                      order.orderType?.toString() ?? "NORMAL",
                                      Colors.purple),
                                  const SizedBox(width: 4),
                                  _pillBadge(
                                      order.resolutionStatus?.toString() ??
                                          "OPEN",
                                      (order.resolutionStatus?.toString() ==
                                          "RESOLVED")
                                          ? Colors.green
                                          : Colors.amber.shade900),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatDate(order.orderDate.toString()),
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xff64748B)),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close,
                                color: Color(0xff64748B)),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      // TRACKING STEPPER
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xffF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xffE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            _buildLightStepNode("Pending", 0, activeStep >= 0),
                            _buildLightStepLine(activeStep >= 1),
                            _buildLightStepNode("Accepted", 1, activeStep >= 1),
                            _buildLightStepLine(activeStep >= 2),
                            _buildLightStepNode(
                                "Dispatched", 2, activeStep >= 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // BODY CONTENT
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ROUTING INFO
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xffF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xffE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("FROM SHOP",
                                        style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xff64748B))),
                                    const SizedBox(height: 4),
                                    Text(
                                      order.shopName ?? "-",
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xff0F172A)),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_rounded,
                                  color: Color(0xff0284C7), size: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text("TO SUPPLIER",
                                        style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xff64748B))),
                                    const SizedBox(height: 4),
                                    Text(
                                      order.supplierName ?? "-",
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xff0F172A)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("ORDER ITEMS",
                                style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xff334155))),
                            Text("${order.items?.length ?? 0} Items Total",
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff0284C7))),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // ITEM DETAILS TABLE
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xffE2E8F0)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: order.items?.length ?? 0,
                              separatorBuilder: (_, __) => const Divider(
                                  height: 1, color: Color(0xffE2E8F0)),
                              itemBuilder: (context, idx) {
                                final item = order.items![idx];
                                String itemStat =
                                (item.itemStatus ?? "PENDING")
                                    .toString()
                                    .toUpperCase();

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Text("${idx + 1}.",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff94A3B8))),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(item.sweetName ?? "-",
                                                style: const TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xff0F172A))),
                                            const SizedBox(height: 2),
                                            Text(
                                              "Ordered: ${item.quantity} ${item.unit} | Supplied: ${item.suppliedQuantity ?? 0} | Remaining: ${item.remainingQuantity ?? 0}",
                                              style: const TextStyle(
                                                  fontSize: 11.5,
                                                  color: Color(0xff64748B)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      _buildItemStatusBadge(itemStat),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // FOOTER
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xffF8FAFC),
                    border: Border(top: BorderSide(color: Color(0xffE2E8F0))),
                    borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff0F172A),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pillBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25), width: 0.5),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
            fontSize: 8.5, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }

  Widget _buildItemStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == "ACCEPTED") color = const Color(0xFF10B981);
    if (status == "PARTIAL") color = Colors.amber.shade800;
    if (status == "REJECTED") color = Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildLightStepNode(String label, int index, bool isActive) {
    return Row(
      children: [
        CircleAvatar(
          radius: 9,
          backgroundColor: isActive
              ? const Color(0xff10B981)
              : const Color(0xffCBD5E1),
          child: isActive
              ? const Icon(Icons.check, size: 10, color: Colors.white)
              : Text("${index + 1}",
              style: const TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? const Color(0xff0F172A) : const Color(0xff64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildLightStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isActive ? const Color(0xff10B981) : const Color(0xffE2E8F0),
      ),
    );
  }
}

// --- REDESIGNED MODERN CARD COMPONENT WITH CARD-LEVEL BUTTONS ---
class ModernOrderCard extends StatefulWidget {
  final TrackOwnOrdersByShopAdminModel order;
  final int actionableItemsCount;
  final String formattedDate;
  final VoidCallback onTap;
  final VoidCallback onReorderAll;
  final VoidCallback onCancelAll;

  const ModernOrderCard({
    super.key,
    required this.order,
    required this.actionableItemsCount,
    required this.formattedDate,
    required this.onTap,
    required this.onReorderAll,
    required this.onCancelAll,
  });

  @override
  State<ModernOrderCard> createState() => _ModernOrderCardState();
}

class _ModernOrderCardState extends State<ModernOrderCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    String orderStatus = (widget.order.orderStatus ?? "PENDING").toUpperCase();
    bool hasActionableItems = widget.actionableItemsCount > 0;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHovered
                ? const Color(0xff0284C7)
                : const Color(0xffE2E8F0),
            width: isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? const Color(0x140284C7)
                  : const Color(0x06000000),
              blurRadius: isHovered ? 18 : 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CARD HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("ORDER ID",
                          style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xff94A3B8))),
                      const SizedBox(height: 2),
                      Text(
                        "#${widget.order.orderId.toString().split('_').last}",
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                            color: Color(0xff0F172A)),
                      ),
                    ],
                  ),
                  _buildMainStatusBadge(orderStatus),
                ],
              ),
              const SizedBox(height: 8),

              // METADATA BADGES
              Row(
                children: [
                  _pillBadge(widget.order.orderType?.toString() ?? "NORMAL",
                      Colors.purple),
                  const SizedBox(width: 6),
                  _pillBadge(
                      widget.order.resolutionStatus?.toString() ?? "OPEN",
                      (widget.order.resolutionStatus?.toString() == "RESOLVED")
                          ? Colors.green
                          : Colors.amber.shade900),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: Color(0xffF1F5F9)),
              ),

              // ROUTING DETAILS (SHOP TO SUPPLIER)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("SHOP",
                            style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xff94A3B8))),
                        const SizedBox(height: 2),
                        Text(
                          widget.order.shopName ?? "-",
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff334155)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.east_rounded,
                        size: 14, color: Color(0xffCBD5E1)),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("SUPPLIER",
                            style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xff94A3B8))),
                        const SizedBox(height: 2),
                        Text(
                          widget.order.supplierName ?? "-",
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff334155)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ITEMS LIST SUMMARY (WITH SEPARATORS & HIGH CONTRAST)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xffF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xffE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("ITEMS SUMMARY",
                              style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xff64748B))),
                          Text("${widget.order.items?.length ?? 0} Total",
                              style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff0284C7))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: widget.order.items?.length ?? 0,
                          separatorBuilder: (_, __) => const Divider(
                            height: 12,
                            thickness: 0.8,
                            color: Color(0xffE2E8F0),
                          ),
                          itemBuilder: (context, idx) {
                            final item = widget.order.items![idx];
                            String itemStat = (item.itemStatus ?? "PENDING")
                                .toString()
                                .toUpperCase();
                            bool isPartialOrRejected = itemStat == "PARTIAL" ||
                                itemStat == "REJECTED";

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.sweetName ?? "-",
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xff0F172A)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        "Qty: ${item.quantity} ${item.unit}",
                                        style: const TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xff64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: (isPartialOrRejected
                                        ? Colors.amber.shade800
                                        : const Color(0xFF64748B))
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    itemStat,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isPartialOrRejected
                                          ? Colors.amber.shade900
                                          : const Color(0xff475569),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // CARD-LEVEL ACTION BUTTONS (REORDER ALL / CANCEL ALL)
              if (hasActionableItems) ...[
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: widget.onReorderAll,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xff0284C7),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A0284C7),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.autorenew_rounded,
                                  size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                "Reorder Remaining",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: widget.onCancelAll,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xffFEE2E2),
                            border: Border.all(color: const Color(0xffFECACA)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cancel_outlined,
                                  size: 14, color: Colors.redAccent),
                              SizedBox(width: 4),
                              Text(
                                "Cancel Remaining",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // FOOTER DATE & CLICK INTENT
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 13, color: Color(0xff94A3B8)),
                      const SizedBox(width: 4),
                      Text(widget.formattedDate,
                          style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff64748B))),
                    ],
                  ),
                  InkWell(
                    onTap: widget.onTap,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                      child: Text("View Details →",
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff0284C7))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _pillBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25), width: 0.5),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
            fontSize: 8.5, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }

  Widget _buildMainStatusBadge(String status) {
    Color color = Colors.amber.shade800;
    if (status == "ACCEPTED") color = const Color(0xff0284C7);
    if (status == "DISPATCHED") color = const Color(0xff10B981);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
            fontSize: 9.5, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }
}