import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:js_order_website/controllers/api_controller.dart';
import '../constants/static.dart';
import '../provider/provider.dart'; // Apna provider path check kar lena

class OrderRequestListScreen extends ConsumerStatefulWidget {
  const OrderRequestListScreen({super.key});

  @override
  ConsumerState<OrderRequestListScreen> createState() => _OrderRequestListScreenState();
}

class _OrderRequestListScreenState extends ConsumerState<OrderRequestListScreen> {
  // Colors & Styles
  static const Color primaryDark = Color(0xff1A2B4C);
  static const Color bgLight = Color(0xffF8FAFC);
  static const Color borderCol = Color(0xffE2E8F0);
  static const Color accentBlue = Color(0xff3B82F6);
  static const _hStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xff64748B));

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(master_Provider).fetchOrderRequest();
    });
  }


  @override
  Widget build(BuildContext context) {
    final masterProv = ref.watch(master_Provider);
    final List<dynamic> orders = masterProv.allOrdersOfCounterUser ?? [];
    final bool isLoading = masterProv.loading;

    return Scaffold(
      backgroundColor: const Color(0xffF9FBFF),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER SECTION ---
            _buildHeaderSection(isLoading),
            const SizedBox(height: 20),

            // --- MAIN CONTENT (TABLE) ---
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderCol),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  children: [
                    _buildTableHeader(),
                    const Divider(height: 1, color: borderCol),

                    Expanded(
                      child: isLoading
                          ? buildShimmerEffectCard(context: context)
                          : orders.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                        itemCount: orders.length,
                        separatorBuilder: (c, i) => const Divider(height: 1, color: borderCol),
                        itemBuilder: (c, i) => _buildOrderRow(orders[i], i + 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool isLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Order Requests",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryDark)),
            // const SizedBox(height: 4),
            Text("Track and manage incoming inventory requests from counters",
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        // Refresh Button
        // OutlinedButton.icon(
        //   onPressed: () => ref.read(master_Provider).fetchOrderRequest(),
        //   icon: isLoading
        //       ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
        //       : const Icon(Icons.refresh_rounded, size: 18),
        //   label: const Text("REFRESH"),
        //   style: OutlinedButton.styleFrom(
        //     side: const BorderSide(color: borderCol),
        //     foregroundColor: primaryDark,
        //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        //   ),
        // )
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      color: bgLight,
      child: const Row(
        children: [
          SizedBox(width: 45, child: Text("S.N.", style: _hStyle)),
          Expanded(flex: 3, child: Text("SWEET NAME", style: _hStyle)),
          Expanded(flex: 2, child: Text("QUANTITY", style: _hStyle)),
          Expanded(flex: 2, child: Text("COUNTER NAME", style: _hStyle)),
          Expanded(flex: 2, child: Text("REQUEST DATE", style: _hStyle)),
          Expanded(flex: 2, child: Text("STATUS", textAlign: TextAlign.center, style: _hStyle)),
        ],
      ),
    );
  }

  Widget _buildOrderRow(dynamic order, int index) {
    String status = (order.status ?? "PENDING").toString().toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        children: [
          // Index
          SizedBox(width: 45, child: Text("${index.toString()}.",
              style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w500))),

          // Sweet Info
          Expanded(flex: 3, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.sweet_name?.toString().toUpperCase() ?? "N/A",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryDark)),
              // const SizedBox(height: 2),
              // Text("ID: ${order.row_id.toString().split('_').last}",
              //     style: TextStyle(fontSize: 10, color: Colors.blueGrey[300], letterSpacing: 0.5)),
            ],
          )),

          // Quantity
          Expanded(flex: 2, child: Row(
            children: [
              Text("${order.quantity ?? '0'}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
              const SizedBox(width: 4),
              Text("${order.unit ?? ''}",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          )),

          // Counter
          Expanded(flex: 2, child: Text(order.counter_name ?? "-",
              style: const TextStyle(fontSize: 13, color: Colors.blueGrey, fontWeight: FontWeight.w500))),

          // Date
          Expanded(flex: 2, child: Text(_formatDateTime(order.cr_on.toString()),
              style: TextStyle(fontSize: 12, color: Colors.grey[700]))),

          // Status Badge
          Expanded(flex: 2, child: Center(child: _statusBadge(status))),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    bool isPending = status == "PENDING";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: isPending ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isPending ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2))
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3, backgroundColor: isPending ? Colors.orange : Colors.green),
          const SizedBox(width: 6),
          Text(status,
              style: TextStyle(color: isPending ? Colors.orange[800] : Colors.green[800],
                  fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  String _formatDateTime(String date) {
    if (date == "null") return "-";
    try {
      DateTime dt = DateTime.parse(date);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      return date;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No order requests found", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }
}