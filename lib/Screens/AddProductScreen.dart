import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:js_order_website/Screens/LoginUserDetails.dart';
import 'package:js_order_website/config/config.dart';
import '../models/FetchShopModel.dart';
import '../provider/provider.dart';
import '../utilities/functions.dart';
import '../controllers/api_controller.dart';
import '../widgets/CustomDropDownSearch.dart';
import '../widgets/TextInputField.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  bool isLoading = false;
  List attachments_uploaded = [];
  String? selectedCatId;
  String? selectedShopId;
  String? selectedCounterId;
  String? selectedReturnType;

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final shelfLifeController = TextEditingController();
  final unitController = TextEditingController(text: "kg");

  static const Color primaryDark = Color(0xff1A2B4C);
  static const Color accentGold = Color(0xffC5A059);
  static const Color borderCol = Color(0xffE2E8F0);
  static const Color successGreen = Color(0xff108548);
  static const Color bgLight = Color(0xffF8FAFC);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(master_Provider).fetchCategory();
      ref.read(master_Provider).fetchSweets();
      // ref.read(master_Provider).fetchShop();
      if(LoginUserDetails.isAdmin) {
        ref.read(master_Provider).fetchShop();
      }
      ref.read(master_Provider).fetchCounter();
    });
  }

  // --- SAVE LOGIC ---
  Future<void> _handleSave() async {
    if (nameController.text.trim().isEmpty) return _showToast("Sweet Name is required!", Colors.redAccent);
    if (selectedCatId == null) return _showToast("Select Category!", Colors.redAccent);
    if (selectedShopId == null && LoginUserDetails.isAdmin) return _showToast("Select Shop!", Colors.redAccent);
    if (selectedCounterId == null) return _showToast("Select Counter!", Colors.redAccent);

    final priceStr = priceController.text.trim();
    if (priceStr.isEmpty || double.tryParse(priceStr) == null || double.parse(priceStr) <= 0) {
      return _showToast("Enter valid Price!", Colors.redAccent);
    }

    final shelfLifeStr = shelfLifeController.text.trim();
    if (shelfLifeStr.isNotEmpty && int.tryParse(shelfLifeStr) == null) {
      return _showToast("Shelf Life must be a number!", Colors.redAccent);
    }

    final desc = descController.text.trim();
    if (desc.isEmpty) {
      return _showToast("Description is required!", Colors.redAccent);
    }


    if (attachments_uploaded.isEmpty) {
      return _showToast("Please upload a product image!", Colors.orangeAccent);
    }

    if (selectedReturnType == null || selectedReturnType!.isEmpty) {
      return _showToast("Please select a Return Type!", Colors.redAccent);
    }

    setState(() => isLoading = true);
    try {
      final productData = {
        "sweet_name": nameController.text.trim(),
        "description": descController.text.trim(),
        "price": priceStr,
        "category_id": selectedCatId,
        "shop_id": LoginUserDetails.isAdmin ? selectedShopId : LoginUserDetails.shopId,
        "counter_id": selectedCounterId,
        "shelf_life_days": shelfLifeController.text.trim().isEmpty ? "0" : shelfLifeController.text.trim(),
        "unit": unitController.text.trim(),
        "return_type": selectedReturnType,
        "image_url": attachments_uploaded.isNotEmpty ? attachments_uploaded.first['foPa'] : "",
      };

      var res = await ApiController.addSweets(params: productData);
      if (res != null && res['status'] == 0) {
        _showToast("Sweet Item Saved Successfully!", Colors.green);
        _resetForm();
        ref.read(master_Provider).fetchSweets();
      }
      if (res['status'] == 1) {
        _showToast("${res['msg']}", Colors.red);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _resetForm() {
    nameController.clear();
    descController.clear();
    priceController.clear();
    shelfLifeController.clear();
    unitController.text = "kg";
    attachments_uploaded.clear();
    selectedCatId = null;
    selectedShopId = null;
    selectedCounterId = null;
    selectedReturnType = null;
    setState(() {});
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final masterProv = ref.watch(master_Provider);
    final sweets = masterProv.allSweets ?? [];

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 900;

        return Scaffold(
          backgroundColor: const Color(0xffF4F7FA),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader("Sweet Master", sweets.length),
                const SizedBox(height: 25),
                _buildResponsiveForm(isMobile, masterProv),
                const SizedBox(height: 35),
                _buildSectionTitle("REGISTERED INVENTORY"),
                const SizedBox(height: 15),
                // FIXED HEIGHT SCROLLABLE LIST
                _buildScrollableList(sweets, masterProv.loading, isMobile),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponsiveForm(bool isMobile, var masterProv) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
      ),
      child: isMobile
          ? Column(children: [
        _buildLargeImagePicker(),
        const SizedBox(height: 20),
        _buildFormInputs(isMobile, masterProv),
      ])
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildLargeImagePicker(),
        const SizedBox(width: 30),
        Expanded(child: _buildFormInputs(isMobile, masterProv)),
      ]),
    );
  }

  Widget _buildFormInputs(bool isMobile, var masterProv) {
    return Column(
      children: [
        _formGrid(isMobile, [
          _box("SWEET NAME *", nameController, hint: "Name"),

          if(LoginUserDetails.isAdmin)
          // _commonDropdown("SHOP *", masterProv.allShops ?? [], (v) => v.shop_name, (v) => selectedShopId = v.row_id.toString()),
            _commonDropdown(
              label: "SHOP *",
              items: masterProv.allShops ?? [],
              itemLabel: (v) => v.shop_name,
              // is logic ko dhyan se dekhein
              selectedItem: selectedShopId == null
                  ? null
                  : (masterProv.allShops ?? []).cast<FetchShopModel?>().firstWhere(
                      (s) => s?.row_id.toString() == selectedShopId,
                  orElse: () => null
              ),
              onSelected: (val) {
                setState(() {
                  selectedShopId = val?.row_id.toString();
                  selectedCatId = null;
                  selectedCounterId = null;
                });

                if (selectedShopId != null) {
                  ref.read(master_Provider).fetchCategoryAndCounterAccoridngToShopIdWhenAddSweet(
                      params: {'shop_id': selectedShopId}
                  );
                }
              },
            ),



          // _commonDropdown("CATEGORY *", masterProv.allCategories ?? [], (v) => v.category_name, (v) => selectedCatId = v.row_id.toString()),
          _commonDropdown(
            label: "CATEGORY *",
            items: masterProv.allCategories ?? [],
            itemLabel: (v) => v.category_name,
            selectedItem: (masterProv.allCategories ?? []).cast<dynamic>().firstWhere(
                    (c) => c.row_id.toString() == selectedCatId,
                orElse: () => null
            ),
            onSelected: (v) => setState(() => selectedCatId = v?.row_id.toString()),
          ),


        ]),
        const SizedBox(height: 16),
        _formGrid(isMobile, [
          // _commonDropdown("COUNTER *", masterProv.allCounters ?? [], (v) => v.counter_name, (v) => selectedCounterId = v.row_id.toString()),
          _commonDropdown(
            label: "COUNTER *",
            items: masterProv.allCounters ?? [],
            itemLabel: (v) => v.counter_name,
            selectedItem: (masterProv.allCounters ?? []).cast<dynamic>().firstWhere(
                    (c) => c.row_id.toString() == selectedCounterId,
                orElse: () => null
            ),
            onSelected: (v) => setState(() => selectedCounterId = v?.row_id.toString()),
          ),

          _box("PRICE (₹) *", priceController, isNum: true),
          _box("UNIT", unitController, hint: "kg/pc"),
        ]),
        const SizedBox(height: 16),
        _formGrid(isMobile, [
          _box("SHELF LIFE (days)", shelfLifeController, isNum: true),
          _simpleDropdown("RETURN TYPE", ["RETURNABLE", "NON-RETURNABLE"], selectedReturnType, (v) => setState(() => selectedReturnType = v)),
          _box("DESCRIPTION", descController, hint: "Short notes..."),
        ]),
        const SizedBox(height: 25),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(width: isMobile ? double.infinity : 180, height: 45, child: _buildSaveButton()),
        ),
      ],
    );
  }

  Widget _formGrid(bool isMobile, List<Widget> children) {
    if (isMobile) return Column(children: children.map((e) => Padding(padding: const EdgeInsets.only(bottom: 12), child: e)).toList());
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: children.map((e) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: e))).toList());
  }

  // --- MODERN IMAGE PICKER WITH REMOVE OPTION ---
  Widget _buildLargeImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("IMAGE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
        const SizedBox(height: 8),
        Stack(
          children: [
            InkWell(
              onTap: _pickFile,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderCol, width: 1.5)),
                child: attachments_uploaded.isEmpty
                    ? const Icon(Icons.add_a_photo_outlined, size: 32, color: Colors.grey)
                    : ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(url + attachments_uploaded.first['foPa'], fit: BoxFit.cover)),
              ),
            ),
            if (attachments_uploaded.isNotEmpty)
              Positioned(
                top: 5, right: 5,
                child: InkWell(
                  onTap: () => setState(() => attachments_uploaded.clear()),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // --- SCROLLABLE LIST WITH FIXED HEIGHT ---
  Widget _buildScrollableList(List sweets, bool loading, bool isMobile) {
    return Container(
      height: 400, // Height thodi choti kar di hai as requested
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderCol)
      ),
      child: Column(
        children: [
          // --- TABLE HEADER ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            color: bgLight,
            child: Row(
              children: [
                Expanded(flex: 1, child: Text("IMG", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
                Container(width: 60),
                Expanded(flex: 3, child: Text("ITEM NAME", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
                Expanded(flex: 2, child: Text("SHOP", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
                Expanded(flex: 2, child: Text("CATEGORY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
                Expanded(flex: 2, child: Text("COUNTER", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
                Expanded(flex: 1, child: Text("PRICE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
                Expanded(flex: 1, child: Text("S.LIFE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
              ],
            ),
          ),

          if (loading) const LinearProgressIndicator(minHeight: 2, color: accentGold),

          // --- TABLE BODY ---
          Expanded(
            child: sweets.isEmpty && !loading
                ? Center(child: Text("No items found", style: TextStyle(color: Colors.grey[400])))
                : ListView.separated(
              itemCount: sweets.length,
              separatorBuilder: (c, i) => const Divider(height: 1, color: Color(0xffF1F5F9)),
              itemBuilder: (c, i) {
                final item = sweets[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  child: Row(
                    children: [
                      // 1. Image Column with Click functionality
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            if(item.image_url != null && item.image_url != "") {
                              _showImageDialog(item.image_url);
                            }
                          },
                          child: Hero(
                            tag: "img_${item.row_id}", // Animation ke liye
                            child: _tableImg(item.image_url),
                          ),
                        ),
                      ),
                      Container(width: 60),
                      Expanded(flex: 3, child: Text(item.sweet_name ?? "-", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryDark))),
                      Expanded(flex: 2, child: Text(item.shop_name ?? "-", style: const TextStyle(fontSize: 12, color: Colors.blueGrey))),
                      Expanded(flex: 2, child: Text(item.category_name ?? "-", style: const TextStyle(fontSize: 12))),
                      Expanded(flex: 2, child: Text(item.counter_name ?? "-", style: const TextStyle(fontSize: 12, color: Colors.blueGrey))),
                      Expanded(flex: 1, child: Text("₹${item.price}", style: const TextStyle(fontWeight: FontWeight.bold, color: successGreen))),
                      Expanded(flex: 1, child: Text("${item.shelf_life_days ?? '0'} D", style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

// Image Thumbnail Helper
  Widget _tableImg(String? path) {
    return Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
          color: bgLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderCol.withOpacity(0.5))
      ),
      child: (path != null && path.isNotEmpty)
          ? ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Image.network("$serverUrlMedia$path", fit: BoxFit.cover, errorBuilder: (c,e,s) => Icon(Icons.broken_image, size: 16, color: Colors.grey)))
          : const Icon(Icons.fastfood_outlined, size: 18, color: Colors.grey),
    );
  }

// --- MST DIALOG TO SHOW FULL IMAGE ---
  void _showImageDialog(String path) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Click to Close
            GestureDetector(onTap: () => Navigator.pop(context), child: Container(color: Colors.transparent)),

            // The Image Container
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)]
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      "$serverUrlMedia$path",
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) => progress == null ? child : const Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator()),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Close Button below image
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel, color: Colors.white, size: 40),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }


  // Widget _tableImg(String? path) {
  //   return Container(
  //     width: 40, height: 40,
  //     decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(6)),
  //     child: (path != null && path.isNotEmpty)
  //         ? ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network("$serverUrlMedia$path", fit: BoxFit.cover))
  //         : const Icon(Icons.fastfood, size: 18, color: Colors.grey),
  //   );
  // }

  Widget _box(String label, TextEditingController ctrl, {bool isNum = false, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: CustomTextInput(
            hintText: hint ?? label.toLowerCase(),
            controller: ctrl,
            keyboardType: isNum ? TextInputType.number : TextInputType.text,
            // STRICT VALIDATION: No spaces at start
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'^\s+')),
              if (isNum) FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _commonDropdown(String label, List items, String Function(dynamic) itemLabel, Function(dynamic) onSelected) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
  //       const SizedBox(height: 6),
  //       SizedBox(
  //         height: 40,
  //         child: CustomDropdownSearch<dynamic>(
  //           items: items,
  //           itemLabelBuilder: itemLabel,
  //           compareFn: (i, s) => i.row_id.toString() == s.row_id.toString(),
  //           onChanged: (val) => setState(() => onSelected(val)),
  //           hintText: "Select",
  //         ),
  //       ),
  //     ],
  //   );
  // }


  Widget _commonDropdown({required String label,required List items,required String Function(dynamic) itemLabel, required Function(dynamic) onSelected,
    dynamic selectedItem,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: CustomDropdownSearch<dynamic>(
            items: items,
            itemLabelBuilder: itemLabel,
            selectedItem: selectedItem,
            compareFn: (i, s) => i.row_id.toString() == s.row_id.toString(),
            onChanged: (val) => onSelected(val),
            hintText: "Select",
          ),
        ),
      ],
    );
  }





  Widget _simpleDropdown(String label, List<String> items, String? currentValue, Function(String?) onSel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xff64748B), letterSpacing: 1)),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: const EdgeInsets.only(left: 12, right: 4),
          decoration: BoxDecoration(
            color: Colors.white, // Ek dum white background
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: currentValue,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                    hint: const Text("Select Type", style: TextStyle(fontSize: 13, color: Colors.grey)),
                    items: items.map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, style: const TextStyle(fontSize: 12, color: Color(0xff1A2B4C)))
                    )).toList(),
                    onChanged: (v) => onSel(v),
                  ),
                ),
              ),
              // Agar value selected hai toh "Clear" button dikhao
              // if (currentValue != null)
              //   IconButton(
              //     icon: const Icon(Icons.cancel, size: 18, color: Colors.grey),
              //     onPressed: () => onSel(null), // Unselect logic
              //   ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : _handleSave,
      style: ElevatedButton.styleFrom(backgroundColor: successGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      child: isLoading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text("SAVE ITEM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildHeader(String title, int count) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: primaryDark)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: accentGold.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text("$count ITEMS", style: const TextStyle(color: accentGold, fontSize: 10, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2));
  }

  Future<void> _pickFile() async {
    var token = await ApiController.getloggedinUserToken();
    var res = await Functions.chooseFileUsingFilePicker(token);
    if (res != null && res['rsp'] != null && res['rsp']['status'] == true) {
      var data = res['rsp']['data']?['filesInfo'];
      if (data != null) {
        attachments_uploaded.clear();
        for (var e in data) { attachments_uploaded.add({"foPa": e['foPa'].toString()}); }
        setState(() {});
      }
    }
  }
}