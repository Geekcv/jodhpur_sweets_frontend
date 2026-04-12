import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants/static.dart';
import '../models/TrackOwnOrdersByShopAdminModel.dart';
import '../provider/provider.dart';

class TrackOwnOrdersShopAdminScreen extends ConsumerStatefulWidget {
  const TrackOwnOrdersShopAdminScreen({super.key});

  @override
  ConsumerState<TrackOwnOrdersShopAdminScreen> createState() => _TrackOwnOrdersShopAdminScreenState();
}

class _TrackOwnOrdersShopAdminScreenState extends ConsumerState<TrackOwnOrdersShopAdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(master_Provider).trackOrderStatusShopAdminSendToSupplier();
    });
  }




  String formatDate(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = ref.watch(master_Provider);

    return Scaffold(
      backgroundColor: const Color(0xffF1F5F9),
      body: orderProv.loading
          ? buildShimmerEffectCard(context: context)
          : orderProv.ownOrdersShopAdmin.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Order Tracking History",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff1A2B4C))),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.start,
              children: orderProv.ownOrdersShopAdmin.map((order) {
                return SizedBox(
                  width: 360,
                  child: OrderCard(order: order, formattedDate: formatDate(order.orderDate.toString())),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 50, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text("No orders found", style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}

class OrderCard extends StatefulWidget {
  final TrackOwnOrdersByShopAdminModel order;
  final String formattedDate;
  const OrderCard({super.key, required this.order, required this.formattedDate});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool isHovered = false;

  // SOLUTION: ScrollController define kiya taaki Scrollbar ko link mil sake
  final ScrollController _itemScrollController = ScrollController();

  @override
  void dispose() {
    // Controller dispose karna mat bhulna memory management ke liye
    _itemScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHovered ? const Color(0xffF57C00).withOpacity(0.3) : const Color(0xffE2E8F0),
            width: 1,
          ),
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
                          const Text("ORDER ID", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
                          Text("#${widget.order.orderId.toString().split('_').last}",
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xff1A2B4C))),
                        ],
                      ),
                      _buildStatusBadge(widget.order.orderStatus.toString()),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, thickness: 0.5, color: Color(0xffF1F5F9)),
                  ),
                  Row(
                    children: [
                      _routeIcon(Icons.store_outlined),
                      const SizedBox(width: 8),
                      Expanded(child: _routeDetails(widget.order.shopName ?? "-")),
                      const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(child: _routeDetails(widget.order.supplierName ?? "-", alignRight: true)),
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
                            // --- Left Side: Icon & Title ---
                            Icon(Icons.list_alt_rounded, size: 13, color: Colors.grey.shade500),
                            const SizedBox(width: 6),
                            Text(
                                "CONSIGNMENT DETAILS",
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.grey.shade600,
                                    letterSpacing: 0.7 // Thoda premium spacing
                                )
                            ),

                            // --- The Magic Spacer: Everything after this goes to the extreme right ---
                            const Spacer(),

                            // --- Right Side: Total Items Badge ---
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                // Subtle Gradient for a premium feel
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xff1A2B4C).withOpacity(0.12),
                                    const Color(0xff1A2B4C).withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xff1A2B4C).withOpacity(0.1),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Chota dot indicator
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(color: Color(0xff1A2B4C), shape: BoxShape.circle),
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
                        Divider(),
                        const SizedBox(height: 4),
                        Container(
                          height: 120, // Thodi height badhayi hai taaki 3-4 items saaf dikhein
                          decoration: BoxDecoration(
                            color: const Color(0xffF8FAFC), // Halka sa background depth ke liye
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: Scrollbar(
                            controller: _itemScrollController,
                            thumbVisibility: true,
                            thickness: 2,
                            scrollbarOrientation: ScrollbarOrientation.right,
                            child: Theme(
                              data: ThemeData(
                                scrollbarTheme: ScrollbarThemeData(
                                  thumbColor: WidgetStateProperty.all(
                                    const Color(0xff1A2B4C).withOpacity(0.15), // Light color jo background se blend ho jaye
                                  ),
                                ),
                              ),
                              child: SingleChildScrollView(
                                controller: _itemScrollController,
                                child: Column(
                                  children: List.generate(widget.order.items?.length ?? 0, (index) {
                                    final item = widget.order.items![index];
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                          child: Row(
                                            children: [
                                              // --- Serial Number (Chota aur Professional) ---
                                              Container(
                                                width: 18,
                                                height: 18,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xff1A2B4C).withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "${index + 1}",
                                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xff1A2B4C)),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),

                                              // --- Sweet Name ---
                                              Expanded(
                                                child: Text(
                                                  item.sweetName ?? "-",
                                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xff475569)),
                                                ),
                                              ),

                                              // --- Quantity Badge ---
                                              Container(
                                                margin: EdgeInsets.only(right: 10),
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(color: const Color(0xffE2E8F0)),
                                                ),
                                                child: Text(
                                                  "${item.quantity} ${item.unit}",
                                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xff1A2B4C)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // --- Item Divider (Line between rows) ---
                                        if (index != (widget.order.items!.length - 1))
                                          Divider(height: 1, thickness: 0.5, color: Colors.grey.withOpacity(0.2), indent: 30),
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
                          const Icon(Icons.access_time, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(widget.formattedDate,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey)),
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
    );
  }

  Widget _routeIcon(IconData icon) {
    return Icon(icon, size: 16, color: const Color(0xff94A3B8));
  }

  Widget _routeDetails(String value, {bool alignRight = false}) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xff1A2B4C)),
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isDispatched = status.toUpperCase() == "DISPATCHED";
    Color color = isDispatched ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(status,
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }
}