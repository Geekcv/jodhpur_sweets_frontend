import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:js_order_website/controllers/api_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/static.dart';
import '../models/SupplierOrder.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

import '../widgets/CustomPdfViewerScreen.dart';
import '../widgets/TextInputField.dart';


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
                        CustomTextInput(
                          height: 40,
                          controller: transportController,
                          validator: true,
                          hintText: "Enter Vehicle Number",
                          onChanged: (value) {
                            if (vehicleError != null) setDialogState(() => vehicleError = null);
                          },
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
                            // Professional Modern Blue (Slate / Indigo Accent mix look)
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,

                            // Clean padding & size consistency
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            minimumSize: const Size(double.infinity, 48), // Sleek full-width height

                            // Smooth subtle elevation
                            elevation: 0.5,
                            shadowColor: const Color(0xFF2563EB).withOpacity(0.3),

                            // Rounded subtle borders with subtle outer stroke
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Color(0xFF1D4ED8), width: 0.5),
                            ),

                            // Text styling for clear typography
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
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


  Set<String> downloadingIds = {};
  Future<void> _handleDownload(SupplierOrder order, StateSetter setModalState) async {
    final String orderId = order.orderId.toString();
    setModalState(() => downloadingIds.add(orderId));

    try {
      var res = await ApiController.downloadOrderRequestSupplierSide(context: context,params: {'order_id': orderId});

      if (res != null && res['status'] == 0) {
        String url = res['filePath'];
        String fileName = "Order_${orderId.split('_').last}.pdf";

        final response = await http.get(Uri.parse(url));
        final bytes = response.bodyBytes;

        final blob = html.Blob([bytes], 'application/pdf');
        final blobUrl = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: blobUrl)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(blobUrl);

        _showSnackBar("Download Completed", Colors.green);
      } else {
        _showSnackBar(res['msg'] ?? "Failed to fetch file", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Error: $e", Colors.red);
    } finally {
      if (mounted) {
        setModalState(() => downloadingIds.remove(orderId));
      }
    }
  }



  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isGridView = true;
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  List<SupplierOrder> get filteredOrders {
    if (searchQuery.trim().isEmpty) return supplierOrders;
    String query = searchQuery.toLowerCase();
    return supplierOrders.where((order) {
      String orderId = order.orderId.toString().toLowerCase();
      String shopName = order.shop?.shopName?.toLowerCase() ?? "";
      bool hasMatchingSweet = order.items?.any((item) =>
          (item.sweetName ?? "").toLowerCase().contains(query)) ?? false;

      return orderId.contains(query) || shopName.contains(query) || hasMatchingSweet;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      endDrawer: Drawer(
        width: screenWidth > 1200 ? 450 : screenWidth * 0.45,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: _buildRightDetailsPanel(),
      ),
      onEndDrawerChanged: (isOpen) {
        if (!isOpen) {
          setState(() => showDetails = false);
        }
      },
      body: isLoading
          ? buildShimmerEffect(context: context)
          : Column(
        children: [
          _buildHeaderAndSearchBar(),
          Expanded(
            child: filteredOrders.isEmpty
                ? _buildNoDataFound()
                : (isGridView ? _buildCardSection() : _buildTableSection()),
          ),
        ],
      ),
    );
  }



  // @override
  // Widget build(BuildContext context) {
  //   double screenWidth = MediaQuery.of(context).size.width;
  //
  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     body: isLoading
  //         // ?  const Center(child: CircularProgressIndicator(color: Colors.blue))
  //       ? buildShimmerEffect(context: context)
  //         : Row(
  //       children: [
  //         Expanded(child: _buildTableSection()),
  //         AnimatedContainer(
  //           duration: const Duration(milliseconds: 300),
  //           curve: Curves.fastOutSlowIn,
  //           width: showDetails ? (screenWidth > 1200 ? 400 : screenWidth * 0.4) : 0,
  //           // overflow fix using LayoutBuilder
  //           child: showDetails ? _buildRightDetailsPanel() : const SizedBox.shrink(),
  //         ),
  //       ],
  //     ),
  //   );
  // }





  Widget _buildHeaderAndSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Side: Title & Subtitle
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "Supplier Orders",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff0F172A)),
                ),
                SizedBox(height: 2),
                Text(
                  "Review and manage incoming orders from shops",
                  style: TextStyle(fontSize: 12, color: Color(0xff64748B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Right Side: Search Bar + View Toggle Controls
          Expanded(
            flex: 1,
            child: Row(
              children: [
                // Search Input Field
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xffE2E8F0)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: "Search by sweet, order ID, shop...",
                        hintStyle: TextStyle(fontSize: 12, color: Color(0xff94A3B8)),
                        prefixIcon: Icon(Icons.search, size: 18, color: Color(0xff64748B)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Grid / List View Toggle Buttons
                Container(
                  height: 40,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xffE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => setState(() => isGridView = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: isGridView ? const Color(0xffEFF6FF) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.grid_view_rounded,
                            size: 18,
                            color: isGridView ? const Color(0xff2563EB) : const Color(0xff64748B),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => isGridView = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: !isGridView ? const Color(0xffEFF6FF) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.view_list_rounded,
                            size: 18,
                            color: !isGridView ? const Color(0xff2563EB) : const Color(0xff64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }




  Widget _buildCardSection() {
    List<SupplierOrder> list = filteredOrders;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 440,
        mainAxisExtent: 360,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        var item = list[index];
        String status = item.orderStatus ?? "PENDING";
        int itemsCount = item.items?.length ?? 0;
        bool isSelected = selectedOrder?.orderId == item.orderId;

        // Fix for undefined 'isDownloading' identifier
        bool isDownloading = downloadingIds.contains(item.orderId.toString());

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              selectedOrder = item;
              showDetails = true;
            });
            _scaffoldKey.currentState?.openEndDrawer();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xffF0F7FF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xff2563EB) : const Color(0xffE2E8F0),
                width: isSelected ? 1.5 : 1.0,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: const Color(0xff2563EB).withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Clean Header: Order ID, Status, View PDF & Download Actions
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xffDBEAFE) : const Color(0xffF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        size: 18,
                        color: Color(0xff2563EB),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "#${getShortId(item.orderId)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xff0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _statusBadge(status),
                    const Spacer(),

                    // Action Button 1: View PDF
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xffEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: IconButton(
                        tooltip: "View PDF",
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.visibility_outlined, color: Color(0xff2563EB), size: 16),
                        onPressed: () async {
                          final String currentOrderId = item.orderId.toString();
                          var res = await ApiController.downloadOrderRequestSupplierSide(
                            context: context,
                            params: {'order_id': currentOrderId},
                          );

                          if (res != null && res['status'] == 0 && res['filePath'] != null) {
                            // if (context.mounted) {
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => CustomPdfViewerScreen(
                            //         pdfUrl: res['filePath'],
                            //         title: "Order #${getShortId(currentOrderId)}",
                            //         fileName: "Order_${currentOrderId.split('_').last}.pdf",
                            //       ),
                            //     ),
                            //   );
                            // }
                            final Uri url = Uri.parse(res['filePath']);

                            // New Tab me open karne ke liye launchUrl with externalApplication
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                webOnlyWindowName: '_blank', // Web par new tab kholne ke liye
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Could not open PDF link")),
                                );
                              }
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(res?['msg'] ?? "Unable to fetch PDF URL")),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Action Button 2: Download / Print
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xffF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: isDownloading
                          ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : IconButton(
                        tooltip: "Download Order Copy",
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.print_outlined, size: 16, color: Color(0xff475569)),
                        onPressed: () => _handleDownload(item, setState),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Divider(thickness: 0.3),
                // 2. Info Grid: Destination & Total Items Count
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "SHOP",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff94A3B8),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.shop?.shopName ?? "-",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff1E293B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "${item.shop?.city ?? ''}${item.shop?.city != null && item.shop?.state != null ? ', ' : ''}${item.shop?.state ?? ''}",
                            style: const TextStyle(fontSize: 11, color: Color(0xff64748B)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 32,
                      width: 1,
                      color: const Color(0xffE2E8F0),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "TOTAL ITEMS",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff94A3B8),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$itemsCount Items",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2563EB),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. Items Summary List Section
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : const Color(0xffF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? const Color(0xffBFDBFE) : const Color(0xffF1F5F9),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "ORDER ITEMS",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              "$itemsCount Total",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff64748B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1, thickness: 1, color: Color(0xffE2E8F0)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: item.items?.length ?? 0,
                            separatorBuilder: (c, i) => const SizedBox(height: 8),
                            itemBuilder: (c, idx) {
                              var sweet = item.items![idx];
                              return Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: 20,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffEFF6FF),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "${idx + 1}",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff2563EB),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      sweet.sweetName ?? "-",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff334155),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: const Color(0xffCBD5E1)),
                                    ),
                                    child: Text(
                                      "${sweet.quantity} ${sweet.unit}",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff0F172A),
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
              ],
            ),
          ),
        );
      },
    );
  }



