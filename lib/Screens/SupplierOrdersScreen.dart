import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:js_order_website/controllers/api_controller.dart';
import '../constants/static.dart';
import '../models/SupplierOrder.dart';

class SupplierOrdersScreen extends StatefulWidget {
  const SupplierOrdersScreen({super.key});

  @override
  State<SupplierOrdersScreen> createState() => _SupplierOrdersScreenState();
}

class _SupplierOrdersScreenState extends State<SupplierOrdersScreen> {
  bool isLoading = false;
  List<SupplierOrder> supplierOrders = [];
  SupplierOrder? selectedOrder;
  bool showDetails = false;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  fetchOrders() async {
    setState(() => isLoading = true);
    var data = await ApiController.fetchMyOrderSupplier(params: {});
    setState(() {
      supplierOrders = data;
      isLoading = false;
      // Re-sync selected order if it exists
      if (selectedOrder != null) {
        selectedOrder = supplierOrders.firstWhere((o) => o.orderId == selectedOrder!.orderId, orElse: () => selectedOrder!);
      }
    });
  }

  String getShortId(dynamic id) {
    String s = id.toString();
    return s.length > 4 ? s.substring(s.length - 4).toUpperCase() : s.toUpperCase();
  }

  Future<void> handleUpdateStatus(String orderId, String status) async {
    var res = await ApiController.updateOrderStatus(params: {"order_id": orderId, "status": status});
    if (res != null && res['status'] == 0) {
      _showSnackBar("Order marked as $status", Colors.green);
      await fetchOrders();
    }
    else{
      _showSnackBar("${res['msg']}", Colors.red);
    }
  }

