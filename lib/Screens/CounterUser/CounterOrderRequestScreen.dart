import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:js_order_website/Screens/LoginUserDetails.dart';
import 'package:js_order_website/config/config.dart';

import '../../controllers/api_controller.dart';
import '../../provider/provider.dart';
import '../../widgets/CustomDropDownSearch.dart';
import '../../widgets/TextInputField.dart';


class CounterOrderRequestScreen extends ConsumerStatefulWidget {
  const CounterOrderRequestScreen({super.key});

  @override
  ConsumerState<CounterOrderRequestScreen> createState() => _CounterOrderRequestScreenState();
}

class _CounterOrderRequestScreenState extends ConsumerState<CounterOrderRequestScreen> {
  bool isLoading = false;

  // --- STATE CONTROLLERS ---
  dynamic selectedSweet;
  final qtyCtrl = TextEditingController();

  final searchCtrl = TextEditingController();
  String searchTerm = "";

  final Map<String, TextEditingController> _qtyControllers = {};
  final Map<String, dynamic> _cart = {};

  // --- STYLING CONSTANTS ---
  static const Color primaryNavy = Color(0xff0F172A);
  static const Color primaryDark = Color(0xff0F172A);
  static const Color accentGold = Color(0xffD97706);
  static const Color borderCol = Color(0xffE2E8F0);
  static const Color bgCol = Color(0xF9FAFB);
  static const Color bgLight = Color(0xffF1F5F9);
  static const Color cardBg = Colors.white;

