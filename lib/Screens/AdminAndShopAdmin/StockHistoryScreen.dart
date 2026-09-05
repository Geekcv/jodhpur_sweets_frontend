import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../constants/static.dart';
import '../../models/StockHistoryModel.dart';
import '../../provider/provider.dart';
import '../../widgets/TextInputField.dart';

class StockHistoryScreen extends ConsumerStatefulWidget {
  const StockHistoryScreen({super.key});

  @override
  ConsumerState<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends ConsumerState<StockHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(master_Provider).fetchStockHistory());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final Color primaryDark = const Color(0xff1A2B4C), borderCol = const Color(0xffE2E8F0);

  String _formatDate(dynamic dateVal) {
    if (dateVal == null) return "-";
    try {
      return DateFormat('dd-MM-yyyy').format(dateVal is DateTime ? dateVal : DateTime.parse(dateVal.toString()));
    } catch (_) { return dateVal.toString(); }
  }

  @override
  Widget build(BuildContext context) {
    final masterProv = ref.watch(master_Provider);

    final filteredList = masterProv.stockHistoryData.where((item) {
      final q = _searchQuery.toLowerCase().trim();
      if (q.isEmpty) return true;
      return (item.shop_name ?? "").toLowerCase().contains(q) ||
          (item.sweet_name ?? "").toLowerCase().contains(q) ||
          (item.counter_name ?? "").toLowerCase().contains(q) ||
          (item.transaction_type ?? "").toLowerCase().contains(q) ||
          (item.transaction_id ?? "").toLowerCase().contains(q);
    }).toList();

    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 800;
      return Scaffold(
        backgroundColor: const Color(0xffF8FAFC),
        body: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isMobile),
              const SizedBox(height: 16),
              Expanded(child: _buildHistoryTable(filteredList, isMobile)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Activity Logs", style: TextStyle(fontSize: isMobile ? 16 : 20, fontWeight: FontWeight.w900, color: primaryDark)),
              const SizedBox(height: 6),
              Text("Track every stock movement", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
        SizedBox(
          width: isMobile ? 180 : 270,
          height: 38,
          child: CustomTextInput(
            hintText: "Search shop, item...",
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

  Widget _buildHistoryTable(List<StockHistoryModel> data, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderCol),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
            decoration: BoxDecoration(color: primaryDark.withOpacity(0.05), borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
            child: Row(
              children: [
                _hCell("SR.", 1),
                _hCell("SHOP NAME", 4),
                _hCell("ITEM NAME", 4),
                _hCell("TYPE", 2, isCenter: true),
                _hCell("QTY", 2, isCenter: true),
                if (!isMobile) _hCell("COUNTER", 3),
                _hCell("DATE", 3, isCenter: true),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xffE2E8F0)),
          ref.read(master_Provider).loading
              ? Expanded(child: buildShimmerEffect(context: context))
              : data.isEmpty
              ? const Expanded(child: Center(child: Text("No transactions found")))
              : Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: data.length,
              separatorBuilder: (c, i) => Divider(height: 1, color: Colors.grey[100]),
              itemBuilder: (context, index) => _buildDataRow(data[index], index, isMobile),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(StockHistoryModel item, int index, bool isMobile) {
    Color typeColor = item.transaction_type == "IN" ? Colors.green : (item.transaction_type == "OUT" ? Colors.red : Colors.blue);
    IconData typeIcon = item.transaction_type == "IN" ? Icons.arrow_downward : (item.transaction_type == "OUT" ? Icons.arrow_upward : Icons.tune);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text("${index + 1}.", style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))),
          Expanded(flex: 4, child: Text(item.shop_name ?? "-", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff334155)))),
          Expanded(flex: 4, child: Text(item.sweet_name ?? "-", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff334155)))),
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(typeIcon, size: 10, color: typeColor),
                      const SizedBox(width: 4),
                      Text(item.transaction_type ?? "-", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: typeColor)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(flex: 2, child: Center(child: Text("${item.quantity} ${item.unit ?? ''}", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)))),
          if (!isMobile) Expanded(flex: 3, child: Text(item.counter_name ?? "-", style: const TextStyle(fontSize: 12, color: Colors.blueGrey))),
          Expanded(flex: 3, child: Center(child: Text(_formatDate(item.cr_on), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)))),
        ],
      ),
    );
  }

  Widget _hCell(String label, int flex, {bool isCenter = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: isCenter ? TextAlign.center : TextAlign.start,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xff64748B), letterSpacing: 0.5),
      ),
    );
  }
}