// 5. No Data Found Empty State View:
  Widget _buildNoDataFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 48, color: Color(0xff94A3B8)),
          const SizedBox(height: 12),
          const Text(
            "No Orders Found",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff475569)),
          ),
          // const SizedBox(height: 4),
          // Text(
          //   searchQuery.isNotEmpty ? "No orders matched '$searchQuery'" : "There are currently no orders available.",
          //   style: const TextStyle(fontSize: 12, color: Color(0xff94A3B8)),
          // ),
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
                Expanded(flex: 1, child: Text("STATUS", style: _headerStyle,)),
                Expanded(flex: 2, child: Text("ACTION", style: _headerStyle, textAlign: TextAlign.center)),
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
                bool isDownloading = downloadingIds.contains(item.orderId.toString());

                // Logic for "More" sweets
                int itemsCount = item.items?.length ?? 0;
                String firstSweet = item.items?.isNotEmpty == true ? item.items!.first.sweetName ?? "-" : "-";
                String sweetDisplay = itemsCount > 1 ? "$firstSweet +${itemsCount - 1} More" : firstSweet;

                return InkWell(
                  // onTap: () => setState(() { selectedOrder = item; showDetails = true; }),
                  // onTap: () {
                  //   setState(() {
                  //     if (selectedOrder?.orderId == item.orderId) {
                  //       // Agar wahi item hai, toh band kar do (toggle)
                  //       showDetails = !showDetails;
                  //     } else {
                  //       // Agar naya item hai, toh select karo aur panel khol do
                  //       selectedOrder = item;
                  //       showDetails = true;
                  //     }
                  //   });
                  // },
                  onTap: () {
                    setState(() {
                      selectedOrder = item;
                      showDetails = true;
                    });
                    // EndDrawer kholne ke liye yeh line required hai:
                    _scaffoldKey.currentState?.openEndDrawer();
                  },
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
                        Expanded(flex: 1, child: Align(alignment: Alignment.centerLeft, child: _statusBadge(item.orderStatus))),

                        // 7. Actions

                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // View PDF Button
                              Container(
                                height: 32,
                                width: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xffEFF6FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: IconButton(
                                  tooltip: "View PDF",
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.visibility_outlined, color: Color(0xff2563EB), size: 16),
                                  onPressed: () async {
                                    final String currentOrderId = item.orderId.toString();
                                    var res = await ApiController.downloadOrderRequestSupplierSide(
                                      context: context,
                                      params: {'order_id': currentOrderId},
                                    );

                                    if (res != null && res['status'] == 0 && res['filePath'] != null) {
                                      // if (context.mounted) {
                                      //   Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //       builder: (context) => CustomPdfViewerScreen(
                                      //         pdfUrl: res['filePath'],
                                      //         title: "Order #${getShortId(currentOrderId)}",
                                      //         fileName: "Order_${currentOrderId.split('_').last}.pdf",
                                      //       ),
                                      //     ),
                                      //   );
                                      // }
                                      final Uri url = Uri.parse(res['filePath']);

                                      // New Tab me open karne ke liye launchUrl with externalApplication
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(
                                          url,
                                          webOnlyWindowName: '_blank', // Web par new tab kholne ke liye
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Could not open PDF link")),
                                          );
                                        }
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(res?['msg'] ?? "Unable to fetch PDF URL")),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Print / Download Button
                              Container(
                                height: 32,
                                width: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xffF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: isDownloading
                                    ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                                    : IconButton(
                                  tooltip: "Download Order Copy",
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.print_outlined, size: 16, color: Color(0xff475569)),
                                  onPressed: () => _handleDownload(item, setState),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Expanded(
                        //   flex: 1,
                        //   child: Center(
                        //     child: isDownloading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        //     : SizedBox(
                        //       // width: 32,// height: 32,
                        //       child: IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                        //         icon: const Icon(Icons.print, size: 16, color: Colors.blue),
                        //         tooltip: "Download Order Copy",
                        //         onPressed: () => _handleDownload(item, setState)
                        //       ),
                        //     ),
                        //   ),
                        // ),
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
                IconButton(
                  onPressed: () {
                    setState(() => showDetails = false);
                    Navigator.of(context).pop(); // <-- Drawer ko close/pop karega
                  },
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                ),
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
                  _buildActionBtn("Dispatch", Colors.white, Colors.black87, Icons.description,
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