import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:js_order_website/controllers/api_controller.dart';

import 'package:http/http.dart' as http;
import 'dart:html' as html;

import '../../constants/static.dart';
import '../../models/ChalanDataModel.dart';
import '../../provider/provider.dart';
import '../../widgets/CustomPdfViewerScreen.dart';
import '../../widgets/TextInputField.dart';
import '../LoginUserDetails.dart';

class ChalanListScreen extends ConsumerStatefulWidget {
  const ChalanListScreen({super.key});

  @override
  ConsumerState<ChalanListScreen> createState() => _ChalanListScreenState();
}

class _ChalanListScreenState extends ConsumerState<ChalanListScreen> {
  final List<String> downloadingIds = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(master_Provider).fetchChallan();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";
    try {
      return DateFormat('dd MMM, yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  String formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(dateStr));
    } catch (_) {
      return "N/A";
    }
  }

  Future<void> _handleDownload(ChalanDataModel data, StateSetter setModalState) async {
    final String id = data.chalanId.toString();
    setModalState(() => downloadingIds.add(id));

    try {
      var res = await ApiController.downLoadChalan(
        context: context,
        params: {'chalan_id': data.chalanId},
      );

      if (res != null && res['status'] == 0) {
        String url = res['filePath'];
        String fileName = "Chalan_${id.split('_').last}.pdf";

        final response = await http.get(Uri.parse(url));
        final blob = html.Blob([response.bodyBytes]);
        final blobUrl = html.Url.createObjectUrlFromBlob(blob);

        html.AnchorElement(href: blobUrl)
          ..setAttribute("download", fileName)
          ..click();

        html.Url.revokeObjectUrl(blobUrl);

        if (mounted) Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['msg'] ?? "Download failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error while downloading file")),
      );
    } finally {
      if (mounted) setModalState(() => downloadingIds.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final masterProv = ref.watch(master_Provider);
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 800;

    final filteredChallans = masterProv.challanData.where((item) {
      final q = _searchQuery.toLowerCase().trim();
      if (q.isEmpty) return true;

      final chalanId = (item.chalanId ?? "").toString().toLowerCase();
      final orderId = (item.orderId ?? "").toString().toLowerCase();
      final shop = (item.shopName ?? "").toLowerCase();
      final city = (item.city ?? "").toLowerCase();
      final transport = (item.transportDetails ?? "").toLowerCase();
      final supplier = (item.supplierName ?? "").toLowerCase();
      final hasMatchingItem = item.items?.any((i) => (i.sweetName ?? "").toLowerCase().contains(q)) ?? false;

      return chalanId.contains(q) || orderId.contains(q) || shop.contains(q) || city.contains(q) || transport.contains(q) || supplier.contains(q) || hasMatchingItem;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF1F5F9),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader(isMobile),
            const SizedBox(height: 16),
            Expanded(
              child: masterProv.loading
                  ? buildShimmerEffectCard(context: context)
                  : filteredChallans.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: size.width > 1200 ? 3 : size.width > 800 ? 2 : 1,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  mainAxisExtent: 410,
                ),
                itemCount: filteredChallans.length,
                itemBuilder: (context, index) => _buildChalanCard(filteredChallans[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Challans",
                style: TextStyle(
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xff1A2B4C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Manage and track delivery challans",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        SizedBox(
          width: isMobile ? 180 : 300,
          height: 38,
          child: CustomTextInput(
            hintText: "Search challan, item...",
            controller: _searchController,
            maxLines: 1,
            keyboardType: TextInputType.text,
            onChanged: (val) => setState(() => _searchQuery = val),
            prefixicon: const Icon(Icons.search, size: 16, color: Colors.grey),
            suffixicon: _searchQuery.isNotEmpty
                ? InkWell(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = "");
              },
              child: const Icon(Icons.clear, size: 14, color: Colors.grey),
            )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildChalanCard(ChalanDataModel data) {
    final ScrollController cardScrollController = ScrollController();
    bool isAlreadyVerified = data.is_verified == true;
    return InkWell(
      onTap: () => _showChalanDetail(data),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, color: Color(0xff64748B), size: 20),
                  const SizedBox(width: 8),
                  Text("CHL-${data.chalanId.toString().split('_').last}", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xff1E293B))),
                  const Spacer(),
                  _statusBadge(data.orderStatus ?? "PENDING"),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoTile(Icons.home_outlined, "DESTINATION", data.shopName ?? "-", "${data.city}, ${data.state}"),
                  _infoTile(Icons.local_shipping_outlined, "VEHICLE", data.transportDetails ?? "-", "${data.supplierName}"),
                  const SizedBox(width: 6),
                  _infoTile(Icons.calendar_today_outlined, "DISPATCH", formatDate(data.dispatchDate.toString()), formatTime(data.orderDate.toString())),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                decoration: BoxDecoration(
                  color: const Color(0xffF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffE2E8F0)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("ITEMS SUMMARY", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xff64748B), letterSpacing: 0.5)),
                        Text("TOTAL: ${data.items?.length ?? 0}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xff1E293B))),
                      ],
                    ),
                    const Divider(height: 24, color: Color(0xffE2E8F0)),
                    Expanded(
                      child: Scrollbar(
                        controller: cardScrollController,
                        thumbVisibility: true,
                        thickness: 3,
                        radius: const Radius.circular(10),
                        child: ListView.separated(
                          controller: cardScrollController,
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(right: 12),
                          itemCount: data.items?.length ?? 0,
                          separatorBuilder: (context, i) => Divider(height: 1, thickness: 0.5, color: Colors.grey.withOpacity(0.08), indent: 35),
                          itemBuilder: (context, i) {
                            final item = data.items![i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(color: const Color(0xff6366F1).withOpacity(0.1), shape: BoxShape.circle),
                                    child: Center(child: Text("${i + 1}", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xff6366F1)))),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(item.sweetName ?? "-", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xff334155)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xffE2E8F0))),
                                    child: Text("${item.quantity} ${item.unit}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xff1A2B4C))),
                                  ),
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isAlreadyVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xffDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xff22C55E).withOpacity(0.5)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified, color: Color(0xff166534), size: 14),
                          SizedBox(width: 4),
                          Text("VERIFIED", style: TextStyle(color: Color(0xff166534), fontSize: 10, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    )
                  else if (LoginUserDetails.role == 'SHOP_ADMIN')
                    InkWell(
                      onTap: () => _handleVerifyOTP(data),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xff4F46E5), Color(0xff4338CA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [BoxShadow(color: const Color(0xff4F46E5).withOpacity(0.25), blurRadius: 2, offset: const Offset(0, 1))],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.security, color: Colors.white, size: 14),
                            SizedBox(width: 6),
                            Text("VERIFY", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(width: 10),
                  _actionButton(Icons.visibility_outlined, () => _showChalanDetail(data)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChalanDetail(ChalanDataModel data) {
    String shortChalanId = data.chalanId.toString().length > 4
        ? data.chalanId.toString().substring(data.chalanId.toString().length - 4)
        : data.chalanId.toString();
    String shortOrderId = data.orderId.toString().length > 4
        ? data.orderId.toString().substring(data.orderId.toString().length - 4)
        : data.orderId.toString();

    final ScrollController itemsScrollController = ScrollController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDownloading = downloadingIds.contains(data.chalanId.toString());

          return Dialog(
            backgroundColor: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 650,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Action Bar / Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.description_outlined, color: Color(0xff2563EB), size: 22),
                            SizedBox(width: 8),
                            Text(
                              "Challan",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff0F172A)),
                            ),
                          ],
                        ),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 1. VIEW PDF BUTTON (Square Custom Design)
                              IconButton(
                                tooltip: "View PDF",
                                onPressed: () async {
                                  var res = await ApiController.downLoadChalan(
                                    context: context,
                                    params: {'chalan_id': data.chalanId},
                                  );
                                  if (res != null && res['status'] == 0 && res['filePath'] != null) {
                                    if (context.mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CustomPdfViewerScreen(
                                            pdfUrl: res['filePath'],
                                            title: "Challan #$shortChalanId",
                                            fileName: "Chalan_$shortChalanId.pdf",
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(res?['msg'] ?? "Unable to fetch PDF URL")),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.visibility_outlined, color: Color(0xff2563EB), size: 18),
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(const Color(0xffEFF6FF)),
                                  // Hover background effect disable kiya gaya hai
                                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  // Download button ki vertical height (38px) ke barabar fix kiya gaya hai
                                  fixedSize: WidgetStateProperty.all(const Size(38, 38)),
                                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // 2. PRINT / DOWNLOAD BUTTON
                              ElevatedButton.icon(
                                onPressed: isDownloading ? null : () => _handleDownload(data, setModalState),
                                icon: isDownloading
                                    ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xff2563EB)),
                                )
                                    : const Icon(Icons.print_outlined, size: 16, color: Color(0xff2563EB)),
                                label: Text(
                                  isDownloading ? "Downloading..." : "Download",
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xff2563EB)),
                                ),
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(const Color(0xffEFF6FF)),
                                  elevation: WidgetStateProperty.all(0),
                                  // Hover color completely disable kar diya hai
                                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 14)),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  // Height bilkul View PDF button jitni (38px) fix ki gayi hai
                                  fixedSize: WidgetStateProperty.all(const Size.fromHeight(38)),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // 3. CLOSE BUTTON (Same Height Axis Alignment)
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close_rounded, color: Color(0xff64748B), size: 20),
                                tooltip: "Close",
                                style: ButtonStyle(
                                  // Close button ka bhi hover effect disable kiya gaya hai
                                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                                  fixedSize: WidgetStateProperty.all(const Size(38, 38)),
                                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xffF1F5F9)),

                  // Scrollable Content Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Supplier Info & Challan Header Details
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: const Color(0xff2563EB),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        (data.supplierName != null && data.supplierName!.isNotEmpty)
                                            ? data.supplierName![0].toUpperCase()
                                            : "S",
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data.supplierName ?? "SupplierHub",
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff0F172A)),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        "Delivery Challan / Goods Dispatch Note",
                                        style: TextStyle(fontSize: 12, color: Color(0xff64748B)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text("Challan No.", style: TextStyle(fontSize: 11, color: Color(0xff64748B))),
                                  const SizedBox(height: 2),
                                  Text(
                                    "CH-$shortChalanId",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xff0F172A)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    formatDate(data.dispatchDate.toString()),
                                    style: const TextStyle(fontSize: 12, color: Color(0xff64748B)),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Divider(thickness: 1, color: Color(0xff0F172A)),
                          const SizedBox(height: 20),

                          // Information Cards Side-by-Side
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xffE2E8F0)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.person_outline, size: 15, color: Color(0xff64748B)),
                                          SizedBox(width: 6),
                                          Text("Delivered To", style: TextStyle(fontSize: 12, color: Color(0xff64748B))),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        data.shopName ?? "-",
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff0F172A)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Order: #ORD-$shortOrderId",
                                        style: const TextStyle(fontSize: 12, color: Color(0xff64748B)),
                                      ),
                                      if (data.city != null || data.state != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          "${data.city ?? ''}, ${data.state ?? ''}",
                                          style: const TextStyle(fontSize: 11, color: Color(0xff94A3B8)),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xffE2E8F0)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.local_shipping_outlined, size: 15, color: Color(0xff64748B)),
                                          SizedBox(width: 6),
                                          Text("Vehicle Details", style: TextStyle(fontSize: 12, color: Color(0xff64748B))),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        data.transportDetails ?? "-",
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff0F172A)),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Text("Status: ", style: TextStyle(fontSize: 12, color: Color(0xff64748B))),
                                          Text(
                                            data.orderStatus ?? "Dispatched",
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff059669)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Items Table Container with Internal Scrollbar
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xffE2E8F0)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: const BoxDecoration(
                                    color: Color(0xffF8FAFC),
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                                  ),
                                  child: const Row(
                                    children: [
                                      SizedBox(width: 30, child: Text("#", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xff475569)))),
                                      Expanded(flex: 3, child: Text("PRODUCT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xff475569)))),
                                      Expanded(flex: 1, child: Text("REQ. QTY", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xff475569)))),
                                      Expanded(flex: 1, child: Text("SUP. QTY", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xff475569)))),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1, color: Color(0xffE2E8F0)),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxHeight: 220),
                                  child: Scrollbar(
                                    controller: itemsScrollController,
                                    thumbVisibility: true,
                                    child: ListView.separated(
                                      controller: itemsScrollController,
                                      shrinkWrap: true,
                                      itemCount: data.items?.length ?? 0,
                                      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xffF1F5F9)),
                                      itemBuilder: (context, index) {
                                        final item = data.items![index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 30,
                                                child: Text("${index + 1}", style: const TextStyle(fontSize: 12, color: Color(0xff64748B))),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  item.sweetName ?? "-",
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xff0F172A)),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  "${item.quantity ?? '-'}",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(fontSize: 13, color: Color(0xff64748B)),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  "${item.quantity ?? '-'} ${item.unit ?? ''}",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xff0F172A)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const Divider(height: 1, color: Color(0xffE2E8F0)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: const BoxDecoration(
                                    color: Color(0xffF8FAFC),
                                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(11)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Text("Total Supplied Items: ", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xff475569))),
                                      Text(
                                        "${data.items?.length ?? 0}",
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff0F172A)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value, String subValue) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 12, color: const Color(0xff64748B)),
            const SizedBox(width: 4),
            Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xff64748B))),
          ]),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(subValue, style: const TextStyle(fontSize: 10, color: Color(0xff94A3B8)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    bool isDispatched = status == "DISPATCHED";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: isDispatched ? const Color(0xffDCFCE7) : const Color(0xffFEF3C7), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: isDispatched ? const Color(0xff22C55E) : const Color(0xffF59E0B), size: 7),
          const SizedBox(width: 5),
          Text(status, style: TextStyle(color: isDispatched ? const Color(0xff166534) : const Color(0xff92400E), fontSize: 10, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xffE2E8F0)), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: const Color(0xff64748B)),
      ),
    );
  }

  Widget _buildModalSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xff94A3B8), fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xff334155))),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text("No Chalans Found", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }

  Future<void> _handleVerifyOTP(ChalanDataModel data) async {
    final otpController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Color(0xffEEF2FF), shape: BoxShape.circle),
                child: const Icon(Icons.shield_outlined, color: Color(0xff4F46E5), size: 32),
              ),
              const SizedBox(height: 20),
              const Text("Security Verification", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xff1E293B))),
              const SizedBox(height: 8),
              const Text("Enter the 6-digit OTP to verify delivery and update stock inventory.", textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0xff64748B), height: 1.5)),
              const SizedBox(height: 24),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: 8, color: Color(0xff4F46E5)),
                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: const Color(0xffF8FAFC),
                  hintText: "000000",
                  hintStyle: TextStyle(color: Colors.grey[300], letterSpacing: 8),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xffE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xff4F46E5), width: 2)),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text("Cancel", style: TextStyle(color: Color(0xff64748B), fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff4F46E5),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        if (otpController.text.length < 4) return;

                        var res = await ApiController.verifyChallanForAutoInv(params: {
                          'chalan_id': data.chalanId,
                          'otp': otpController.text.trim(),
                        });

                        if (res != null && (res['status'] == 0 || res['status'] == "0")) {
                          Navigator.pop(context);
                          ref.read(master_Provider).fetchChallan();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['msg'] ?? "Inventory Updated!"), backgroundColor: const Color(0xff10B981), behavior: SnackBarBehavior.floating));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['msg'] ?? "Invalid OTP"), backgroundColor: const Color(0xffEF4444), behavior: SnackBarBehavior.floating));
                        }
                      },
                      child: const Text("Confirm", style: TextStyle(fontWeight: FontWeight.bold)),
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
}