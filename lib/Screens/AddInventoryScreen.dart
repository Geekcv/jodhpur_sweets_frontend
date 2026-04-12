import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/api_controller.dart';
import '../models/InventoryModel.dart';
import '../provider/provider.dart';
import '../widgets/CustomDropDownSearch.dart';
import '../widgets/TextInputField.dart';

class AddInventoryScreen extends ConsumerStatefulWidget {
  const AddInventoryScreen({super.key});

  @override
  ConsumerState<AddInventoryScreen> createState() => _AddInventoryScreenState();
}

class _AddInventoryScreenState extends ConsumerState<AddInventoryScreen> {
  bool isLoading = false;
  String selectedType = "IN"; // Default Tab

  // Selection IDs
  String? selectedCounterId;
  String? selectedSweetId;
  DateTime? selectedExpiryDate;

  // Controllers
  final quantityCtrl = TextEditingController();
  final refCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final minCtrl = TextEditingController();
  final maxCtrl = TextEditingController();

  static const Color primaryDark = Color(0xff1A2B4C);
  static const Color successGreen = Color(0xff108548);
  static const Color borderCol = Color(0xffE2E8F0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(master_Provider).fetchSweets();
      ref.read(master_Provider).fetchCounter();
      ref.read(master_Provider).fetchInventory();
    });
  }



  Future<void> _handleSubmit() async {
    // 1. BASIC VALIDATION (Sabke liye common)
    if (selectedCounterId == null) return _showToast("Please select a Counter!", Colors.orange);
    if (selectedSweetId == null) return _showToast("Please select a Sweet!", Colors.orange);
    if (selectedType == null) return _showToast("Please select Transaction Type!", Colors.orange);

    String qty = quantityCtrl.text.trim();
    if (qty.isEmpty || double.tryParse(qty) == null || double.parse(qty) <= 0) {
      return _showToast("Enter a valid quantity greater than 0!", Colors.redAccent);
    }


    // 2. TYPE-SPECIFIC VALIDATION
    if (selectedType == "IN") {
      if (selectedExpiryDate == null) return _showToast("Expiry Date is required for IN stock!", Colors.orange);
      if (minCtrl.text.isEmpty || maxCtrl.text.isEmpty) {
        return _showToast("Min/Max stock limits are required for IN stock!", Colors.orange);
      }
    }

    if (selectedType == "ADJUST") {
      if (minCtrl.text.isEmpty || maxCtrl.text.isEmpty) {
        return _showToast("Please provide updated Min/Max stock limits!", Colors.orange);
      }
    }

    setState(() => isLoading = true);

    try {
      // 3. DYNAMIC DATA PAYLOAD (Sirf wahi data jayega jo us Type ke liye zaruri hai)
      Map<String, dynamic> tobeSendData = {
        "counter_id": selectedCounterId,
        "sweet_id": selectedSweetId,
        "transaction_type": selectedType,
        "quantity": qty,
        "notes": notesCtrl.text.trim(),
      };

      // Agar IN hai toh ye fields add karo
      if (selectedType == "IN") {
        tobeSendData.addAll({
          "expiry_date": DateFormat('yyyy-MM-dd').format(selectedExpiryDate!),
          "reference_id": refCtrl.text.trim().isEmpty ? "PO-${DateTime.now().millisecondsSinceEpoch}" : refCtrl.text.trim(),
          "min_stock": minCtrl.text.trim(),
          "max_stock": maxCtrl.text.trim(),
        });
      }

      // Agar ADJUST hai toh limits add karo
      if (selectedType == "ADJUST") {
        tobeSendData.addAll({
          "min_stock": minCtrl.text.trim(),
          "max_stock": maxCtrl.text.trim(),
        });
      }

      // 4. API CALL
      var res = await ApiController.addInventory(params: tobeSendData);

      if (res != null) {
        if (res['status'] == 0) {
          _showToast("Stock $selectedType Successful ", Colors.green);
          ref.read(master_Provider).fetchInventory();
          _clearForm();
        } else {
          _showToast(res['msg'] ?? res['message'] ?? "Failed to update inventory", Colors.red);
        }
      }
    } catch (e) {
      _showToast("Error: $e", Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _clearForm() {
    isLoading=false;
    quantityCtrl.clear();
    refCtrl.clear();
    notesCtrl.clear();
    maxCtrl.clear();
    minCtrl.clear();
    selectedExpiryDate = null;
    // selectedSweetId = null;
    // selectedCounterId = null;
    setState(() {});
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final masterProv = ref.watch(master_Provider);
    final sweets = masterProv.allSweets ?? [];
    final counters = masterProv.allCounters ?? [];
    final inventoryLogs = masterProv.allInventory ?? [];

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 700;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FIXED HEADER
              Padding(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(isMobile ? "Inventory" : "Inventory Management", isMobile),
                    const SizedBox(height: 15),
                    _buildTabSwitcher(isMobile),
                  ],
                ),
              ),

              // SCROLLABLE CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildResponsiveForm(sweets, counters, isMobile),
                      const SizedBox(height: 20),
                      _buildListTitle("RECENT TRANSACTIONS"),
                      const SizedBox(height: 12),
                      _buildInventoryTable(inventoryLogs, isMobile),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }


  Widget _buildTabSwitcher(bool isMobile) {
    // List of tabs taaki code repeat na ho
    final tabs = [
      {"type": "IN", "icon": Icons.arrow_downward_rounded, "color": Colors.green},
      {"type": "OUT", "icon": Icons.arrow_upward_rounded, "color": Colors.redAccent},
      {"type": "ADJUST", "icon": Icons.tune_rounded, "color": Colors.blue},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: tabs.map((tab) {
          String type = tab["type"] as String;
          IconData icon = tab["icon"] as IconData;
          Color activeColor = tab["color"] as Color;
          bool isSel = selectedType == type;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () => setState(() => selectedType = type),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 20,
                    vertical: isMobile ? 10 : 8
                ),
                decoration: BoxDecoration(
                  color: isSel ? activeColor : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSel ? activeColor : borderCol,
                    width: 1.5,
                  ),
                  // boxShadow: isSel
                  //     ? [BoxShadow(color: activeColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                  //     : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: isMobile ? 12 : 16, color: isSel ? Colors.white : activeColor),
                    const SizedBox(width: 6),
                    Text(type,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: isMobile ? 12 : 14,
                            letterSpacing: 0.5,
                            color: isSel ? Colors.white : primaryDark
                        )
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }



  Widget _buildResponsiveForm(List sweets, List counters, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      margin: const EdgeInsets.only(top: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderCol),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
      ),
      // child: Column(
      //   children: [
      //     Row(
      //       crossAxisAlignment: CrossAxisAlignment.end,
      //       children: [
      //         Expanded(flex: 2, child: _dropdown("SELECT COUNTER", counters, (v) => v.counter_name, (v) => selectedCounterId = v.row_id.toString())),
      //         const SizedBox(width: 15),
      //         Expanded(flex: 2, child: _dropdown("SELECT ITEM", sweets, (v) => v.sweet_name, (v) => selectedSweetId = v.row_id.toString())),
      //         const SizedBox(width: 15),
      //         Expanded(flex: 1, child: _box("QUANTITY", quantityCtrl, isNum: true)),
      //         if (selectedType == "IN") ...[
      //           const SizedBox(width: 15),
      //           Expanded(flex: 1, child: _dateBox("EXPIRY DATE")),
      //         ]
      //       ],
      //     ),
      //     const SizedBox(height: 20),
      //     Row(
      //       crossAxisAlignment: CrossAxisAlignment.end,
      //       children: [
      //         if (selectedType == "IN") ...[
      //           Expanded(flex: 1, child: _box("REF/PO ID", refCtrl)),
      //           const SizedBox(width: 15),
      //         ],
      //         if (selectedType != "OUT") ...[
      //           Expanded(flex: 1, child: _box("MIN STOCK", minCtrl, isNum: true)),
      //           const SizedBox(width: 15),
      //           Expanded(flex: 1, child: _box("MAX STOCK", maxCtrl, isNum: true)),
      //           const SizedBox(width: 15),
      //         ],
      //         Expanded(flex: 2, child: _box("NOTES / REMARKS", notesCtrl)),
      //         const SizedBox(width: 20),
      //         _buildSubmitBtn(),
      //       ],
      //     ),
      //   ],
      // ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          _fieldWrapper(isMobile, 250, _dropdown("SELECT COUNTER", counters, (v) => v.counter_name, (v) => selectedCounterId = v.row_id.toString())),
          _fieldWrapper(isMobile, 250, _dropdown("SELECT SWEET NAME", sweets, (v) => v.sweet_name, (v) => selectedSweetId = v.row_id.toString())),
          _fieldWrapper(isMobile, 120, _box("QTY", quantityCtrl, isNum: true)),

          if (selectedType == "IN") ...[
            _fieldWrapper(isMobile, 150, _dateBox("EXPIRY DATE")),
            _fieldWrapper(isMobile, 150, _box("REF ID", refCtrl)),
          ],

          if (selectedType != "OUT") ...[
            _fieldWrapper(isMobile, 120, _box("MIN STOCK", minCtrl, isNum: true)),
            _fieldWrapper(isMobile, 120, _box("MAX STOCK", maxCtrl, isNum: true)),
          ],

          _fieldWrapper(isMobile, 350, _box("NOTES", notesCtrl)),

          // Submit Button
          SizedBox(
            width: isMobile ? double.infinity : 180,
            height: 40,
            child: _buildSubmitBtn(),
          ),
        ],
      ),
    );
  }


  Widget _fieldWrapper(bool isMobile, double width, Widget child) {
    return SizedBox(width: isMobile ? double.infinity : width, child: child);
  }



  Widget _dropdown(String label, List items, String Function(dynamic) labelBuilder, Function(dynamic) onSel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: CustomDropdownSearch<dynamic>(
            items: items,
            itemLabelBuilder: labelBuilder,
            compareFn: (a, b) => a.row_id.toString() == b.row_id.toString(),
            onChanged: (val) => setState(() => onSel(val)),
            hintText: "Select",
          ),
        ),
      ],
    );
  }


  Widget _dateBox(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
            if (picked != null) setState(() => selectedExpiryDate = picked);
          },
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: const Color(0xffF8FAFC), borderRadius: BorderRadius.circular(6), border: Border.all(color: borderCol)),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, size: 14, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(selectedExpiryDate == null ? "Select" : DateFormat('dd-MM-yy').format(selectedExpiryDate!), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _box(String label, TextEditingController ctrl, {bool isNum = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
        const SizedBox(height: 6),
        SizedBox(height: 38,
            child: CustomTextInput(
            hintText: label.toLowerCase(),
            controller: ctrl,
            maxLines: 1,
            keyboardType: isNum ? TextInputType.number : TextInputType.text,
              inputFormatters: [
                if (isNum) FilteringTextInputFormatter.digitsOnly, // Sirf numbers 0-9
                FilteringTextInputFormatter.deny(RegExp(r'\s')),   // Space bilkul allowed nahi hai
              ],
            )),
      ],
    );
  }

  Widget _buildSubmitBtn() {
    return SizedBox(
      height: 38,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedType == "IN" ? successGreen : (selectedType == "OUT" ? Colors.redAccent : Colors.blue),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 30),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text("CONFIRM ${selectedType}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }



  Widget _buildInventoryTable(List<InventoryModel> data, bool isMobile) { // Fixed: List<InventoryModel>
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderCol),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          // --- TABLE HEADER ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: const BoxDecoration(
                color: Color(0xffF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(8))
            ),
            child: Row(
              children: [
                _hCell("SR.", 1),
                _hCell("ITEM", 3),
                _hCell("QTY", 2, isCenter: true),
                if (!isMobile) ...[
                  _hCell("MIN", 1, isCenter: true), // Added Min
                  _hCell("MAX", 1, isCenter: true), // Added Max
                  _hCell("COUNTER", 3),
                ],
                _hCell("EXPIRY", 2, isCenter: true),
              ],
            ),
          ),
          const Divider(height: 1, color: borderCol),

          // --- DATA LIST ---
          data == null || data.isEmpty
              ? const Padding(
              padding: EdgeInsets.all(50),
              child: Text("No Stock Records Found", style: TextStyle(color: Colors.grey, fontSize: 13))
          )
              : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            separatorBuilder: (c, i) => const Divider(height: 1, color: borderCol),
            itemBuilder: (context, index) {
              final item = data[index];

              // Safely parsing numbers
              double qty = double.tryParse(item.quantity?.toString() ?? '0') ?? 0;
              double minStock = double.tryParse(item.minStock?.toString() ?? '0') ?? 0;
              double maxStock = double.tryParse(item.maxStock?.toString() ?? '0') ?? 0;

              bool isLowStock = qty <= minStock;
              bool isOverStock = qty >= maxStock && maxStock > 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Row(
                  children: [
                    // 1. SR.
                    Expanded(flex: 1, child: Text("${index + 1}.", style: const TextStyle(fontSize: 11, color: Colors.black))),

                    // 2. ITEM & ALERTS
                    Expanded(
                        flex: 3,
                        child:Text(item.sweetName ?? "-",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryDark))
                    ),

                    // 3. CURRENT QTY
                    Expanded(
                        flex: 2,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isLowStock ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text("${item.quantity} ${item.unit ?? ''}",
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isLowStock ? Colors.red : Colors.green)),
                          ),
                        )
                    ),

                    // 4. MIN/MAX & COUNTER (Desktop Only)
                    if (!isMobile) ...[
                      Expanded(flex: 1, child: Center(child: Text("${item.minStock ?? 0}", style: const TextStyle(fontSize: 11)))),
                      Expanded(flex: 1, child: Center(child: Text("${item.maxStock ?? 0}", style: const TextStyle(fontSize: 11)))),
                      Expanded(flex: 3, child: Text(item.counterName ?? "-", style: const TextStyle(fontSize: 11, color: Colors.blueGrey))),
                    ],

                    // 5. EXPIRY
                    Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            item.expiryDate != null
                                ? DateFormat('dd MMM yy').format(DateTime.parse(item.expiryDate.toString()))
                                : "-",
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryDark),
                          ),
                        )
                    ),
                  ],
                ),
              );
            },
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
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xff64748B), letterSpacing: 0.5),
      ),
    );
  }



  Widget _buildHeader(String title, bool isMobile) {
    return Row(
      children: [
        Icon(Icons.inventory, size: isMobile ? 16 : 22, color: primaryDark),
        const SizedBox(width: 10),
        Text(title, style: TextStyle(fontSize: isMobile ? 14 : 20, fontWeight: FontWeight.w900, color: primaryDark)),
      ],
    );
  }

  Widget _buildListTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1.2));
  }
}