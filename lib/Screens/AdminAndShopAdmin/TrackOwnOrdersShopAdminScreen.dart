import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../constants/static.dart';
import '../../models/FetchShopModel.dart';
import '../../models/TrackOwnOrdersByShopAdminModel.dart';
import '../../provider/provider.dart';
import '../../widgets/CustomDropDownSearch.dart';
import '../../widgets/TextInputField.dart';
import '../LoginUserDetails.dart';


class TrackOwnOrdersShopAdminScreen extends ConsumerStatefulWidget {
  const TrackOwnOrdersShopAdminScreen({super.key});

  @override
  ConsumerState<TrackOwnOrdersShopAdminScreen> createState() => _TrackOwnOrdersShopAdminScreenState();
}

class _TrackOwnOrdersShopAdminScreenState extends ConsumerState<TrackOwnOrdersShopAdminScreen> {
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
        await ref.read(master_Provider).trackOrderStatusShopAdminSendToSupplier();
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
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      return dateStr;
    }
  }




  @override
  Widget build(BuildContext context) {
    final orderProv = ref.watch(master_Provider);
    final shops = ref.watch(master_Provider).allShops ?? [];
    final rawOrders = orderProv.ownOrdersShopAdmin ?? [];
    bool isMobile = MediaQuery.of(context).size.width < 600;

    // --- APPLY FILTERS ---
    final filteredOrders = rawOrders.where((order) {
      final status = (order.orderStatus ?? "PENDING").toString().toUpperCase();
      final orderId = (order.orderId ?? "").toString().toLowerCase();
      final shopName = (order.shopName ?? "").toString().toLowerCase();
      final supplierName = (order.supplierName ?? "").toString().toLowerCase();
      final query = searchQuery.toLowerCase();

      bool matchesTab = (selectedTab == "ALL") || (status == selectedTab);
      bool matchesSearch = orderId.contains(query) || shopName.contains(query) ||
          supplierName.contains(query) || (order.items?.any((item) => (item.sweetName ?? "").toString().toLowerCase().contains(query)) ?? false);
      return matchesTab && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF1F5F9),
      body: orderProv.loading ? buildShimmerEffectCard(context: context)
          : LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          int crossAxisCount = width >= 1024 ? 3 : (width >= 650 ? 2 : 1);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER WITH TITLE, SUBTITLE, FILTERS & SEARCH ---
                _buildHeaderWithSearch(isMobile, shops, rawOrders),
                const SizedBox(height: 20),

                // --- GRID VIEW CARDS ---
                Expanded(
                  child: filteredOrders.isEmpty
                      ? _buildEmptyState()
                      : ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 345,
                      ),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return OrderCard(
                          order: order,
                          formattedDate: formatDate(order.orderDate.toString()),
                          onTap: () => _showOrderDetailsDialog(context, order),
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

  Widget _buildHeaderWithSearch(bool isMobile, List<FetchShopModel> shops, List<dynamic> rawOrders) {
    // Title & Subtitle Section
    Widget headerTitleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text(
          "Order Tracking History",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xff1A2B4C),
          ),
        ),
        SizedBox(height: 4),
        Text(
          "View and manage supplier orders.",
          style: TextStyle(
            fontSize: 12,
            color: Color(0xff64748B),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );

    // Search Bar
    Widget searchBar = SizedBox(
      width: isMobile ? double.infinity : 250,
      height: 38,
      child: CustomTextInput(
        hintText: "Search ID, shop, item...",
        controller: _searchController,
        maxLines: 1,
        keyboardType: TextInputType.text,
        onChanged: (val) => setState(() => searchQuery = val),
        prefixicon: const Icon(Icons.search, size: 16, color: Colors.grey),
        suffixicon: searchQuery.isNotEmpty
            ? InkWell(
          onTap: () {
            _searchController.clear();
            setState(() => searchQuery = "");
          },
          child: const Icon(Icons.clear, size: 14, color: Colors.grey),
        )
            : null,
      ),
    );

    // Mobile Layout
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitleSection,
          const SizedBox(height: 14),
          if (LoginUserDetails.isAdmin) ...[
            _dropdownBoxFoShop(shops, double.infinity),
            const SizedBox(height: 10),
          ],
          _buildOrderFilterDropdown(rawOrders, double.infinity),
          const SizedBox(height: 10),
          searchBar,
        ],
      );
    }

    // Desktop/Tablet Layout (Single Line Bar)
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        headerTitleSection,
        Row(
          children: [
            if (LoginUserDetails.isAdmin) ...[
              _dropdownBoxFoShop(shops, 180),
              const SizedBox(width: 10),
            ],
            _buildOrderFilterDropdown(rawOrders, 180),
            const SizedBox(width: 10),
            searchBar,
          ],
        ),
      ],
    );
  }


  Widget _buildOrderFilterDropdown(List<dynamic> allOrders, double dropdownWidth) {
    int getCount(String tabStatus) {
      if (tabStatus == "ALL") return allOrders.length;
      return allOrders.where((o) {
        return (o.orderStatus ?? "PENDING").toString().toUpperCase() == tabStatus;
      }).length;
    }

    final filterItems = [
      {'key': 'ALL', 'label': 'All Orders'},
      {'key': 'PENDING', 'label': 'Pending'},
      {'key': 'ACCEPTED', 'label': 'Accepted'},
      {'key': 'DISPATCHED', 'label': 'Dispatched'},
    ];

    return SizedBox(
      width: dropdownWidth,
      height: 38,
      child: CustomDropdownSearch<Map<String, String>>(
        items: filterItems,
        showSearchBox: false,
        itemLabelBuilder: (item) {
          int count = getCount(item['key']!);
          return "${item['label']}";
        },
        compareFn: (a, b) => a['key'] == b['key'],
        selectedItem: filterItems.firstWhere(
              (item) => item['key'] == selectedTab,
          orElse: () => filterItems.first,
        ),
        onChanged: (val) {
          if (val != null) {
            setState(() {
              selectedTab = val['key']!;
            });
          }
        },
        hintText: "Select Status",
      ),
    );
  }


  Widget _dropdownBoxFoShop(List<FetchShopModel> shop, double width) {
    FetchShopModel? currentSelected;
    if (shop_id != null && shop.any((s) => s.row_id.toString() == shop_id)) {
      currentSelected = shop.firstWhere((d) => d.row_id.toString() == shop_id);
    }

    return Container(
      width: width,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<FetchShopModel>(
          value: currentSelected,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 25, color: Colors.black87),
          dropdownColor: Colors.white,
          hint: const Text("Filter by Shop",
              style: const TextStyle(
                fontSize: 12.8,
                letterSpacing: 0.9,
                color: Colors.black87,
              )),
          items: shop.map((FetchShopModel item) {
            return DropdownMenuItem<FetchShopModel>(
              value: item,
              child: Text(
                item.shop_name ?? "-",
                style: const TextStyle(fontSize: 13, color: Colors.black87),
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
          Icon(Icons.inventory_2_outlined,
              size: 50, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text("No orders found",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // --- PREMIUM DIALOG BOX ---
  void _showOrderDetailsDialog(BuildContext context, TrackOwnOrdersByShopAdminModel order) {
    String status = (order.orderStatus ?? "PENDING").toUpperCase();
    int activeStep = status == "DISPATCHED" ? 2 : (status == "ACCEPTED" ? 1 : 0);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        double screenWidth = MediaQuery.of(context).size.width;
        bool isMobile = screenWidth < 600;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(isMobile ? 12 : 24),
          child: Container(
            width: isMobile ? double.infinity : 540,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff0F172A).withOpacity(0.18),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- 1. MODERN HERO HEADER ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff0F172A), Color(0xff1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "ORDER DETAILS",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xff94A3B8),
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SelectableText(
                                "${order.orderId.toString().split('_').last}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded,
                                  color: Colors.white70, size: 18),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),

                      // --- STEPPER INSIDE HERO ---
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(
                          children: [
                            _buildDarkStepNode("Pending", 0, activeStep >= 0),
                            _buildDarkStepLine(activeStep >= 1),
                            _buildDarkStepNode("Accepted", 1, activeStep >= 1),
                            _buildDarkStepLine(activeStep >= 2),
                            _buildDarkStepNode("Dispatched", 2, activeStep >= 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // --- 2. SCROLLABLE BODY CONTENT ---
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ROUTE CARD
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
                                    Row(
                                      children: const [
                                        Icon(Icons.storefront_rounded,
                                            size: 12, color: Colors.blueGrey),
                                        SizedBox(width: 4),
                                        Text("SHOP",style: TextStyle(
                                                fontSize: 8.5,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.blueGrey)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      order.shopName ?? "-",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xff0F172A)),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color(0x0A000000), blurRadius: 4)
                                  ],
                                ),
                                child: const Icon(Icons.east_rounded,
                                    color: Color(0xff0284C7), size: 14),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: const [
                                        Text("SUPPLIER",
                                            style: TextStyle(
                                                fontSize: 8.5,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.blueGrey)),
                                        SizedBox(width: 4),
                                        Icon(Icons.local_shipping_outlined,
                                            size: 12, color: Colors.blueGrey),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      order.supplierName ?? "-",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xff0F172A)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // MANIFEST HEADER & COUNTER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "ORDER ITEMS",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff334155),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xff0284C7).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${order.items?.length ?? 0} ITEMS TOTAL",
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xff0284C7),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),

                        // HIGH-CAPACITY SCROLLABLE ITEM TABLE (Supports 100+ items smoothly)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 260),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xffE2E8F0)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Sticky Table Header
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                  color: const Color(0xffF1F5F9),
                                  child: Row(
                                    children: const [
                                      SizedBox(width: 30,
                                          child: Text("SR.",style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,color: Colors.blueGrey))),
                                      Expanded(
                                          child: Text("ITEM NAME",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blueGrey))),
                                      Text("QUANTITY",
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueGrey)),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1, color: Color(0xffE2E8F0)),

                                // Scrollable Item List Body
// Scrollable Item List Body
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                // Create a local ScrollController for the Scrollbar
                                final ScrollController itemScrollController = ScrollController();

                                return Scrollbar(
                                  controller: itemScrollController, // 1. Controller here
                                  thumbVisibility: true,
                                  child: ListView.builder(
                                    controller: itemScrollController, // 2. Same controller here
                                    shrinkWrap: true,
                                    itemCount: order.items?.length ?? 0,
                                    itemBuilder: (context, idx) {
                                      final item = order.items![idx];
                                      bool isEven = idx % 2 == 0;

                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        color: isEven ? Colors.white : const Color(0xffF8FAFC),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 30,
                                              child: Text(
                                                "${idx + 1}",
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                item.sweetName ?? "-",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xff0F172A),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: const Color(0xffE2E8F0)),
                                              ),
                                              child: Text(
                                                "${item.quantity ?? 0} ${item.unit ?? ''}",
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff0284C7),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- 3. FIXED FOOTER BAR ---
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded,
                              size: 13, color: Colors.blueGrey),
                          const SizedBox(width: 5),
                          Text(
                            formatDate(order.orderDate.toString()),
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 34,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0F172A),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Dismiss",
                              style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
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

// Stepper Components (Hero Header Dark Theme Compatible)
  Widget _buildDarkStepNode(String label, int index, bool isActive) {
    return Row(
      children: [
        CircleAvatar(
          radius: 9,
          backgroundColor:
          isActive ? const Color(0xff10B981) : Colors.white.withOpacity(0.2),
          child: isActive
              ? const Icon(Icons.check, size: 11, color: Colors.white)
              : Text("${index + 1}",
              style: const TextStyle(
                  fontSize: 8.5,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? Colors.white : Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildDarkStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color:
        isActive ? const Color(0xff10B981) : Colors.white.withOpacity(0.15),
      ),
    );
  }

}

// --- ORIGINAL ORDER CARD WITH CLICK SUPPORT ---
class OrderCard extends StatefulWidget {
  final TrackOwnOrdersByShopAdminModel order;
  final String formattedDate;
  final VoidCallback onTap;
  const OrderCard({super.key, required this.order, required this.formattedDate,required this.onTap});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool isHovered = false;
  final ScrollController _itemScrollController = ScrollController();

  @override
  void dispose() {
    _itemScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isHovered ? const Color(0xffF57C00).withOpacity(0.3) : const Color(0xffE2E8F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("ORDER ID",style: TextStyle(fontSize: 8,fontWeight: FontWeight.bold,color: Colors.black54)),
                            Text("${widget.order.orderId.toString().split('_').last}",
                                style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Color(0xff1A2B4C))),
                          ],
                        ),
                        _buildStatusBadge(widget.order.orderStatus.toString()),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1,thickness: 0.1,color: Colors.black54),
                    ),
                    Row(
                      children: [
                        _routeIcon(Icons.store_outlined),
                        const SizedBox(width: 8),
                        Expanded(child:_routeDetails(widget.order.shopName ?? "-")),
                        const Icon(Icons.chevron_right,size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(child: _routeDetails(widget.order.supplierName ?? "-",alignRight: true)),
                        const SizedBox(width: 8),
                        _routeIcon(Icons.local_shipping_outlined),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xffF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xffEDF2F7)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.list_alt_rounded,size: 13, color: Colors.grey.shade500),
                              const SizedBox(width: 6),
                              const Text(
                                "ORDER ITEMS",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff334155),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xff1A2B4C)
                                          .withOpacity(0.12),
                                      const Color(0xff1A2B4C)
                                          .withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xff1A2B4C)
                                        .withOpacity(0.1),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                          color: Color(0xff1A2B4C),
                                          shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "${widget.order.items?.length ?? 0} ITEMS",
                                      style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xff1A2B4C),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 4),
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xffF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Scrollbar(
                              controller: _itemScrollController,
                              thumbVisibility: true,
                              thickness: 2,
                              scrollbarOrientation:
                              ScrollbarOrientation.right,
                              child: Theme(
                                data: ThemeData(
                                  scrollbarTheme: ScrollbarThemeData(
                                    thumbColor: WidgetStateProperty.all(
                                      const Color(0xff1A2B4C)
                                          .withOpacity(0.15),
                                    ),
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  controller: _itemScrollController,
                                  child: Column(
                                    children: List.generate(
                                        widget.order.items?.length ?? 0,
                                            (index) {
                                          final item =
                                          widget.order.items![index];
                                          return Column(
                                            children: [
                                              Padding(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                    horizontal: 4),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 18,
                                                      height: 18,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xff1A2B4C)
                                                            .withOpacity(0.1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          "${index + 1}",
                                                          style: const TextStyle(
                                                              fontSize: 9,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                              color: Color(
                                                                  0xff1A2B4C)),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Text(
                                                        item.sweetName ?? "-",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                            FontWeight.w600,
                                                            color: Color(
                                                                0xff475569)),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin:
                                                      const EdgeInsets.only(
                                                          right: 10),
                                                      padding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(4),
                                                        border: Border.all(
                                                            color: const Color(
                                                                0xffE2E8F0)),
                                                      ),
                                                      child: Text(
                                                        "${item.quantity} ${item.unit}",
                                                        style: const TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                            FontWeight.w800,
                                                            color: Color(
                                                                0xff1A2B4C)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (index !=
                                                  (widget.order.items!.length -
                                                      1))
                                                Divider(
                                                    height: 1,
                                                    thickness: 0.5,
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    indent: 30),
                                            ],
                                          );
                                        }),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(widget.formattedDate,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey)),
                          ],
                        ),
                      ],
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

  Widget _routeIcon(IconData icon) {
    return Icon(icon, size: 16, color: const Color(0xff94A3B8));
  }

  Widget _routeDetails(String value, {bool alignRight = false}) {
    return Column(
      crossAxisAlignment:
      alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xff1A2B4C)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isDispatched = status.toUpperCase() == "DISPATCHED";
    Color color = isDispatched ? Colors.green : Colors.orange;
    if (status.toUpperCase() == "ACCEPTED") color = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(status.toUpperCase(),
          style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }
}