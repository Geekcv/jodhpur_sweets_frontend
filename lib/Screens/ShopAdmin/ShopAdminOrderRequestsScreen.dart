import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../constants/static.dart';
import '../../controllers/api_controller.dart';
import '../../models/ShopAdminOrderRequestModel.dart';
import '../../provider/provider.dart';


class ShopAdminOrderRequestsScreen extends ConsumerStatefulWidget {
  const ShopAdminOrderRequestsScreen({super.key});

  @override
  ConsumerState<ShopAdminOrderRequestsScreen> createState() => _ShopAdminOrderRequestsScreenState();
}

class _ShopAdminOrderRequestsScreenState extends ConsumerState<ShopAdminOrderRequestsScreen> {
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
    final pendingItems = (group.requests ?? []).where((e) {
      String reqStatus = (e.requestStatus ?? e.status ?? "PENDING").toString().toUpperCase();
      return reqStatus == "PENDING";
    }).map((e) => e.rowId.toString()).toList();

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
        return sweet.contains(q) || counter.contains(q) || reqId.contains(q) || status.contains(q);
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

  // Helper to get selected items list for dialog
  List<ShopAdminOrderRequestModel> _getSelectedItemsList(List<ShopAdminOrderGroupModel> groups) {
    List<ShopAdminOrderRequestModel> selectedItems = [];
    for (var grp in groups) {
      for (var req in (grp.requests ?? [])) {
        if (selectedIds.contains(req.rowId.toString())) {
          selectedItems.add(req);
        }
      }
    }
    return selectedItems;
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
                _buildHeaderSection(isMobile, rawGroups),
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
  Widget _buildHeaderSection(bool isMobile, List<ShopAdminOrderGroupModel> groups) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Counter Requests", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: primaryNavy, letterSpacing: -0.5,)),
            SizedBox(height: 2),
            Text("Review and forward counter requests to suppliers", style: TextStyle(fontSize: 12, color: slateSub)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: selectedIds.isEmpty ? null : () => _openSupplierDialog(groups),
          icon: const Icon(Icons.send_rounded, size: 14),
          label: Text("Send to Supplier (${selectedIds.length})"),
          style: ElevatedButton.styleFrom(
            backgroundColor: accentBlue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xff94A3B8),
            disabledForegroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

    final pendingRequests = requests.where((e) {
      String reqStatus = (e.requestStatus ?? e.status ?? "PENDING").toString().toUpperCase();
      return reqStatus == "PENDING";
    }).toList();

    // Check if group has pending requests
    bool hasPendingRequests = pendingRequests.isNotEmpty;
    bool isFullySelected = hasPendingRequests && pendingRequests.every((e) => selectedIds.contains(e.rowId.toString()));

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
          // Agr pending request hai toh Open rkho, agar koi pending nahi hai toh Close rkho
          initiallyExpanded: hasPendingRequests,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          title: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Counter Request", style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: primaryNavy,
                  ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDateTime(group.crOn?.toString() ?? group.requestGroup?.toString()),
                    style: const TextStyle(fontSize: 11, color: slateSub),
                  ),
                ],
              ),
              // Header Stats Badges
              Wrap(
                spacing: 10,
                runSpacing: 6,
                children: [
                  _headerMetaBadge("Items", "${group.totalRequests ?? requests.length}", const Color(0xff475569)),
                  _headerMetaBadge("Req Qty", "${group.totalRequestedQuantity ?? 0}", const Color(0xff2563EB)),
                  _headerMetaBadge("Supplied Qty", "${group.totalSuppliedQuantity ?? 0}", const Color(0xff16A34A)),
                  _headerMetaBadge("Pending Qty", "${group.totalPendingQuantity ?? 0}", const Color(0xffD97706)),
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
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFullySelected
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          size: 18,
                          color: accentBlue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isFullySelected
                              ? "Deselect All Pending (${pendingRequests.length})"
                              : "Select All Pending (${pendingRequests.length})",
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: accentBlue,
                          ),
                        ),
                      ],
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

  Widget _headerMetaBadge(String label, String value, Color themeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: themeColor.withOpacity(0.2), width: 0.8),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 10.5, fontFamily: 'sans-serif'),
          children: [
            TextSpan(
              text: "$label: ",
              style: TextStyle(color: themeColor.withOpacity(0.9), fontWeight: FontWeight.w500),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: themeColor, fontWeight: FontWeight.w700),
            ),
          ],
        ),
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
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 138,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        bool isSelected = selectedIds.contains(item.rowId.toString());

        String reqStatus = (item.requestStatus ?? item.status ?? "PENDING").toString().toUpperCase();
        String itemStat = (item.itemStatus ?? "PENDING").toString().toUpperCase();

        bool isPending = reqStatus == "PENDING";

        return InkWell(
          onTap: isPending ? () => _toggleSelection(item.rowId.toString()) : null,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xffEFF6FF) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? const Color(0xff2563EB) : const Color(0xffE2E8F0),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildCheckbox(isPending, isSelected),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.sweetName ?? "-",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff0F172A),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "${item.requestedOrder ?? 'REQ'} • ${item.counterName ?? '-'}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${item.requestedQuantity ?? 0} ${item.unit ?? ''}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xff0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              _statusBadgeUI("REQ: $reqStatus", _getReqStatusColor(reqStatus)),
                            ],
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Color(0xffE2E8F0),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _statusBadgeUI("SUPPLIER: $itemStat", _getItemStatusColor(itemStat)),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 11, color: Color(0xff475569)),
                              children: [
                                const TextSpan(text: "Supplied: "),
                                TextSpan(
                                  text: "${item.suppliedQuantity ?? 0}",
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xff16A34A)),
                                ),
                                const TextSpan(text: " | Pending: "),
                                TextSpan(
                                  text: "${item.pendingQuantity ?? 0} ${item.unit ?? ''}",
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xffD97706)),
                                ),
                              ],
                            ),
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
      },
    );
  }

  Widget _statusBadgeUI(String fullText, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: statusColor.withOpacity(0.25), width: 0.8),
      ),
      child: Text(
        fullText,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: statusColor,
        ),
      ),
    );
  }

  Color _getReqStatusColor(String status) {
    switch (status) {
      case 'APPROVED':
        return const Color(0xff16A34A);
      case 'REJECTED':
        return const Color(0xffDC2626);
      case 'PENDING':
      default:
        return const Color(0xffD97706);
    }
  }

  Color _getItemStatusColor(String status) {
    switch (status) {
      case 'ACCEPTED':
        return const Color(0xff0D9488);
      case 'PARTIAL':
        return const Color(0xffEA580C);
      case 'REJECTED':
        return const Color(0xffDC2626);
      case 'PENDING':
      default:
        return const Color(0xff2563EB);
    }
  }

  // --- LIST ROW VIEW ---
  Widget _buildListRowLayout(List<ShopAdminOrderRequestModel> items, bool isMobile) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        bool isSelected = selectedIds.contains(item.rowId.toString());

        String reqStatus = (item.requestStatus ?? item.status ?? "PENDING").toString().toUpperCase();
        String itemStat = (item.itemStatus ?? "PENDING").toString().toUpperCase();

        bool isPending = reqStatus == "PENDING";

        return InkWell(
          onTap: isPending ? () => _toggleSelection(item.rowId.toString()) : null,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xffEFF6FF) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? const Color(0xff2563EB) : const Color(0xffE2E8F0),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildCheckbox(isPending, isSelected),
                const SizedBox(width: 12),

                Expanded(
                  flex: isMobile ? 4 : 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.sweetName ?? "-",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "${item.requestedOrder ?? 'REQ'} • ${item.counterName ?? '-'}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  flex: isMobile ? 4 : 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Req: ${item.requestedQuantity ?? 0} ${item.unit ?? ''}",
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: const TextStyle(fontSize: 10.5, color: Color(0xff475569)),
                          children: [
                            const TextSpan(text: "Supplied: "),
                            TextSpan(
                              text: "${item.suppliedQuantity ?? 0}",
                              style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xff16A34A)),
                            ),
                            const TextSpan(text: " | Pending: "),
                            TextSpan(
                              text: "${item.pendingQuantity ?? 0}",
                              style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xffD97706)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _statusBadgeUI("REQ: $reqStatus", _getReqStatusColor(reqStatus)),
                    const SizedBox(height: 4),
                    _statusBadgeUI("SUPPLIER: $itemStat", _getItemStatusColor(itemStat)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckbox(bool isPending, bool isSelected) {
    if (!isPending) {
      return const Icon(
        Icons.verified_rounded,
        color: Color(0xFF10B981),
        size: 18,
      );
    }

    return Icon(
      isSelected
          ? Icons.task_alt_rounded
          : Icons.radio_button_off_rounded,
      color: isSelected ? accentBlue : const Color(0xFFCBD5E1),
      size: 20,
    );
  }


  // --- CONFIRM & SEND TO SUPPLIER MODAL DIALOG ---
  void _openSupplierDialog(List<ShopAdminOrderGroupModel> rawGroups) {
    if (selectedIds.isEmpty) return;

    final selectedItems = _getSelectedItemsList(rawGroups);

    showDialog(
      context: context,
      builder: (context) {
        bool isLoading = false;
        String? errorMessage;

        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                    "Confirm Order Request",
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
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Review selected items before forwarding to supplier:",
                      style: TextStyle(fontSize: 12, color: slateSub),
                    ),
                    const SizedBox(height: 12),

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

                    // DIRECT SELECTED ITEMS LIST
                    Container(
                      constraints: const BoxConstraints(maxHeight: 250),
                      decoration: BoxDecoration(
                        color: const Color(0xffF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderCol),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: selectedItems.length,
                        separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: borderCol),
                        itemBuilder: (context, index) {
                          final item = selectedItems[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.sweetName ?? "-",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: primaryNavy,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "${item.requestedOrder ?? 'REQ'} • ${item.counterName ?? '-'}",
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          color: slateSub,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: accentBlue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "${item.requestedQuantity ?? 0} ${item.unit ?? ''}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                      color: accentBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        onPressed: isLoading
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
                                      "Order sent to supplier successfully"),
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
                            : const Icon(Icons.send_rounded, size: 16),
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