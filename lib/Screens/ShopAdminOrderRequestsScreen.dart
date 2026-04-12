import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants/static.dart';
import '../controllers/api_controller.dart';
import '../provider/provider.dart';

class ShopAdminOrderRequestsScreen extends ConsumerStatefulWidget {
  const ShopAdminOrderRequestsScreen({super.key});

  @override
  ConsumerState<ShopAdminOrderRequestsScreen> createState() => _ShopAdminOrderRequestsScreenState();
}

class _ShopAdminOrderRequestsScreenState extends ConsumerState<ShopAdminOrderRequestsScreen> {
  List<String> selectedIds = [];

  @override
  void initState() {
    super.initState();
    myorders();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(master_Provider).fetchAllRequestOrderByShopAdmin();
      ref.read(master_Provider).fetchSuppliers();
    });
  }


  myorders() async{
    await ApiController.trackOrderStatusShopAdminSendToSupplier();
  }

  void _toggleSelection(String id) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
      } else {
        selectedIds.add(id);
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(master_Provider);
    final requests = provider.orderRequest;
    const navy = Color(0xff1A2B4C);
    const accentGold = Color(0xffD4AF37);
    bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      // appBar: AppBar(
      //   title: const Text("Order Requests",style: TextStyle(color: navy, fontWeight: FontWeight.w900, fontSize: 18)),
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   bottom: PreferredSize(
      //     preferredSize: const Size.fromHeight(1),
      //     child: Container(color: Colors.grey.withOpacity(0.1), height: 1),
      //   ),
      // ),
      body: provider.loading ? buildShimmerEffect(context: context) : requests.isEmpty
          ? _buildEmptyState()
          : Container(
        margin: EdgeInsets.only(top: 10),
            child: Column(
                    children: [

            _buildHeader(isMobile),


            Expanded(
              child: ListView.builder(
                itemCount: requests.length,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = requests[index];
                  bool isSelected = selectedIds.contains(item.rowId.toString());

                  // --- STAGGERED FADE-IN ANIMATION ---
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + (index * 100)), // Ek-ek karke aayenge
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)), // Niche se upar slide
                          child: child,
                        ),
                      );
                    },
                    child: _buildDataRow(item, index, isSelected, isMobile, navy),
                  );
                },
              ),
            ),
                    ],
                  ),
          ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildAnimatedActionBar(navy),

    );
  }



  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xffF1F5F9))),
      ),
      child: Row(
        children: [
          _headerCell("", 1), // Checkbox
          _headerCell("SR.", 1),
          _headerCell("SWEET NAME", 4),
          _headerCell("COUNTER", 3),
          // Alignment match karne ke liye header ko bhi center kiya
          Expanded(flex: 3, child: Text("QTY", textAlign: TextAlign.center, style: _headerStyle())),
          if (!isMobile) _headerCell("ORDERED AT", 3),
          Expanded(flex: 2, child: Text("STATUS", textAlign: TextAlign.center, style: _headerStyle())),
        ],
      ),
    );
  }