  static const TextStyle _hStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: primaryNavy,
    letterSpacing: 0.5,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(master_Provider).fetchSweets();
      if (!LoginUserDetails.isCounterUser) {
        ref.read(master_Provider).fetchCounter();
      }
      ref.read(master_Provider).fetchOrderRequest();
    });

    searchCtrl.addListener(() {
      setState(() {
        searchTerm = searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    qtyCtrl.dispose();
    for (final c in _qtyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------- QUANTITY HELPERS ----------
  TextEditingController _ctrlFor(dynamic sweet) {
    final id = sweet.row_id.toString();
    return _qtyControllers.putIfAbsent(id, () {
      return TextEditingController();
    });
  }

  void _onQtyChanged(dynamic sweet, String val) {
    final id = sweet.row_id.toString();
    final qty = int.tryParse(val.trim()) ?? 0;
    setState(() {
      if (qty <= 0) {
        _cart.remove(id);
      } else {
        _cart[id] = sweet;
      }
    });
  }

  void _bump(dynamic sweet, int delta) {
    final ctrl = _ctrlFor(sweet);
    final current = int.tryParse(ctrl.text.trim()) ?? 0;
    final next = (current + delta).clamp(0, 99999);
    ctrl.text = next == 0 ? "" : next.toString();
    ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
    _onQtyChanged(sweet, ctrl.text);
  }

  int _qtyOf(dynamic sweet) {
    return int.tryParse(_ctrlFor(sweet).text.trim()) ?? 0;
  }

  int get _totalUnits {
    int total = 0;
    for (final entry in _cart.entries) {
      total += int.tryParse(_qtyControllers[entry.key]?.text ?? "0") ?? 0;
    }
    return total;
  }

  void _addFromDropdown() {
    if (selectedSweet == null || qtyCtrl.text.trim().isEmpty) {
      _showToast("Select item and quantity first", Colors.orange);
      return;
    }
    final addQty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
    if (addQty <= 0) {
      _showToast("Enter valid quantity", Colors.orange);
      return;
    }

    final ctrl = _ctrlFor(selectedSweet);
    final current = int.tryParse(ctrl.text.trim()) ?? 0;
    final updated = current + addQty;
    ctrl.text = updated.toString();
    _onQtyChanged(selectedSweet, ctrl.text);

    setState(() {
      selectedSweet = null;
      qtyCtrl.clear();
    });

    _showToast("Item added successfully!", const Color(0xff108548));
  }

  // ---------- FULL IMAGE PREVIEW DIALOG ----------
  void _showImageDialog(String? path) {
    if (path == null || path.isEmpty) return;
    final String url = path.startsWith("http") ? path : "$serverUrlMedia$path";

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10)
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Padding(
                    padding: EdgeInsets.all(20),
                    child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- CONFIRM DIALOG ----------
  void _confirmOrderDialog() {
    if (_cart.isEmpty) {
      _showToast("Please select at least 1 item", Colors.orange);
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: cardBg,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.assignment_turned_in_rounded,color: primaryNavy, size: 20),
                    SizedBox(width: 8),
                    Text("Confirm Order Request", style: TextStyle(fontWeight: FontWeight.w800,fontSize: 15,color: primaryNavy,)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text("Please review your selected items before submitting:",style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                const SizedBox(height: 12),

                // SCROLLABLE LIST OF SELECTED ITEMS
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 320),
                    decoration: BoxDecoration(
                      color: bgCol,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderCol),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _cart.length,
                      separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: borderCol),
                      itemBuilder: (context, index) {
                        final key = _cart.keys.elementAt(index);
                        final sweet = _cart[key];
                        final qty = int.tryParse(_qtyControllers[key]?.text ?? "0") ?? 0;
                        final unit = sweet.unit?.toString() ?? "unit";

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              // _thumb(sweet.image_url?.toString(), sweet.sweet_name?.toString(), size: 30),
                              // const SizedBox(width: 10),
                              Expanded(
                                child: Text(sweet.sweet_name?.toString() ?? "",
                                  style: const TextStyle(fontWeight: FontWeight.w700,fontSize: 12,color: primaryNavy),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: primaryNavy.withOpacity(0.06), borderRadius: BorderRadius.circular(4),),
                                child: Text("$qty $unit",style: const TextStyle(fontWeight: FontWeight.w800,fontSize: 11,color: primaryNavy)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // SUMMARY BAR
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryNavy.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderCol),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Items: ${_cart.length}", style: const TextStyle(fontWeight: FontWeight.w700,fontSize: 12,color: primaryNavy),),
                      // Text(
                      //   "Total Quantity: $_totalUnits",
                      //   style: const TextStyle(
                      //       fontWeight: FontWeight.w800,
                      //       fontSize: 12,
                      //       color: accentGold),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ACTION BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text("CANCEL",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 11)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        _handleFinalSubmit();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff2563EB),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text("SUBMIT ORDER",
                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- SUBMIT API ----------
  Future<void> _handleFinalSubmit() async {
    setState(() {
      isLoading = true;
    });

    final List<Map<String, dynamic>> itemsPayload = [];
    for (final entry in _cart.entries) {
      final q = int.tryParse(_qtyControllers[entry.key]?.text ?? "0") ?? 0;
      if (q > 0) {
        itemsPayload.add({
          "sweet_id": entry.key,
          "quantity": q,
        });
      }
    }

    final params = {
      "counter_id": LoginUserDetails.userId.toString(),
      "items": itemsPayload,
    };

    var res = await ApiController.creteOrderRequestByCounterUser(params: params);

    if (res != null && res['status'] == 0) {
      _showToast("Order Request Sent Successfully!", const Color(0xff108548));
      setState(() {
        for (final c in _qtyControllers.values) {
          c.clear();
        }
        _cart.clear();
      });
    } else if (res != null && res['status'] == 1) {
      _showToast("${res['msg']}", Colors.redAccent);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showToast(String msg, Color col) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      backgroundColor: col,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      margin: const EdgeInsets.all(12),
    ));
  }





  // ---------- MAIN BUILD ----------
  @override
  Widget build(BuildContext context) {
    final masterProv = ref.watch(master_Provider);
    final List allSweets = masterProv.allSweets ?? [];

    var filteredSweets = allSweets;
    if (searchTerm.isNotEmpty) {
      filteredSweets = filteredSweets.where((s) => s.sweet_name.toString().toLowerCase().contains(searchTerm)).toList();
    }

    return Scaffold(
      backgroundColor: bgCol,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 650;
          final double padding = isMobile ? 10 : 16;

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(padding, 16, padding, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSingleLineControlBar(sweets: allSweets,isMobile: isMobile),
                    const SizedBox(height: 16),
                    if (!isMobile && filteredSweets.isNotEmpty)
                      _buildTableHeader(),
                  ],
                ),
              ),

              // --- SCROLLABLE TABLE CONTENT ONLY ---
              Expanded(
                child: filteredSweets.isEmpty ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: _emptyState(),
                ): Padding(
                  padding: EdgeInsets.only(left: padding,right: padding,bottom: 16,),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredSweets.length,
                    itemBuilder: (context, i) {
                      return _buildOrderRow(filteredSweets[i],isMobile,i + 1);
                    },
                  ),
                ),
              ),

              // --- FIXED BOTTOM BAR ---
              if (_cart.isNotEmpty) _buildBottomBar(isMobile),
            ],
          );
        },
      ),
    );
  }





  // ---------- CONTROL BAR WITH END SEARCH FIELD ----------
  Widget _buildSingleLineControlBar({required List sweets, required bool isMobile}) {
    final double dropdownWidth = isMobile ? double.infinity : 240;
    final double qtyWidth = isMobile ? double.infinity : 120;
    final double searchWidth = isMobile ? double.infinity : 300;

    // Input Controls Box (3 elements)
    Widget inputCard = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg, // White Background sirf 3 inputs wale container ke liye
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderCol),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // 1. Dropdown
          SizedBox(
            width: dropdownWidth,
            height: 34,
            child: CustomDropdownSearch<dynamic>(
              items: sweets,
              selectedItem: selectedSweet,
              itemLabelBuilder: (v) {
                return v != null ? "${v.sweet_name}" : "Select Item";
              },
              compareFn: (a, b) => a?.row_id == b?.row_id,
              onChanged: (v) => setState(() => selectedSweet = v),
              hintText: "Select Item",
            ),
          ),
          // 2. Qty Input
          SizedBox(
            width: qtyWidth,
            height: 34,
            child: CustomTextInput(
              hintText: "Qty",
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLines: 1,
            ),
          ),
          // 3. Add Button
          SizedBox(
            height: 34,
            width: isMobile ? double.infinity : null,
            child: ElevatedButton.icon(
              onPressed: _addFromDropdown,
              icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
              label: const Text(
                "ADD ITEM",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff2563EB),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Search Field Widget
    Widget searchField = SizedBox(
      width: searchWidth,
      child: TextField(
        controller: searchCtrl,
        style: const TextStyle(fontSize: 11),
        decoration: InputDecoration(
          isDense: true,
          hintText: "Search item...",
          hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
          prefixIcon: const Icon(Icons.search, size: 15, color: Colors.blueGrey),
          filled: true,
          fillColor: cardBg, // Smooth contrast background
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: borderCol),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: borderCol),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xff2563EB)),
          ),
        ),
      ),
    );

    // Mobile layout setup (Vertical stack) vs Desktop layout setup (Horizontal Row)
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          inputCard,
          const SizedBox(height: 10),
          searchField,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Align(alignment: Alignment.centerLeft, child: inputCard)),
        const SizedBox(width: 12),
        searchField,
      ],
    );
  }
  // ---------- TABLE HEADER UI (Matching Example) ----------
  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: bgLight,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        border: Border.all(color: borderCol),
      ),
      child: const Row(
        children: [
          SizedBox(width: 45, child: Text("S.N.", style: _hStyle)),
          Expanded(flex: 3, child: Text("SWEET NAME", style: _hStyle)),
          // Expanded(flex: 2, child: Text("COUNTER NAME", style: _hStyle)),
          Expanded(flex: 2, child: Text("CATEGORY", style: _hStyle)),
          Expanded(flex: 2, child: Text("SHELF LIFE", style: _hStyle)),
          Expanded(flex: 2, child: Text("QUANTITY", textAlign: TextAlign.center, style: _hStyle)),
        ],
      ),
    );
  }



  // ---------- ORDER ROW UI (Matching Example Design) ----------
  Widget _buildOrderRow(dynamic sweet, bool isMobile, int index) {
    final qty = _qtyOf(sweet);
    final bool selected = qty > 0;

    final String sweetName = sweet.sweet_name?.toString().toUpperCase() ?? 'N/A';
    // final String counterName = sweet.counter_name?.toString() ?? '-';
    final String categoryName = sweet.category_name?.toString() ?? '-';
    final String shelfLife = sweet.shelf_life_days != null ? "${sweet.shelf_life_days} Days" : "-";

    if (isMobile) {
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? accentGold : borderCol,
            width: selected ? 1.2 : 1,
          ),
        ),
        child: Row(
          children: [
            // GestureDetector(
            //   onTap: () => _showImageDialog(sweet.image_url?.toString()),
            //   child: _thumb(sweet.image_url?.toString(), sweetName, size: 36),
            // ),
            // const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("$index. $sweetName",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: primaryDark,)),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 4,
                    children: [
                      // if (counterName != '-')
                      //   _metaBadge(counterName, primaryNavy.withOpacity(0.06), primaryNavy),
                      if (categoryName != '-')
                        _metaBadge(categoryName, Colors.blueGrey.withOpacity(0.08), Colors.blueGrey[800]!),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(width: 8),
            _compactQtyStepper(sweet),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: cardBg,
        border: const Border(bottom: BorderSide(color: borderCol, width: 0.8)),
      ),
      child: Row(
        children: [
          // Index
          SizedBox(
            width: 45,
            child: Text("${index.toString()}.",
              style: TextStyle(color: Colors.grey[600],fontSize: 12,fontWeight: FontWeight.w500),
            ),
          ),

          // Sweet Info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // GestureDetector(
                //   onTap: () => _showImageDialog(sweet.image_url?.toString()),
                //   child: _thumb(sweet.image_url?.toString(), sweetName, size: 32),
                // ),
                // const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(sweetName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: primaryDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Counter
          // Expanded(
          //   flex: 2,
          //   child: Text(counterName,style: const TextStyle(fontSize: 13,color: Colors.blueGrey,fontWeight: FontWeight.w500)),
          // ),

          // Category
          Expanded(
            flex: 2,
            child: Text(categoryName,
              style: TextStyle(fontSize: 12,color: Colors.grey[700],fontWeight: FontWeight.w500),
            ),
          ),

          // Shelf Life
          Expanded(
            flex: 2,
            child: Text(shelfLife,
              style: TextStyle(fontSize: 12,color: Colors.green[800],fontWeight: FontWeight.w600),
            ),
          ),

          // Quantity Stepper
          Expanded(
            flex: 2,
            child: Center(
              child: _compactQtyStepper(sweet),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaBadge(String label, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(label,style: TextStyle(fontSize: 9.5,fontWeight: FontWeight.w700,color: textCol)),
    );
  }

  Widget _compactQtyStepper(dynamic sweet) {
    final ctrl = _ctrlFor(sweet);
    final bool selected = _qtyOf(sweet) > 0;

    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: selected ? primaryNavy.withOpacity(0.05) : bgCol,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: selected ? primaryNavy.withOpacity(0.3) : borderCol,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepperBtn(Icons.remove, () => _bump(sweet, -1)),
          SizedBox(
            width: 32,
            child: TextField(
              controller: ctrl,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: primaryNavy,
              ),
              decoration: const InputDecoration(
                isDense: true,
                hintText: "0",
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) => _onQtyChanged(sweet, v),
            ),
          ),
          _stepperBtn(Icons.add, () => _bump(sweet, 1)),
        ],
      ),
    );
  }

  Widget _stepperBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 24,
        height: 28,
        child: Icon(icon, size: 13, color: primaryNavy),
      ),
    );
  }

  // ---------- BOTTOM SUBMIT BAR ----------
  Widget _buildBottomBar(bool isMobile) {
    return Container(
      padding:
      EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        border: const Border(top: BorderSide(color: borderCol)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Text(
                // "${_cart.length} Items Selected  •  Total Qty: $_totalUnits",
                "${_cart.length} Items Selected",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: primaryNavy,
                ),
              ),
            ),
            SizedBox(
              height: 34,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _confirmOrderDialog,
                icon: isLoading
                    ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.send_rounded,
                    size: 15, color: Colors.white),
                label: Text(
                  isLoading ? "SUBMITTING..." : "CONFIRM ORDER",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff2563EB),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- THUMBNAIL RENDER ----------
  // Widget _thumb(String? path, String? name, {double size = 32}) {
  //   final String initial =
  //   (name != null && name.isNotEmpty) ? name[0].toUpperCase() : "?";
  //
  //   Widget fallback = Container(
  //     width: size,
  //     height: size,
  //     alignment: Alignment.center,
  //     decoration: BoxDecoration(
  //       color: primaryNavy.withOpacity(0.08),
  //       borderRadius: BorderRadius.circular(6),
  //     ),
  //     child: Text(
  //       initial,
  //       style: TextStyle(
  //         fontWeight: FontWeight.w800,
  //         fontSize: size * 0.4,
  //         color: primaryNavy,
  //       ),
  //     ),
  //   );
  //
  //   if (path == null || path.isEmpty) return fallback;
  //   final String url = path.startsWith("http") ? path : "$serverUrlMedia$path";
  //
  //   return ClipRRect(
  //     borderRadius: BorderRadius.circular(6),
  //     child: Image.network(
  //       url,
  //       width: size,
  //       height: size,
  //       fit: BoxFit.cover,
  //       errorBuilder: (_, __, ___) => fallback,
  //     ),
  //   );
  // }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderCol),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Soft rounded icon background
            Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.search_off_rounded,
                size: 28,
                color: Color(0xff64748B),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "No Items Found",
              style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}