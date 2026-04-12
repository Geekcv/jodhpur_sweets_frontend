import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:js_order_website/controllers/api_controller.dart';
import '../constants/static.dart';
import '../models/ChalanDataModel.dart';
import '../provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

import 'LoginUserDetails.dart'; // Sabse important line download ke liye

class ChalanListScreen extends ConsumerStatefulWidget {
  const ChalanListScreen({super.key});

  @override
  ConsumerState<ChalanListScreen> createState() => _ChalanListScreenState();
}

class _ChalanListScreenState extends ConsumerState<ChalanListScreen> {
  // Loading track karne ke liye
  final List<String> downloadingIds = [];

  final ScrollController _itemScrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(master_Provider).fetchChallan();
    });
  }


  @override
  void dispose() {
    // _itemScrollController.dispose();
    super.dispose();
  }



  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM, yyyy').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  String formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('hh:mm a').format(dt);
    } catch (e) {
      return "N/A";
    }
  }

  Future<void> _handleDownload(ChalanDataModel data, StateSetter setModalState) async {
    final String id = data.chalanId.toString();
    setModalState(() => downloadingIds.add(id));

    try {
      // 1. API se file path lein
      var res = await ApiController.downLoadChalan(
        context: context,
        params: {'chalan_id': data.chalanId},
      );

      if (res != null && res['status'] == 0) {
        String url = res['filePath'];
        String fileName = "Chalan_${id.split('_').last}.pdf";

        // 2. BACKGROUND FETCH (Jo aapne manga tha)
        // Isse browser ko pata nahi chalta ki PDF hai, wo bas bytes leta hai
        final response = await http.get(Uri.parse(url));
        final bytes = response.bodyBytes;

        // 3. BLOB CREATION
        final blob = html.Blob([bytes]);
        final blobUrl = html.Url.createObjectUrlFromBlob(blob);

        // 4. ANCHOR CLICK
        final anchor = html.AnchorElement(href: blobUrl)
          ..setAttribute("download", fileName)
          ..click();

        // 5. CLEANUP
        html.Url.revokeObjectUrl(blobUrl);

        debugPrint('PDF Direct Downloaded Successfully: $fileName');

        if (mounted) {
          Navigator.pop(context); // Modal close
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['msg'] ?? "Download failed")),
        );
      }
    } catch (e) {
      debugPrint("Force Download Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error while downloading file")),
      );
    } finally {
      if (mounted) {
        setModalState(() => downloadingIds.remove(id));
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final masterProv = ref.watch(master_Provider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xffF1F5F9),
      body: masterProv.loading
          ? buildShimmerEffectCard(context: context)
          : masterProv.challanData.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: size.width > 1200 ? 3 : size.width > 800 ? 2 : 1,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          mainAxisExtent: 410,
        ),
        itemCount: masterProv.challanData.length,
        itemBuilder: (context, index) {
          return _buildChalanCard(masterProv.challanData[index]);
        },
      ),
    );
  }

  Widget _buildChalanCard(ChalanDataModel data) {
    final ScrollController cardScrollController = ScrollController();

    bool isAlreadyVerified = data.is_verified == true;
    return Container(
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
                Text(
                  "CHL-${data.chalanId.toString().split('_').last}",
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xff1E293B)),
                ),
                const Spacer(),
                _statusBadge(data.orderStatus ?? "PENDING"),
              ],
            ),
          ),
          SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoTile(Icons.home_outlined, "DESTINATION", data.shopName ?? "-", "${data.city}, ${data.state}"),
                _infoTile(Icons.local_shipping_outlined, "VEHICLE", data.transportDetails ?? "-", "${data.supplierName}"),
                SizedBox(width: 6),
                _infoTile(Icons.calendar_today_outlined, "DISPATCH", formatDate(data.dispatchDate.toString()), formatTime(data.orderDate.toString())),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 16), // Padding adjust ki
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
                      const Text("ITEMS SUMMARY",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xff64748B), letterSpacing: 0.5)),
                      Text("TOTAL: ${data.items?.length ?? 0}",
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xff1E293B))),
                    ],
                  ),
                  const Divider(height: 24, color: Color(0xffE2E8F0)),

                  Expanded(
                    // constraints: const BoxConstraints(maxHeight: 160),
                    child: Scrollbar(
                      controller: cardScrollController, // <--- Local controller
                      thumbVisibility: true,
                      thickness: 3,
                      radius: const Radius.circular(10),
                      child: ListView.separated(
                        controller: cardScrollController, // <--- Wahi local controller yahan bhi
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(right: 12),
                        itemCount: data.items?.length ?? 0,
                        separatorBuilder: (context, i) => Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Colors.grey.withOpacity(0.08),
                          indent: 35,
                        ),
                        itemBuilder: (context, i) {
                          final item = data.items![i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                // --- Index Badge ---
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: const Color(0xff6366F1).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text("${i + 1}",
                                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xff6366F1))),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // --- Item Name ---
                                Expanded(
                                  child: Text(
                                    item.sweetName ?? "-",
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xff334155)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // --- Qty Badge ---
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xff4F46E5), Color(0xff4338CA)], // Deep Indigo
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff4F46E5).withOpacity(0.25),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
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
    );
  }

  void _showChalanDetail(ChalanDataModel data) {
    String shortChalanId = data.chalanId.toString().length > 4 ? data.chalanId.toString().substring(data.chalanId.toString().length - 4) : data.chalanId.toString();
    String shortOrderId = data.orderId.toString().length > 4 ? data.orderId.toString().substring(data.orderId.toString().length - 4) : data.orderId.toString();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // StatefulBuilder loading dikhane ke liye
        builder: (context, setModalState) {
          final isDownloading = downloadingIds.contains(data.chalanId.toString());

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              width: 450,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("CHALAN DETAILS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xff64748B), letterSpacing: 1.5)),
                            const SizedBox(height: 4),
                            Text("ID: #$shortChalanId", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xff1E293B))),
                          ],
                        ),
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded))
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xffF1F5F9), thickness: 2)),
                    _buildModalSection("Order Reference", "Order ID: #$shortOrderId"),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildModalSection("Store", data.shopName ?? "-")),
                        Expanded(child: _buildModalSection("Location", "${data.city}, ${data.state}")),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildModalSection("Transport / Vehicle", data.transportDetails ?? "-"),
                    const SizedBox(height: 24),
                    const Text("ITEMS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xff64748B), letterSpacing: 1.5)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xffE2E8F0))),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(color: Color(0xffF8FAFC), borderRadius: BorderRadius.vertical(top: Radius.circular(11))),
                            child: const Row(
                              children: [
                                Expanded(child: Text("Item Name", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
                                Text("Quantity", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                          ...?data.items?.map((item) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xffE2E8F0)))),
                            child: Row(
                              children: [
                                Expanded(child: Text(item.sweetName ?? "-", style: const TextStyle(fontSize: 13, color: Color(0xff334155)))),
                                Text("${item.quantity} ${item.unit}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xff1E293B))),
                              ],
                            ),
                          )).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // DOWNLOAD BUTTON - UI INTEGRATION
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isDownloading ? null : () => _handleDownload(data, setModalState),
                        icon: isDownloading
                            ? buildShimmerEffectCard(context: context)
                            : const Icon(Icons.download_rounded, size: 18),
                        label: Text(isDownloading ? "DOWNLOADING..." : "DOWNLOAD PDF"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1A2B4C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    )
                  ],
                ),
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
            Icon(icon, size: 12, color: const Color(0xff64748B)), const SizedBox(width: 4),
            Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xff64748B)))]),
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
    // JSON se verification_code nikaal kar pehle hi controller mein daal diya
    print("this is the vericatio_code:-----------${data.verification_code}");
    final otpController = TextEditingController(text: data.verification_code?.toString() ?? "");

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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xffEEF2FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined, color: Color(0xff4F46E5), size: 32),
              ),
              const SizedBox(height: 20),

              const Text(
                "Security Verification",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xff1E293B)),
              ),
              const SizedBox(height: 8),
              const Text(
                "Enter the 6-digit OTP to verify delivery and update stock inventory.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xff64748B), height: 1.5),
              ),

              const SizedBox(height: 24),

              // OTP Input field
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
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xffE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xff4F46E5), width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
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

                        var res = await ApiController.verifyChallanForAutoInv(
                            params: {
                              'chalan_id': data.chalanId,
                              'otp': otpController.text.trim()
                            }
                        );

                        if (res != null && (res['status'] == 0 || res['status'] == "0")) {
                          Navigator.pop(context); // Close OTP Dialog
                          ref.read(master_Provider).fetchChallan(); // Refresh
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(res['msg'] ?? "Inventory Updated!"),
                                backgroundColor: const Color(0xff10B981),
                                behavior: SnackBarBehavior.floating,
                              )
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(res['msg'] ?? "Invalid OTP"),
                                backgroundColor: const Color(0xffEF4444),
                                behavior: SnackBarBehavior.floating,
                              )
                          );
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