  // --- CHALLAN DIALOG ---
  void _showChallanDialog(String orderId) {
    final transportController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String? vehicleError; // Validation error handle karne ke liye

    List<Map<String, dynamic>> editableItems = selectedOrder!.items!.map((e) => {
      "sweet_id": e.sweetId,
      "sweet_name": e.sweetName,
      "unit": e.unit,
      "quantity": double.tryParse(e.quantity.toString()) ?? 0.0,
      "status": "ACCEPTED",
    }).toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          int activeCount = editableItems.where((e) => e['status'] == "ACCEPTED").length;
          int totalItems = editableItems.length;

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 460,
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Header ---
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Dispatch Challan", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xff0F172A))),
                            Text(
                                "ID: #${orderId.length > 4 ? orderId.substring(orderId.length - 4) : orderId}",
                                style: const TextStyle(fontSize: 11, color: Color(0xff64748B), fontWeight: FontWeight.w500)
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xffF1F5F9), borderRadius: BorderRadius.circular(6)),
                          child: Text("$totalItems Items", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xff475569))),
                        )
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xffF1F5F9)),

                  // --- Items List ---
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: editableItems.asMap().entries.map((entry) {
                          int idx = entry.key;
                          var item = entry.value;
                          bool isRejected = item['status'] == "REJECTED";

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Transform.scale(
                                  scale: 0.6,
                                  child: Switch(
                                    value: !isRejected,
                                    activeColor: Colors.green,
                                    onChanged: (val) => setDialogState(() {
                                      item['status'] = val ? "ACCEPTED" : "REJECTED";
                                      item['quantity'] = val ? (double.tryParse(selectedOrder!.items![idx].quantity.toString()) ?? 0.0) : 0.0;
                                    }),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['sweet_name'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isRejected ? Colors.grey : const Color(0xff334155))),
                                      Text(isRejected ? "REJECTED" : "AVAILABLE", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isRejected ? Colors.red.shade400 : Colors.green.shade600, letterSpacing: 0.5)),
                                    ],
                                  ),
                                ),
                                if (!isRejected)
                                  SizedBox(
                                    width: 80,
                                    height: 28,
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      decoration: InputDecoration(
                                        suffixText: item['unit'],
                                        suffixStyle: const TextStyle(fontSize: 9, color: Colors.grey),
                                        contentPadding: EdgeInsets.zero,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xffE2E8F0))),
                                      ),
                                      onChanged: (v) => item['quantity'] = double.tryParse(v) ?? 0,
                                      controller: TextEditingController(text: item['quantity'].toString()),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // --- Logistics Section (Validation Added Here) ---
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("VEHICLE DETAILS", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xff94A3B8), letterSpacing: 0.5)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: transportController,
                          style: const TextStyle(fontSize: 12),
                          onChanged: (value) {
                            if (vehicleError != null) setDialogState(() => vehicleError = null);
                          },
                          decoration: InputDecoration(
                            hintText: "Enter Vehicle Number",
                            isDense: true,
                            errorText: vehicleError, // Yahan error dikhega
                            errorStyle: const TextStyle(fontSize: 10),
                            prefixIcon: const Icon(Icons.local_shipping, size: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xffE2E8F0))),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- Footer Button ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: activeCount == 0 ? null : () async {
                          // 1. Check if vehicle number is empty
                          if (transportController.text.trim().isEmpty) {
                            setDialogState(() {
                              vehicleError = "Vehicle number is required";
                            });
                            return;
                          }

                          // --- Loader Dikhao ---
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.blue)),
                            // builder: (context) => buildShimmerEffect(context: context),
                          );

                          try {
                            var updateRes = await ApiController.updateOrderItemBySupplier(params: {
                              "order_id": orderId,
                              "items": editableItems.map((e) => {
                                "sweet_id": e['sweet_id'],
                                "status": e['status'],
                                "supplied_quantity": e['quantity']
                              }).toList(),
                            });

                            if (updateRes != null && (updateRes['status'] == 0 || updateRes['status'] == "0")) {
                              var challanRes = await ApiController.createChalanBySupplier(params: {
                                "order_id": orderId,
                                "dispatch_date": DateFormat('yyyy-MM-dd').format(selectedDate),
                                "transport_details": transportController.text.trim(),
                              });

                              Navigator.pop(context); // Close Loader

                              if (challanRes != null && (challanRes['status'] == 0 || challanRes['status'] == "0")) {
                                fetchOrders();
                                Navigator.pop(context); // Close Main Dialog
                                _showSnackBar(challanRes['message'] ?? "Order Dispatched Successfully!", Colors.green);
                              } else {
                                _showSnackBar(challanRes?['message'] ?? "Failed to generate challan", Colors.red);
                              }
                            } else {
                              Navigator.pop(context); // Close Loader
                              _showSnackBar(updateRes?['message'] ?? "Failed to update item status", Colors.red);
                            }
                          } catch (e) {
                            if (Navigator.canPop(context)) Navigator.pop(context); // Close Loader if open
                            _showSnackBar("Something went wrong: ${e.toString()}", Colors.red);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          elevation: 0,
                        ),
                        child: Text("DISPATCH $activeCount ${activeCount > 1 ? 'ITEMS' : 'ITEM'}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontSize: 12)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      width: 300,
    ));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          // ?  const Center(child: CircularProgressIndicator(color: Colors.blue))
        ? buildShimmerEffect(context: context)
          : Row(
        children: [
          Expanded(child: _buildTableSection()),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            width: showDetails ? (screenWidth > 1200 ? 400 : screenWidth * 0.4) : 0,
            // overflow fix using LayoutBuilder
            child: showDetails ? _buildRightDetailsPanel() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSection() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // Thoda zyada rounded for premium look
          border: Border.all(color: const Color(0xffE2E8F0))
      ),
      child: Column(
        children: [
          // --- Table Header ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
                color: Color(0xffF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12))
            ),
            child: Row(
              children: const [
                Expanded(flex: 1, child: Text("ID", style: _headerStyle)),
                Expanded(flex: 2, child: Text("SHOP NAME", style: _headerStyle)),
                Expanded(flex: 2, child: Text("SWEET NAME", style: _headerStyle)),
                Expanded(flex: 2, child: Text("QTY", style: _headerStyle)),
                Expanded(flex: 1, child: Text("TOTAL ITEMS", style: _headerStyle)), // Naya Column
                Expanded(flex: 1, child: Text("STATUS", style: _headerStyle, textAlign: TextAlign.right)),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),

          // --- Table Body ---
          Expanded(
            child: ListView.separated(
              itemCount: supplierOrders.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xffF1F5F9)),
              itemBuilder: (context, index) {
                var item = supplierOrders[index];
                bool isSelected = selectedOrder?.orderId == item.orderId;

                // Logic for "More" sweets
                int itemsCount = item.items?.length ?? 0;
                String firstSweet = item.items?.isNotEmpty == true ? item.items!.first.sweetName ?? "-" : "-";
                String sweetDisplay = itemsCount > 1 ? "$firstSweet +${itemsCount - 1} More" : firstSweet;

                return InkWell(
                  onTap: () => setState(() { selectedOrder = item; showDetails = true; }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xffF0F7FF) : Colors.transparent,
                      border: Border(
                          left: BorderSide(color: isSelected ? const Color(0xff3B82F6) : Colors.transparent, width: 4)
                      ),
                    ),
                    child: Row(
                      children: [
                        // 1. ID
                        Expanded(flex: 1, child: Text("#${getShortId(item.orderId)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff1E293B)))),

                        // 2. Shop Name
                        Expanded(flex: 2, child: Text(item.shop?.shopName ?? "-", style: const TextStyle(fontSize: 13, color: Color(0xff475569)), overflow: TextOverflow.ellipsis)),

                        // 3. Sweet Name (With More Tag)
                        Expanded(
                            flex: 2,
                            child: Text(
                                sweetDisplay,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: itemsCount > 1 ? FontWeight.w600 : FontWeight.normal,
                                    color: itemsCount > 1 ? const Color(0xff3B82F6) : const Color(0xff475569)
                                ),
                                overflow: TextOverflow.ellipsis
                            )
                        ),


                        // 5. Total Quantity (Sum of all items)
                      Expanded(
                        flex: 2,
                        child: Builder(
                          builder: (context) {
                            // Saari quantities ko "5kg, 3kg, 8kg" format mein map karo
                            List<String> qtyList = item.items?.map((e) => "${e.quantity}${e.unit}").toList() ?? [];

                            // Display logic: Pehli 2 quantities dikhao, baaki ke liye "+More"
                            String qtyDisplay = "";
                            if (qtyList.length > 2) {
                              qtyDisplay = "${qtyList.take(2).join(", ")} +${qtyList.length - 2} More";
                            } else {
                              qtyDisplay = qtyList.join(", ");
                            }

                            return Text(
                              qtyDisplay,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: qtyList.length > 2 ? FontWeight.w600 : FontWeight.normal,
                                  color: qtyList.length > 2 ? const Color(0xff3B82F6) : const Color(0xff1E293B)
                              ),
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ),

                        // 4. Total Items Count
                        Expanded(
                            flex: 1,
                            child: Text("${itemsCount}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
                        ),

                        // 6. Status
                        Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: _statusBadge(item.orderStatus))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildRightDetailsPanel() {
    if (selectedOrder == null) return const SizedBox();
    String status = selectedOrder!.orderStatus ?? "PENDING";

    return Container(
      decoration: const BoxDecoration(color: Colors.white, border: Border(left: BorderSide(color: Color(0xffE2E8F0)))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text("Order Details", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const Spacer(),
                _statusBadge(status, isSmall: false),
                const SizedBox(width: 8),
                IconButton(onPressed: () => setState(() => showDetails = false), icon: const Icon(Icons.close, size: 18, color: Colors.grey)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("TRACKING", style: _sectionTitleStyle),
                  const SizedBox(height: 12),
                  _buildStatusBar(status),
                  const SizedBox(height: 24),
                  const Text("INFO", style: _sectionTitleStyle),
                  const SizedBox(height: 8),
                  _buildInfoBox(),
                  const SizedBox(height: 10),
                  // const Text("ITEMS", style: _sectionTitleStyle),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("ITEMS", style: _sectionTitleStyle),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1), // Light blue background
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "${selectedOrder!.items!.length} Items",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...selectedOrder!.items!.map((e) => _buildItemTile(e)),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xffF1F5F9)))),
            child: Column(
              children: [
                if (status == "PENDING")
                  _buildActionBtn("Accept Order", const Color(0xff10B981), Colors.white, Icons.check,
                          () => handleUpdateStatus(selectedOrder!.orderId.toString(), "ACCEPTED")),
                if (status == "ACCEPTED" || status == "PROCESSING") ...[
                  // _buildActionBtn("Dispatch Order", const Color(0xff3B82F6), Colors.white, Icons.local_shipping,
                  //         () => handleUpdateStatus(selectedOrder!.orderId.toString(), "DISPATCHED")),
                  // const SizedBox(height: 8),
                  _buildActionBtn("Generate Challan", Colors.white, Colors.black87, Icons.description,
                          () => _showChallanDialog(selectedOrder!.orderId.toString()), isOutline: true),
                ],
                if (status == "DISPATCHED")
                  const Center(child: Text("✓ Order Dispatched & Challan Generated", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(String status) {
    bool isAccepted = status == "ACCEPTED" || status == "PROCESSING" || status == "DISPATCHED";
    bool isDispatched = status == "DISPATCHED";
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statusDot("Pending", true),
        _statusLine(isAccepted),
        _statusDot("Accepted", isAccepted),
        _statusLine(isDispatched),
        _statusDot("Sent", isDispatched),
      ],
    );
  }

  Widget _statusDot(String label, bool active) => Column(
    children: [
      Icon(active ? Icons.check_circle : Icons.radio_button_unchecked, size: 14, color: active ? Colors.blue : Colors.grey),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 9, color: active ? Colors.black : Colors.grey)),
    ],
  );

  Widget _statusLine(bool active) => Expanded(child: Container(height: 1.5, color: active ? Colors.blue : Colors.grey.shade300, margin: const EdgeInsets.only(bottom: 14)));

  Widget _buildInfoBox() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xffF8FAFC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xffF1F5F9))),
    child: Column(
      children: [
        _infoRow("Order ID", "#${getShortId(selectedOrder!.orderId)}"),
        _infoRow("Shop", selectedOrder!.shop?.shopName ?? "-"),
        _infoRow("Received", selectedOrder!.orderDate != null ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(selectedOrder!.orderDate.toString())) : "N/A"),
      ],
    ),
  );

  Widget _infoRow(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Flexible(child: Text(l, style: const TextStyle(color: Color(0xff64748B), fontSize: 11), overflow: TextOverflow.ellipsis)), Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))]),
  );

  Widget _buildItemTile(dynamic e) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(border: Border.all(color: const Color(0xffF1F5F9)), borderRadius: BorderRadius.circular(6)),
    child: Row(
      children: [
        Expanded(child: Text(e.sweetName ?? "-", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
        Text("${e.quantity} ${e.unit}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
      ],
    ),
  );

  Widget _buildActionBtn(String l, Color bg, Color tx, IconData i, VoidCallback onTap, {bool isOutline = false}) => SizedBox(
    width: double.infinity, height: 40,
    child: ElevatedButton.icon(
      onPressed: onTap, icon: Icon(i, size: 14, color: tx), label: Text(l, style: TextStyle(color: tx, fontSize: 12, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: isOutline ? const BorderSide(color: Color(0xffE2E8F0)) : BorderSide.none)),
    ),
  );

  Widget _statusBadge(String? status, {bool isSmall = true}) {
    Color col = status == "PENDING" ? Colors.orange : (status == "DISPATCHED" ? Colors.green : Colors.blue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status ?? "PENDING", style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 9)),
    );
  }
}

const _headerStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xff64748B), letterSpacing: 0.5);
const _sectionTitleStyle = TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xff94A3B8), letterSpacing: 1);