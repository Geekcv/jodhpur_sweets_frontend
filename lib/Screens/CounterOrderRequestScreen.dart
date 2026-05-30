import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:js_order_website/Screens/LoginUserDetails.dart';
import '../controllers/api_controller.dart';
import '../provider/provider.dart';
import '../widgets/CustomDropDownSearch.dart';
import '../widgets/TextInputField.dart';

class CounterOrderRequestScreen extends ConsumerStatefulWidget {
  const CounterOrderRequestScreen({super.key});

  @override
  ConsumerState<CounterOrderRequestScreen> createState() => _CounterOrderRequestScreenState();
}

class _CounterOrderRequestScreenState extends ConsumerState<CounterOrderRequestScreen> {
  bool isLoading = false;

  String? selectedCounterId;
  dynamic selectedCounter; // Naya variable for UI reset
  dynamic selectedSweet;
  final qtyCtrl = TextEditingController();

  List<Map<String, dynamic>> requestedItems = [];

  static const Color primaryDark = Color(0xff1A2B4C);
  static const Color accentGold = Color(0xffC5A059);
  static const Color borderCol = Color(0xffE2E8F0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(master_Provider).fetchSweets();

      // print("This is the user:---------${LoginUserDetails.isCounterUser}");
      if(!LoginUserDetails.isCounterUser){
        // print("This is the usedsfdsfr:---------${LoginUserDetails.isCounterUser}");
        ref.read(master_Provider).fetchCounter();
      }

      ref.read(master_Provider).fetchOrderRequest();
    });
  }


  void _addItemToList() {
    if (selectedSweet == null || qtyCtrl.text.trim().isEmpty) {
      _showToast("Please add required fields", Colors.orange);
      return;
    }

    setState(() {
      requestedItems.add({
        "sweet_id": selectedSweet.row_id.toString(),
        "sweet_name": selectedSweet.sweet_name.toString(),
        "quantity": qtyCtrl.text.trim(),
      });

      // RESETTING FIELDS
      selectedSweet = null; // Dropdown khali ho jayega
      qtyCtrl.clear();      // Textfield khali ho jayega
    });
  }

  Future<void> _handleFinalSubmit() async {
    if ((selectedCounterId == null && !LoginUserDetails.isCounterUser) || requestedItems.isEmpty) {
      _showToast("Please fill all required fields", Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    final params = {
      "counter_id": LoginUserDetails.isCounterUser ? LoginUserDetails.userId  : selectedCounterId.toString(),
      "items": requestedItems.map((e) => {
        "sweet_id": e['sweet_id'],
        "quantity": int.parse(e['quantity'].toString())
      }).toList(),
    };

    var res = await ApiController.creteOrderRequestByCounterUser(params: params);

    if (res != null && res['status'] == 0) {
      _showToast("Order Request Sent Successfully!", Colors.green);
      setState(() {
        requestedItems.clear();
      });
    }
    if (res != null && res['status'] == 1) {
      _showToast("${res['msg']}", Colors.red);
    }
    if (mounted) setState(() => isLoading = false);
  }

  void _showToast(String msg, Color col) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: col));
  }

  @override
  Widget build(BuildContext context) {
    final masterProv = ref.watch(master_Provider);
    final sweets = masterProv.allSweets ?? [];
    final counters = masterProv.allCounters ?? [];

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 850;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader("Create Order Request"),
                const SizedBox(height: 16),
                _buildFormCard(sweets, counters, isMobile),
                const SizedBox(height: 20),
                _buildListTitle("ITEMS IN THIS REQUEST"),
                const SizedBox(height: 15),
                _buildItemsTable(isMobile),
                const SizedBox(height: 20),
                if (requestedItems.isNotEmpty)
                  Align(
                    alignment: isMobile ? Alignment.center : Alignment.centerRight,
                    child: _buildFinalSubmitBtn(isMobile),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormCard(List sweets, List counters, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderCol),
      ),
      child: Wrap(
        spacing: 15,
        runSpacing: 15,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          if (!LoginUserDetails.isCounterUser)
            _field(isMobile, 260, _dropdown(
              "SELECT COUNTER USER",
              counters,
              selectedCounter, // Pass current state
                  (v) => v.counter_name,
                  (v) => setState(() {
                selectedCounter = v;
                selectedCounterId = v?.row_id.toString();
              }),
                  (a, b) => a?.row_id == b?.row_id,
            )),

          _field(isMobile, 260, _dropdown(
            "SELECT ITEM",
            sweets,
            selectedSweet, // Pass current state
                (v) => v.sweet_name,
                (v) => setState(() => selectedSweet = v),
                (a, b) => a?.row_id == b?.row_id,
          )),

          _field(isMobile, 120, _box("QTY", qtyCtrl, isNum: true)),

          // Add Item Button (Styled like Confirm Button)
          SizedBox(
            // width: isMobile ? double.infinity : 150,
            height: 38,
            child: ElevatedButton.icon(
              onPressed: _addItemToList,
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: const Text("ADD ITEM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGold, // Gold/Yellowish tone for "Add" action
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SAFE DROPDOWN WITH compareFn ---
  Widget _dropdown(String label,List items,
      dynamic currentSelectedValue, // Ye value must hai
      String Function(dynamic) labelBuilder, Function(dynamic) onSel, bool Function(dynamic, dynamic) compare) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: CustomDropdownSearch<dynamic>(
            items: items,
            selectedItem: currentSelectedValue, // Ye dropdown ko reset karega
            itemLabelBuilder: (val) => val != null ? labelBuilder(val) : "Select",
            compareFn: compare,
            onChanged: (val) {
              // Agar val null hai (reset), toh null pass karo warna selection
              onSel(val);
            },
            hintText: "Select",
          ),
        ),
      ],
    );
  }


  Widget _buildItemsTable(bool isMobile) {
    if (requestedItems.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderCol)),
        child: const Center(child: Text("No items added yet", style: TextStyle(color: Colors.grey))),
      );
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: borderCol)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            color: const Color(0xffF8FAFC),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text("ITEM", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text("QTY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                SizedBox(width: 50, child: Text("REMOVE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.redAccent, letterSpacing: 0.5))),
              ],
            ),
          ),
          ...requestedItems.asMap().entries.map((entry) {
            int idx = entry.key;
            var item = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: borderCol))),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(item['sweet_name'], style: const TextStyle(fontWeight: FontWeight.w600))),
                  Expanded(flex: 1, child: Text(item['quantity'],style: const TextStyle(fontWeight: FontWeight.w400))),
                  SizedBox(width: 50,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () => setState(() => requestedItems.removeAt(idx)),
                    ),
                  )
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFinalSubmitBtn(bool isMobile) {
    return SizedBox(
      height: 40,
      // width: isMobile ? double.infinity : 280,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleFinalSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          // backgroundColor: Color(0xff108548),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("SUBMIT ORDER REQUEST", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // Helpers
  Widget _field(bool isMobile, double width, Widget child) => SizedBox(width: isMobile ? double.infinity : width, child: child);

  Widget _box(String label, TextEditingController ctrl, {bool isNum = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(height: 6),
        SizedBox(height: 38, child: CustomTextInput(
            hintText: label,
            controller: ctrl,
            keyboardType: isNum ? TextInputType.number : TextInputType.text,
          inputFormatters: [
            if (isNum) FilteringTextInputFormatter.digitsOnly, // Sirf numbers 0-9
            FilteringTextInputFormatter.deny(RegExp(r'\s')),   // Space bilkul allowed nahi hai
          ],
          maxLines: 1,
        )),
      ],
    );
  }

  Widget _buildHeader(String t) => Text(t, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: primaryDark));
  Widget _buildListTitle(String t) => Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2));
}