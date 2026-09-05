import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../constants/static.dart';
import '../../controllers/api_controller.dart';
import '../../models/ShopAdminOrderRequestModel.dart';
import '../../provider/provider.dart';
import '../../widgets/CustomDropDownSearch.dart';


class ShopAdminOrderRequestsScreen extends ConsumerStatefulWidget {
  const ShopAdminOrderRequestsScreen({super.key});

  @override
  ConsumerState<ShopAdminOrderRequestsScreen> createState() =>
      _ShopAdminOrderRequestsScreenState();
}

class _ShopAdminOrderRequestsScreenState
    extends ConsumerState<ShopAdminOrderRequestsScreen> {
  static const Color primaryNavy = Color(0xff0F172A);
  static const Color slateSub = Color(0xff64748B);
  static const Color borderCol = Color(0xffE2E8F0);
  static const Color accentBlue = Color(0xff2563EB);

  List<String> selectedIds = [];
  String searchQuery = "";
  bool isCardView = true;
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
    final pendingItems = (group.requests ?? []).where((e) => (e.status == null || e.status.toString().toUpperCase() == "PENDING")).map((e) => e.rowId.toString()).toList();

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
    return DateFormat('dd-MM-yyyy hh:mm a').format(dt);
  }

  List<ShopAdminOrderGroupModel> _getFilteredGroups(List<ShopAdminOrderGroupModel> groups) {
    if (searchQuery.trim().isEmpty) return groups;

    final q = searchQuery.toLowerCase().trim();
    List<ShopAdminOrderGroupModel> filtered = [];

    for (var grp in groups) {
      final grpTime = (grp.requestGroup ?? grp.crOn ?? '').toString().toLowerCase();

      final matchingRequests = (grp.requests ?? []).where((req) {
        final sweet = (req.sweetName ?? '').toLowerCase();
        final counter = (req.counterName ?? '').toLowerCase();
        final reqId = (req.requestedOrder ?? '').toLowerCase();
        final status = (req.status ?? 'pending').toLowerCase();
        return sweet.contains(q) ||
            counter.contains(q) ||
            reqId.contains(q) ||
            status.contains(q);
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
    final List<ShopAdminOrderGroupModel> rawGroups = provider.orderGroups ?? [];
    final List<ShopAdminOrderGroupModel> groups = _getFilteredGroups(rawGroups);

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          bool isMobile = width < 768;

          return provider.loading
              ? buildShimmerEffect(context: context)
              : Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeaderSection(isMobile),
                const SizedBox(height: 16),

                // Control Toolbar (Search Bar + View Toggle)
                _buildControlHeader(isMobile),
                const SizedBox(height: 16),

                // Order Requests List
                Expanded(
                  child: groups.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                    itemCount: groups.length,
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildGroupAccordion(
                          groups[index], width, isMobile);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- HEADER SECTION ---
  Widget _buildHeaderSection(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Counter Requests",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: primaryNavy,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Review and forward counter requests to suppliers",
              style: TextStyle(fontSize: 12, color: slateSub),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: selectedIds.isEmpty ? null : () => _openSupplierDialog(),
          icon: const Icon(Icons.send_rounded, size: 14),
          label: Text("Send to Supplier (${selectedIds.length})"),
          style: ElevatedButton.styleFrom(
            backgroundColor: accentBlue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xff94A3B8),
            disabledForegroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 18, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  // --- CONTROL TOOLBAR ---
  Widget _buildControlHeader(bool isMobile) {
    Widget searchBar = SizedBox(
      width: isMobile ? double.infinity : 320,
      height: 38,
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => searchQuery = val),
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          isDense: true,
          hintText: "Search by sweet name, REQ ID...",
          hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          prefixIcon: const Icon(Icons.search, size: 16, color: slateSub),
          suffixIcon: searchQuery.isNotEmpty
              ? InkWell(
            onTap: () {
              _searchController.clear();
              setState(() => searchQuery = "");
            },
            child: const Icon(Icons.clear, size: 14, color: Colors.grey),
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderCol),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: accentBlue),
          ),
        ),
      ),
    );

    Widget viewToggleIcons = Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderCol),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _viewToggleButton(
            Icons.grid_view_rounded,
            isCardView,
                () => setState(() => isCardView = true),
          ),
          const SizedBox(width: 2),
          _viewToggleButton(
            Icons.format_list_bulleted_rounded,
            !isCardView,
                () => setState(() => isCardView = false),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          searchBar,
          const SizedBox(height: 10),
          viewToggleIcons,
        ],
      );
    }

    return Row(
      children: [
        searchBar,
        const SizedBox(width: 12),
        viewToggleIcons,
      ],
    );
  }

  Widget _viewToggleButton(IconData icon, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? accentBlue : slateSub,
        ),
      ),
    );
  }

  // --- ACCORDION GROUP CARD ---
  Widget _buildGroupAccordion(ShopAdminOrderGroupModel group, double screenWidth, bool isMobile) {
    final requests = group.requests ?? [];
    final pendingRequests = requests.where((e) => (e.status == null || e.status.toString().toUpperCase() == "PENDING")).toList();
    bool isFullySelected = pendingRequests.isNotEmpty && pendingRequests.every((e) => selectedIds.contains(e.rowId.toString()));

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          title: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // "Counter Request Batch: ${_formatDateTime(group.requestGroup ?? group.crOn?.toString())}",
                    "Counter Request",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDateTime(group.crOn?.toString() ?? group.requestGroup),
                    style: const TextStyle(fontSize: 11, color: slateSub),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _metaText("Total Items:", "${group.totalRequests ?? requests.length}"),
                  const SizedBox(width: 12),
                  _metaText("Total Requested Qty:", "${group.totalRequestedQuantity ?? 0}"),
                  const SizedBox(width: 12),
                  _metaText("Total Pending Qty:", "${group.totalPendingQuantity ?? 0}", color: Colors.orange.shade800),
                ],
              ),
            ],
          ),
          children: [
            const Divider(height: 1, color: borderCol),
            const SizedBox(height: 12),

            // Inner Request Content View
            isCardView
                ? _buildGridCardLayout(requests, screenWidth)
                : _buildListRowLayout(requests, isMobile),

            if (pendingRequests.isNotEmpty) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => _toggleGroupSelection(group),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      isFullySelected ? "✓ Select All (selected)" : "Select All Pending",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accentBlue,
                      ),
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _metaText(String label, String value, {Color color = primaryNavy}) {
    return Text.rich(
      TextSpan(
        text: "$label ",
        style: const TextStyle(fontSize: 11, color: slateSub),
        children: [
          TextSpan(
            text: value,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  // --- GRID CARDS VIEW ---
  Widget _buildGridCardLayout(List<ShopAdminOrderRequestModel> items, double screenWidth) {
    int crossAxisCount = 1;
    if (screenWidth >= 1200) {
      crossAxisCount = 3;
    } else if (screenWidth >= 768) {
      crossAxisCount = 2;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 90,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        bool isSelected = selectedIds.contains(item.rowId.toString());
        bool isPending = (item.status == null || item.status.toString().toUpperCase() == "PENDING");

        return InkWell(
          onTap: isPending ? () => _toggleSelection(item.rowId.toString()) : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xffEFF6FF) : const Color(0xffF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? accentBlue : borderCol,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                _buildCheckbox(isPending, isSelected),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.sweetName ?? "-",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: primaryNavy),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${item.requestedOrder ?? 'REQ'} • ${item.counterName ?? ''}",
                        style: const TextStyle(fontSize: 11, color: slateSub),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${item.requestedQuantity ?? 0} ${item.unit ?? ''}",
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primaryNavy),
                    ),
                    const SizedBox(height: 4),
                    _statusBadge(item.status, item.pendingQuantity),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- LIST ROW VIEW ---
  Widget _buildListRowLayout(
      List<ShopAdminOrderRequestModel> items, bool isMobile) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        bool isSelected = selectedIds.contains(item.rowId.toString());
        bool isPending =
        (item.status == null || item.status.toString().toUpperCase() == "PENDING");

        return InkWell(
          onTap: isPending ? () => _toggleSelection(item.rowId.toString()) : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xffEFF6FF) : const Color(0xffF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? accentBlue : const Color(0xffF1F5F9),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                _buildCheckbox(isPending, isSelected),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.sweetName ?? "-",
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: primaryNavy),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.requestedOrder ?? "-",
                        style: const TextStyle(fontSize: 11, color: slateSub),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    item.counterName ?? "-",
                    style: const TextStyle(fontSize: 12, color: slateSub),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "${item.requestedQuantity ?? 0} ${item.unit ?? ''}",
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryNavy),
                  ),
                ),
                _statusBadge(item.status, item.pendingQuantity),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckbox(bool isPending, bool isSelected) {
    // Completed / Processed Status
    if (!isPending) {
      return const Icon(
        Icons.verified_rounded, // Pure solid badge icon
        color: Color(0xFF10B981),
        size: 18,
      );
    }

    // Pending Selection Status
    return Icon(
      isSelected
          ? Icons.task_alt_rounded // Clean round-check for selection
          : Icons.radio_button_off_rounded, // Smooth border ring for unselected
      color: isSelected ? accentBlue : const Color(0xFFCBD5E1),
      size: 20,
    );
  }

  // --- STATUS BADGE ---
  Widget _statusBadge(dynamic statusVal, dynamic pendingQty) {
    String text = (statusVal == null || statusVal.toString().isEmpty) ? "Pending" : statusVal.toString();

    Color bg = const Color(0xffFEF3C7);
    Color textCol = const Color(0xffD97706);

    String uppercase = text.toUpperCase();
    if (uppercase == "ACCEPTED" || uppercase == "APPROVED") {
      bg = const Color(0xffDCFCE7);
      textCol = const Color(0xff16A34A);
      text = "Approved";
    } else if (uppercase == "REJECTED") {
      bg = const Color(0xffFEE2E2);
      textCol = const Color(0xffDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        // pendingQty != null ? "$text  P: $pendingQty" : text,
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: textCol),
      ),
    );
  }

  // --- SUPPLIER MODAL DIALOG ---
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
            final suppliers = ref.read(master_Provider).allSuppliers ?? [];

            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Send to Supplier",
                    style: TextStyle(
                      color: primaryNavy,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 18, color: slateSub),
                  )
                ],
              ),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${selectedIds.length} request(s) selected",
                      style: const TextStyle(fontSize: 12, color: slateSub),
                    ),
                    const SizedBox(height: 16),
                    if (errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 11),
                        ),
                      ),
                    const Text(
                      "Select Supplier",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryNavy),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 40,
                      child: CustomDropdownSearch<dynamic>(
                        items: suppliers,
                        itemLabelBuilder: (item) =>
                        "${item.supplier_name ?? item.name ?? '-'} (${item.phone ?? 'No Contact'})",
                        compareFn: (a, b) =>
                        a.row_id.toString() == b.row_id.toString(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedSupplier = val;
                            errorMessage = null;
                          });
                        },
                        hintText: "—",
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xff93C5FD),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
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
                                "supplier_id":
                                selectedSupplier.row_id.toString(),
                                "request_ids": List.from(selectedIds),
                              },
                            );

                            if (res['status'] == 0) {
                              setState(() => selectedIds.clear());
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }

                              ref
                                  .read(master_Provider)
                                  .fetchAllRequestOrderByShopAdmin();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Color(0xff10B981),
                                  content: Text(
                                      "Order processed successfully"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              setDialogState(() {
                                isLoading = false;
                                errorMessage =
                                    res['msg'] ?? "Process failed.";
                              });
                            }
                          } catch (e) {
                            setDialogState(() {
                              isLoading = false;
                              errorMessage = "Network error occurred.";
                            });
                          }
                        },
                        icon: isLoading
                            ? const SizedBox.shrink()
                            : const Icon(Icons.local_shipping_outlined, size: 16),
                        label: isLoading
                            ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                            : const Text(
                          "Send to Supplier",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        side: const BorderSide(color: borderCol),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed:
                      isLoading ? null : () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: primaryNavy, fontSize: 12),
                      ),
                    ),
                  ],
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
          const Icon(Icons.inbox_rounded, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? "No items match your search"
                : "No order requests found",
            style: const TextStyle(
                color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}