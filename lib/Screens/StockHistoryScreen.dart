import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/StockHistoryModel.dart';
import '../provider/provider.dart';

class StockHistoryScreen extends ConsumerStatefulWidget {
  const StockHistoryScreen({super.key});

  @override
  ConsumerState<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends ConsumerState<StockHistoryScreen> {


  // final List<StockHistoryModel> historyData = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(master_Provider).fetchStockHistory();
    });
  }


  final Color primaryDark = const Color(0xff1A2B4C);
  final Color borderCol = const Color(0xffE2E8F0);

  @override
  Widget build(BuildContext context) {
    final masterProv = ref.watch(master_Provider);

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
              Expanded(
                  child: _buildHistoryTable(masterProv.stockHistoryData, isMobile)),
            ],
          ),
        ),
      );
    });
  }

  // --- TOP HEADER INFO ---
  Widget _buildHeader(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Activity Logs",style: TextStyle(fontSize: isMobile ? 16 : 20, fontWeight: FontWeight.w900, color: primaryDark)),
              Text("Track every stock movement",style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
        // if (!isMobile)
        //   ElevatedButton.icon(
        //     onPressed: () {},
        //     icon: const Icon(Icons.download, size: 18),
        //     label: const Text("Export CSV"),
        //     style: ElevatedButton.styleFrom(backgroundColor: primaryDark, foregroundColor: Colors.white),
        //   )
      ],
    );
  }

  // --- RESPONSIVE TABLE ---
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
          // 1. Table Header (Fixed)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
            decoration: BoxDecoration(
              color: primaryDark.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                _hCell("SR.", 1),
                _hCell("SHOP NAME", 4),
                _hCell("ITEM NAME", 4),
                _hCell("TYPE", 2, isCenter: true),
                _hCell("QTY", 2, isCenter: true),
                if (!isMobile) ...[
                  _hCell("COUNTER", 3),
                  _hCell("NOTES", 3),
                ],
                _hCell("DATE", 3, isCenter: true),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xffE2E8F0)),

          // 2. Data Rows (Scrollable & Taking Full Space)
          data.isEmpty
              ? const Expanded(
            child: Center(child: Text("No transactions found")),
          )
              : Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: data.length,
              separatorBuilder: (c, i) => Divider(height: 1, color: Colors.grey[100]),
              itemBuilder: (context, index) {
                final item = data[index];
                return _buildDataRow(item, index, isMobile);
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDataRow(StockHistoryModel item, int index, bool isMobile) {
    // Transaction Style Logic
    Color typeColor;
    IconData typeIcon;
    if (item.transaction_type == "IN") {
      typeColor = Colors.green;
      typeIcon = Icons.arrow_downward;
    } else if (item.transaction_type == "OUT") {
      typeColor = Colors.red;
      typeIcon = Icons.arrow_upward;
    } else {
      typeColor = Colors.blue;
      typeIcon = Icons.tune;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
      child: Row(
        children: [
          // 1. Serial No.
          Expanded(flex: 1, child: Text("${index + 1}.", style: const TextStyle(fontSize: 12, color: Colors.grey,fontWeight: FontWeight.w500))),

          // 2. Sweet Name
          Expanded(
            flex: 4,
            child: Text(item.shop_name ?? "-",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff334155))),
          ),


          Expanded(
            flex: 4,
            child: Text(item.sweet_name ?? "-",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff334155))),
          ),

          // 3. Type Badge
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(typeIcon, size: 10, color: typeColor),
                    const SizedBox(width: 4),
                    Text(item.transaction_type ?? "-",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: typeColor)),
                  ],
                ),
              ),
            ),
          ),

          // 4. Quantity
          Expanded(
            flex: 2,
            child: Center(
              child: Text("${item.quantity} ${item.unit ?? ''}",
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),

          // 5. Desktop Only: Counter & Notes
          if (!isMobile) ...[
            Expanded(flex: 3, child: Text(item.counter_name ?? "-", style: const TextStyle(fontSize: 12, color: Colors.blueGrey))),
            Expanded(flex: 3, child: Text(item.notes ?? "-", style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey))),
          ],

          // 6. Date (Proper Format)
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                item.cr_on != null
                    ? DateFormat('dd-MM-yyyy').format(DateTime.parse(item.cr_on.toString()))
                    : "-",
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ),
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