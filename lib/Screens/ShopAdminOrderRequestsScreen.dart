import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants/static.dart';
import '../controllers/api_controller.dart';
import '../models/ShopAdminOrderRequestModel.dart';
// import '../models/shop_admin_order_group_model.dart';
// import '../models/shop_admin_order_request_model.dart';
import '../provider/provider.dart';
import '../widgets/CustomDropDownSearch.dart';

class ShopAdminOrderRequestsScreen extends ConsumerStatefulWidget {
  const ShopAdminOrderRequestsScreen({super.key});

  @override
  ConsumerState<ShopAdminOrderRequestsScreen> createState() =>
      _ShopAdminOrderRequestsScreenState();
}

class _ShopAdminOrderRequestsScreenState
    extends ConsumerState<ShopAdminOrderRequestsScreen> {
  List<String> selectedIds = [];
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(master_Provider).fetchAllRequestOrderByShopAdmin();
      ref.read(master_Provider).fetchSuppliers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  void _toggleGroupSelection(ShopAdminOrderGroupModel group) {
    final pendingItems = (group.requests ?? [])
        .where((e) => e.status?.toString().toUpperCase() == "PENDING")
        .map((e) => e.rowId.toString())
        .toList();

    if (pendingItems.isEmpty) return;

    bool allSelected = pendingItems.every((id) => selectedIds.contains(id));

    setState(() {
      if (allSelected) {
        selectedIds.removeWhere((id) => pendingItems.contains(id));
      } else {
        for (var id in pendingItems) {
          if (!selectedIds.contains(id)) {
            selectedIds.add(id);
          }
        }
      }
    });
  }

  String _formatDateTime(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "N/A";
    DateTime? dt = DateTime.tryParse(rawDate);
    if (dt == null) return rawDate;
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  // --- SEARCH FILTER LOGIC ---
  List<ShopAdminOrderGroupModel> _getFilteredGroups(
      List<ShopAdminOrderGroupModel> groups) {
    if (searchQuery.trim().isEmpty) return groups;

    final q = searchQuery.toLowerCase().trim();
    List<ShopAdminOrderGroupModel> filtered = [];

    for (var grp in groups) {
      final grpTime = _formatDateTime(grp.crOn?.toString() ?? grp.requestGroup?.toString()).toLowerCase();

      final matchingRequests = (grp.requests ?? []).where((req) {
        final sweet = (req.sweetName ?? '').toLowerCase();
        final counter = (req.counterName ?? '').toLowerCase();
        final status = (req.status ?? '').toLowerCase();
        return sweet.contains(q) || counter.contains(q) || status.contains(q);
      }).toList();

      if (matchingRequests.isNotEmpty || grpTime.contains(q)) {
        filtered.add(ShopAdminOrderGroupModel(
          crOn: grp.crOn,
          requestGroup: grp.requestGroup,
          totalRequests: grp.totalRequests,
          totalRequestedQuantity: grp.totalRequestedQuantity,
          totalSuppliedQuantity: grp.totalSuppliedQuantity,
          totalPendingQuantity: grp.totalPendingQuantity,
          requests: matchingRequests.isNotEmpty ? matchingRequests : grp.requests,
        ));
      }
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(master_Provider);
    final List<ShopAdminOrderGroupModel> rawGroups = provider.orderGroups;
    final List<ShopAdminOrderGroupModel> groups = _getFilteredGroups(rawGroups);

    bool isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xffF1F5F9),
      body: provider.loading
          ? buildShimmerEffect(context: context)
          : Column(
        children: [
          _buildTopSearchBar(isMobile),
          Expanded(
            child: groups.isEmpty
                ? _buildEmptyState()
                : Stack(
              children: [
                ListView.builder(
                  itemCount: groups.length,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _buildGroupAccordion(
                        groups[index], isMobile);
                  },
                ),
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                      child: _buildFloatingActionBar(isMobile)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SEARCH BAR ---
  Widget _buildTopSearchBar(bool isMobile) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 24, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xffF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xffE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => searchQuery = val),
                style: const TextStyle(fontSize: 13, color: Color(0xff1E293B)),
                decoration: InputDecoration(
                  hintText: "Search item, counter name, status, or date...",
                  hintStyle: const TextStyle(
                      fontSize: 12, color: Color(0xff94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded,
                      size: 18, color: Color(0xff64748B)),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear_rounded,
                        size: 16, color: Color(0xff64748B)),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => searchQuery = "");
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ACCORDION GROUP CARD ---
  Widget _buildGroupAccordion(ShopAdminOrderGroupModel group, bool isMobile) {
    final requests = group.requests ?? [];
    final pendingRequests = requests
        .where((e) => e.status?.toString().toUpperCase() == "PENDING")
        .toList();

    bool isFullySelected = pendingRequests.isNotEmpty &&
        pendingRequests.every((e) => selectedIds.contains(e.rowId.toString()));

    String formattedDate = _formatDateTime(
        group.crOn?.toString() ?? group.requestGroup?.toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding:
          const EdgeInsets.only(left: 14, right: 14, bottom: 12),
          leading: pendingRequests.isNotEmpty
              ? InkWell(
            onTap: () => _toggleGroupSelection(group),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Icon(
                isFullySelected
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                color: isFullySelected
                    ? const Color(0xff2563EB)
                    : const Color(0xffCBD5E1),
                size: 20,
              ),
            ),
          )
              : const Icon(Icons.schedule_rounded,
              color: Color(0xff94A3B8), size: 18),
          title: Row(
            children: [
              Text(
                formattedDate,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xff0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xffF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${requests.length} Requests",
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff475569)),
                ),
              ),
            ],
          ),
          children: [
            if (!isMobile) _buildTableHeader(),
            ...requests.asMap().entries.map((entry) {
              return _buildRowItem(
                  entry.value, entry.key + 1, isMobile);
            }).toList(),
          ],
        ),
      ),
    );
  }

  // --- DESKTOP TABLE COLUMN HEADERS ---
  Widget _buildTableHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 6, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xffF1F5F9)),
      ),
      child: Row(
        children: const [
          SizedBox(width: 24), // Checkbox align
          SizedBox(
            width: 32,
            child: Text("SR.",
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff64748B))),
          ),
          Expanded(
            flex: 4,
            child: Text("SWEET / ITEM",
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff64748B))),
          ),
          Expanded(
            flex: 3,
            child: Text("COUNTER",
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff64748B))),
          ),
          Expanded(
            flex: 2,
            child: Text("QTY",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff64748B))),
          ),
          Expanded(
            flex: 2,
            child: Text("STATUS",
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff64748B))),
          ),
        ],
      ),
    );
  }

  // --- ROW ITEM ---
  Widget _buildRowItem(
      ShopAdminOrderRequestModel item, int index, bool isMobile) {
    bool isSelected = selectedIds.contains(item.rowId.toString());
    bool isPending = item.status?.toString().toUpperCase() == "PENDING";

    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: InkWell(
        onTap: isPending ? () => _toggleSelection(item.rowId.toString()) : null,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: (isSelected && isPending)
                ? const Color(0xffEFF6FF)
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (isSelected && isPending)
                  ? const Color(0xff93C5FD)
                  : const Color(0xffE2E8F0),
            ),
          ),
          child: isMobile
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildCheckbox(isPending, isSelected),
                  const SizedBox(width: 8),
                  Text("#$index",
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff94A3B8))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.sweetName ?? "-",
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xff0F172A)),
                    ),
                  ),
                  _statusBadge(item.status?.toString() ?? "PENDING"),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Counter: ${item.counterName ?? '-'}",
                    style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xff64748B),
                        fontWeight: FontWeight.w500),
                  ),
                  _buildQtyBadge(item),
                ],
              ),
            ],
          )
              : Row(
            children: [
              _buildCheckbox(isPending, isSelected),
              const SizedBox(width: 8),
              SizedBox(
                width: 24,
                child: Text(
                  "$index.",
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff94A3B8)),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  item.sweetName ?? "-",
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xff0F172A)),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  item.counterName ?? "-",
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff475569),
                      fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(child: _buildQtyBadge(item)),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _statusBadge(
                      item.status?.toString() ?? "PENDING"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(bool isPending, bool isSelected) {
    if (!isPending) {
      return const SizedBox(
        width: 24,
        child: Icon(Icons.check_circle_rounded,
            color: Color(0xff10B981), size: 16),
      );
    }
    return SizedBox(
      width: 24,
      child: Icon(
        isSelected
            ? Icons.check_box_rounded
            : Icons.check_box_outline_blank_rounded,
        color:
        isSelected ? const Color(0xff2563EB) : const Color(0xffCBD5E1),
        size: 18,
      ),
    );
  }

  Widget _buildQtyBadge(ShopAdminOrderRequestModel item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xffF1F5F9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "${item.requestedQuantity ?? 0} ${item.unit ?? ''}",
        style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 11,
            color: Color(0xff334155)),
      ),
    );
  }

  Widget _statusBadge(String label) {
    Color color;
    String text = label.toUpperCase();

    switch (text) {
      case 'PENDING':
        color = const Color(0xffD97706);
        break;
      case 'ACCEPTED':
      case 'APPROVED':
      case 'FINALIZED':
        color = const Color(0xff2563EB);
        break;
      case 'COMPLETED':
      case 'DELIVERED':
        color = const Color(0xff059669);
        break;
      case 'REJECTED':
      case 'CANCELLED':
        color = const Color(0xffDC2626);
        break;
      default:
        color = const Color(0xff64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 9, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }

  // --- REFINED ACTION BAR ---
  Widget _buildFloatingActionBar(bool isMobile) {
    bool show = selectedIds.isNotEmpty;

    return AnimatedSlide(
      offset: show ? Offset.zero : const Offset(0, 2),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Container(
        width: isMobile ? MediaQuery.of(context).size.width - 32 : 460,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xff0F172A),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xff2563EB),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.done_all_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${selectedIds.length} Selected",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
                const Text("Pending processing",
                    style: TextStyle(color: Color(0xff94A3B8), fontSize: 10)),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _openSupplierDialog(),
              icon: const Icon(Icons.send_rounded, size: 14),
              label: const Text("Process Order",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CUSTOM DROPDOWN HELPER AS REQUIRED ---
  Widget _dropdown(String label, List items,
      String Function(dynamic) labelBuilder, Function(dynamic) onSel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 42,
          child: CustomDropdownSearch<dynamic>(
            items: items,
            itemLabelBuilder: labelBuilder,
            compareFn: (a, b) => a.row_id.toString() == b.row_id.toString(),
            onChanged: (val) {
              if (val != null) {
                onSel(val);
              }
            },
            hintText: label,
          ),
        ),
      ],
    );
  }

  // --- SUPPLIER DIALOG ---
  void _openSupplierDialog() {
    if (selectedIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        dynamic selectedSupplier;
        bool isLoading = false;
        String? errorMessage;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final suppliers = ref.read(master_Provider).allSuppliers;

            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              titlePadding: const EdgeInsets.all(16),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Row(
                children: const [
                  Icon(Icons.local_shipping_outlined,
                      color: Color(0xff2563EB), size: 20),
                  SizedBox(width: 8),
                  Text("Assign Supplier",
                      style: TextStyle(
                          color: Color(0xff0F172A),
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Text(errorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 11)),
                      ),
                    const Text("Select a supplier to dispatch these items:",
                        style:
                        TextStyle(fontSize: 12, color: Color(0xff64748B))),
                    const SizedBox(height: 12),
                    _dropdown(
                      "Select Supplier",
                      suppliers,
                          (item) =>
                      "${item.supplier_name.toString().toUpperCase()} (${item.phone ?? 'No Contact'})",
                          (val) {
                        setDialogState(() {
                          selectedSupplier = val;
                          errorMessage = null;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Text("Total Selected Items: ${selectedIds.length}",
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff475569))),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.all(16),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text("Cancel",
                      style: TextStyle(color: Color(0xff64748B), fontSize: 12)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: (isLoading || selectedSupplier == null)
                      ? null
                      : () async {
                    setDialogState(() {
                      isLoading = true;
                      errorMessage = null;
                    });

                    try {
                      var res = await ApiController
                          .createFinalOrderByShopAdmin(
                        context: context,
                        params: {
                          "supplier_id": selectedSupplier.row_id.toString(),
                          "request_ids": List.from(selectedIds),
                        },
                      );

                      if (res['status'] == 0) {
                        setState(() => selectedIds.clear());
                        if (context.mounted) Navigator.of(context).pop();

                        ref
                            .read(master_Provider)
                            .fetchAllRequestOrderByShopAdmin();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xff10B981),
                            content: Text("Order processed successfully"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        setDialogState(() {
                          isLoading = false;
                          errorMessage = res['msg'] ?? "Process failed.";
                        });
                      }
                    } catch (e) {
                      setDialogState(() {
                        isLoading = false;
                        errorMessage = "Network error occurred.";
                      });
                    }
                  },
                  child: isLoading
                      ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : const Text("Confirm & Send",
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_rounded, size: 48, color: Color(0xffCBD5E1)),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? "No items match your search"
                : "No order requests found",
            style: const TextStyle(
                color: Color(0xff64748B),
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}