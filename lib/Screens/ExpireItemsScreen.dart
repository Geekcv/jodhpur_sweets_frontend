import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:js_order_website/Screens/LoginUserDetails.dart';
import 'package:js_order_website/controllers/api_controller.dart';
import '../constants/static.dart';
import '../provider/provider.dart';
import '../widgets/CustomDropDownSearch.dart';

class ExpireItemsScreen extends ConsumerStatefulWidget {
  const ExpireItemsScreen({super.key});

  @override
  ConsumerState<ExpireItemsScreen> createState() => _ExpireItemsScreenState();
}

class _ExpireItemsScreenState extends ConsumerState<ExpireItemsScreen> {
  String? selectedCounterId;



  fetchNotification() async{
    await ApiController.fetchNotification();
  }


  @override
  void initState() {
    super.initState();
    fetchNotification();
    _initFlow();
  }

  void _initFlow() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. Counters fetch karein
      await ref.read(master_Provider).fetchCounter();

      final String role = LoginUserDetails.role?.toUpperCase() ?? "";
      final counters = ref.read(master_Provider).allCounters ?? [];

      if (role == 'SHOPADMIN' || role == 'SHOP_ADMIN') {
        if (counters.isNotEmpty) {
          selectedCounterId = counters.first.row_id.toString();
          // Initial data load for first counter
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

  // --- AAPKA BATAAYA HUA DROPDOWN WIDGET (Unchanged) ---
  Widget _dropdown(String label, List items, String Function(dynamic) labelBuilder, Function(dynamic) onSel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: CustomDropdownSearch<dynamic>(
            items: items,
            itemLabelBuilder: labelBuilder,
            compareFn: (a, b) => a.row_id.toString() == b.row_id.toString(),
            onChanged: (val) {
              if (val != null) {
                onSel(val);
              }
            },
            hintText: "Select",
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final masterProv = ref.watch(master_Provider);
    final counters = masterProv.allCounters ?? [];
    final expiredItems = masterProv.expireItmesData ?? []; // Dynamic Data from Provider
    final isLoading = masterProv.loading;

    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < 600;

    return Scaffold(
      backgroundColor: const Color(0xffF1F5F9),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(isMobile, counters),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffE2E8F0)),
                  ),
                  child: isLoading
                      ? buildShimmerEffect(context: context)
                      : expiredItems.isEmpty
                      ? _buildEmptyState()
                      : _buildResponsiveView(isMobile, expiredItems),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isMobile, List counters) {
    final String role = LoginUserDetails.role?.toUpperCase() ?? "";
    bool isShopAdmin = (role == 'SHOPADMIN' || role == 'SHOP_ADMIN');

    String currentCounterName = "Assigned Counter";
    if (!isShopAdmin && selectedCounterId != null) {
      try {
        var current = counters.firstWhere((element) => element.row_id.toString() == selectedCounterId);
        currentCounterName = current.counter_name ?? "Assigned Counter";
      } catch (e) {
        currentCounterName = "Counter ID: $selectedCounterId";
      }
    }

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Expired Inventory",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xff0F172A))),
            const Text("Track items that have reached their shelf life",
                style: TextStyle(fontSize: 12, color: Color(0xff64748B))),
          ],
        ),
        if (isShopAdmin)
          SizedBox(
            width: isMobile ? double.infinity : 300,
            child: _dropdown("SELECT COUNTER", counters, (v) => v.counter_name, (v) {
              setState(() {
                selectedCounterId = v.row_id.toString();
              });
              // Refresh dynamic data for this counter
              ref.read(master_Provider).fetchExpireItems(params: {"counter_id": selectedCounterId});
            }),
          )
        else
          _infoBadge("Counter: $currentCounterName")
      ],
    );
  }

  Widget _buildResponsiveView(bool isMobile, List expiredItems) {
    if (isMobile) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: expiredItems.length,
        separatorBuilder: (c, i) => const Divider(height: 24),
        itemBuilder: (c, i) => _buildMobileCard(expiredItems[i]),
      );
    }
    return _buildDesktopTable(expiredItems);
  }

  Widget _buildDesktopTable(List expiredItems) {
    return Column(
      children: [
        Container(
          color: const Color(0xffF8FAFC),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: const Row(
            children: [
              Expanded(flex: 2, child: Text("ITEM NAME", style: _tableHeaderStyle)),
              Expanded(flex: 1, child: Text("QUANTITY", style: _tableHeaderStyle)),
              Expanded(flex: 1, child: Text("LOSS AMOUNT", style: _tableHeaderStyle)),
              Expanded(flex: 1, child: Text("EXPIRY DATE", style: _tableHeaderStyle)),
              Expanded(flex: 1, child: Text("STATUS", style: _tableHeaderStyle, textAlign: TextAlign.right)),
            ],
          ),
        ),
        const Divider(height: 1,color: Color(0xffE2E8F0),),
        Expanded(
          child: ListView.builder(
            itemCount: expiredItems.length,
            itemBuilder: (c, i) {
              final item = expiredItems[i];
              // Format Expiry Date
              String formattedDate = "-";
              if (item.expiry_date != null) {
                DateTime dt = DateTime.parse(item.expiry_date.toString());
                formattedDate = DateFormat('dd MMM yyyy').format(dt);
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xffF1F5F9)))),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(item.sweet_name ?? "-", style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff334155)))),
                    Expanded(flex: 1, child: Text("${item.quantity ?? "0"}", style: const TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 1, child: Text("₹${double.parse(item.loss_amount?.toString() ?? "0").toStringAsFixed(2)}", style: const TextStyle(color: Colors.redAccent))),
                    Expanded(flex: 1, child: Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.w400, color: Color(0xff334155)))),
                    Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: _statusBadge())),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileCard(dynamic item) {
    String formattedDate = "-";
    if (item.expiry_date != null) {
      DateTime dt = DateTime.parse(item.expiry_date.toString());
      formattedDate = DateFormat('dd MMM yyyy').format(dt);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.sweet_name ?? "-", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            _statusBadge(),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Qty: ${item.quantity ?? "0"}", style: TextStyle(color: Colors.grey.shade700)),
            Text("Loss: ₹${item.loss_amount ?? "0.00"}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text("Expired on: $formattedDate", style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
      ],
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
      child: const Text("EXPIRED", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.blue.shade100)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.storefront, size: 16, color: Colors.blue),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 48, color: Color(0xffCBD5E1)),
          SizedBox(height: 16),
          Text("No Expired Items Found", style: TextStyle(color: Color(0xff64748B), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

const _tableHeaderStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xff64748B), letterSpacing: 1);