// Helper for consistent header text style
  TextStyle _headerStyle() => const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xff64748B), letterSpacing: 1);


  Widget _buildDataRow(item, int index, bool isSelected, bool isMobile, Color navy) {
    DateTime? dt = DateTime.tryParse(item.crOn.toString());
    String timeStr = dt != null ? DateFormat('dd MMM, hh:mm a').format(dt) : "-";

    // Logic: Sirf PENDING status wale hi select ho sakte hain
    bool isPending = item.status?.toUpperCase() == "PENDING";

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        // Agar pending nahi hai toh click disable (null)
        onTap: isPending ? () => _toggleSelection(item.rowId.toString()) : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            // Background blue sirf tabhi dikhe jab item pending HO aur selected HO
            color: (isSelected && isPending) ? Colors.blue.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isSelected && isPending) ? Colors.blue.withOpacity(0.3) : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity((isSelected && isPending) ? 0.05 : 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              // 1. Checkbox / Verified Icon
              Expanded(
                flex: 1,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isPending
                      ? Icon(
                    isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                    key: ValueKey("check_$isSelected"),
                    color: isSelected ? const Color(0xff4F46E5) : Colors.grey[300],
                    size: 20,
                  )
                      : const Icon(
                    Icons.verified_rounded, // Dusre statuses ke liye done icon
                    key: ValueKey("done"),
                    color: Color(0xff10B981),
                    size: 20,
                  ),
                ),
              ),
              // 2. SR No
              Expanded(
                flex: 1,
                child: Text("${index + 1}", style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              // 3. Sweet Name
              Expanded(
                flex: 4,
                child: Text(item.sweetName ?? "-", maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xff1E293B))),
              ),
              // 4. Counter Name
              Expanded(
                flex: 3,
                child: Text(item.counterName ?? "-", maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.blueGrey[600], fontWeight: FontWeight.w500)),
              ),
              // 5. Quantity Badge
              Expanded(
                flex: 3,
                child: UnconstrainedBox(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xffF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xffE2E8F0)),
                    ),
                    child: Text(
                      "${item.quantity} ${item.unit}",
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xff475569)),
                    ),
                  ),
                ),
              ),
              // 6. Time
              if (!isMobile)
                Expanded(flex: 3, child: Text(timeStr, style: TextStyle(fontSize: 13, color: Colors.blueGrey[600], fontWeight: FontWeight.w500))),
              // 7. Status
              Expanded(
                flex: 2,
                child: _statusBadge(item.status ?? "PENDING"),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _statusBadge(String label) {
    Color statusColor;
    String statusText = label.toUpperCase();

    switch (statusText) {
      case 'PENDING':
        statusColor = Colors.orange;
        break;
      case 'ACCEPTED':
      case 'APPROVED':
      case 'ASSIGNED':
      case 'FINALIZED':
        statusColor = const Color(0xff4F46E5); // Indigo
        break;
      case 'DISPATCHED':
        statusColor = Colors.cyan;
        break;
      case 'DELIVERED':
      case 'COMPLETED':
      case 'RECEIVED':
        statusColor = const Color(0xff10B981); // Green
        break;
      case 'REJECTED':
      case 'CANCELLED':
        statusColor = Colors.redAccent;
        break;
      default:
        statusColor = Colors.blueGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5), // Same alignment
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
      ),
      child: Text(
        statusText,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: statusColor, letterSpacing: 0.5),
      ),
    );
  }



  Widget _headerCell(String label, int flex) {
    return Expanded(
      flex: flex,
      child: Text(label, style: _headerStyle()),
    );
  }



  // --- ANIMATED ACTION BAR (POPS UP SMOOTHLY) ---
  Widget _buildAnimatedActionBar(Color navy) {
    return AnimatedScale(
      scale: selectedIds.isNotEmpty ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      // curve: Curves.backOut,
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: navy,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: navy.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Row(
          children: [
            const SizedBox(width: 15),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${selectedIds.length} ITEMS", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                const Text("Ready for approval", style: TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (selectedIds.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please Select Items First"), behavior: SnackBarBehavior.floating),
                  );
                  return;
                }

                showDialog(
                  context: context,
                  builder: (context) {
                    String? selectedSupplierId;
                    bool isLoading = false; // Local loading state
                    String? errorMessage;   // Local error state

                    return StatefulBuilder(
                      builder: (context, setDialogState) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          surfaceTintColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          titlePadding: EdgeInsets.zero,
                          contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 10),

                          title: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            decoration: const BoxDecoration(
                              color: Color(0xffF5F7FF),
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.person_pin_rounded, color: Color(0xff4F46E5), size: 22),
                                const SizedBox(width: 12),
                                const Text("Select Supplier", style: TextStyle(color: Color(0xff1E293B), fontSize: 16, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),

                          content: SizedBox(
                            width: 420,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // --- ERROR MESSAGE BOX ---
                                if (errorMessage != null)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 15),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red[100]!)),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline, color: Colors.red, size: 18),
                                        const SizedBox(width: 10),
                                        Expanded(child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600))),
                                      ],
                                    ),
                                  ),

                                const Text("Choose a supplier to process this order.", style: TextStyle(fontSize: 13, color: Color(0xff64748B))),
                                const SizedBox(height: 20),

                                // --- DROPDOWN ---
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xffE2E8F0), width: 1.5),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      hint: const Text("Select Supplier", style: TextStyle(fontSize: 14, color: Colors.grey)),
                                      value: selectedSupplierId,
                                      dropdownColor: Colors.white,
                                      icon: const Icon(Icons.unfold_more_rounded, color: Color(0xff4F46E5)),
                                      itemHeight: 65,
                                      items: ref.read(master_Provider).allSuppliers.map((sup) {
                                        return DropdownMenuItem<String>(
                                          value: sup.row_id.toString(),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(sup.supplier_name.toString().toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xff1E293B))),
                                              const SizedBox(height: 2),
                                              Text("📞 ${sup.phone ?? 'No Contact'}", style: const TextStyle(fontSize: 10, color: Color(0xff64748B), fontWeight: FontWeight.w500)),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: isLoading ? null : (val) => setDialogState(() {
                                        selectedSupplierId = val;
                                        errorMessage = null;
                                      }),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: const Color(0xffF8FAFC), borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.inventory_2_outlined, size: 16, color: Color(0xff64748B)),
                                      const SizedBox(width: 10),
                                      Text("Total Items: ${selectedIds.length}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xff475569))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          actionsPadding: const EdgeInsets.fromLTRB(0, 0, 20, 20),
                          actions: [
                            TextButton(
                              onPressed: isLoading ? null : () => Navigator.pop(context),
                              child: const Text("Cancel", style: TextStyle(color: Color(0xff94A3B8), fontSize: 14, fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff4F46E5),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                minimumSize: const Size(180, 50), // Fixed size for loader stability
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: (isLoading || selectedSupplierId == null) ? null : () async {
                                setDialogState(() {
                                  isLoading = true;
                                  errorMessage = null;
                                });

                                try {
                                  var res = await ApiController.createFinalOrderByShopAdmin(
                                      context: context,
                                      params: {
                                        "supplier_id": selectedSupplierId,
                                        "request_ids": List.from(selectedIds),
                                      }
                                  );

                                  if (res['status'] == 0) {
                                    setState(() => selectedIds.clear());

                                    // Pehle Pop Phir Snackbar
                                    if (context.mounted) Navigator.of(context).pop();

                                    ref.read(master_Provider).fetchAllRequestOrderByShopAdmin();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Color(0xff10B981),
                                          behavior: SnackBarBehavior.floating,
                                          content: Text("🚀 Order Placed Successfully!"),
                                          duration: Duration(seconds: 2),
                                        )
                                    );
                                  } else {
                                    setDialogState(() {
                                      isLoading = false;
                                      errorMessage = res['msg'] ?? "Process failed. Try again.";
                                    });
                                  }
                                } catch (e) {
                                  setDialogState(() {
                                    isLoading = false;
                                    errorMessage = "Network Error. Please check connection.";
                                  });
                                }
                              },
                              child: isLoading
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text("Confirm & Place Order", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffD4AF37),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("APPROVE & FINALIZE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
          Icon(Icons.auto_awesome_motion_rounded, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          // const Text("Inbox is clear!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          Text("No order requests found", style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }
}