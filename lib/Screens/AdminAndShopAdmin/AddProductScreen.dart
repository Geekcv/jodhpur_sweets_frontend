import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:js_order_website/Screens/LoginUserDetails.dart';
import 'package:js_order_website/config/config.dart';

import '../../controllers/api_controller.dart';
import '../../models/FetchShopModel.dart';
import '../../provider/provider.dart';
import '../../utilities/functions.dart';
import '../../widgets/CustomDropDownSearch.dart';
import '../../widgets/TextInputField.dart';


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

  String? selectedDepartmentId;
  String? selectedSupplierId;

  // --- UNIT SELECTION LISTS ---
  static const List<String> basicUnitList = ["KG", "GM", "PCS"];
  static const List<String> bulkUnitList = ["BOX", "CARTON", "TRAY", "CONTAINER"];

  String selectedUnit = "KG";
  String? selectedBulkUnit;

  // Default layout Mode set to Grid
  bool isGridView = true;

  final nameController = TextEditingController();
  final hindiNameController = TextEditingController();
  final hsnCodeController = TextEditingController();
  final bulkConversionController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final shelfLifeController = TextEditingController();

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
      ref.read(master_Provider).fetchSuppliers();
      ref.read(master_Provider).fetchDepartment();

      if (LoginUserDetails.isAdmin) {
        ref.read(master_Provider).fetchShop();
      }
      ref.read(master_Provider).fetchCounter();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    hindiNameController.dispose();
    hsnCodeController.dispose();
    bulkConversionController.dispose();
    descController.dispose();
    priceController.dispose();
    shelfLifeController.dispose();
    super.dispose();
  }

  // --- SAVE LOGIC ---
  Future<void> _handleSave() async {
    if (nameController.text.trim().isEmpty) return _showToast("Sweet Name is required!", Colors.redAccent);
    if (selectedCatId == null) return _showToast("Select Category!", Colors.redAccent);
    if (selectedDepartmentId == null) return _showToast("Select Department!", Colors.redAccent);
    if (selectedSupplierId == null) return _showToast("Select Supplier!", Colors.redAccent);

    final priceStr = priceController.text.trim();
    if (priceStr.isEmpty || double.tryParse(priceStr) == null || double.parse(priceStr) <= 0) {
      return _showToast("Enter valid Price!", Colors.redAccent);
    }

    if (selectedBulkUnit != null && selectedBulkUnit!.isNotEmpty) {
      if (bulkConversionController.text.trim().isEmpty) {
        return _showToast("Bulk Conversion is required when Bulk Unit is selected!", Colors.redAccent);
      }
    }

    final shelfLifeStr = shelfLifeController.text.trim();
    if (shelfLifeStr.isNotEmpty && int.tryParse(shelfLifeStr) == null) {
      return _showToast("Shelf Life must be a number!", Colors.redAccent);
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
        "hindi_sweets_name": hindiNameController.text.trim(),
        "hsn_code": hsnCodeController.text.trim(),
        "description": descController.text.trim(),
        "price": priceStr,
        "department_id": selectedDepartmentId,
        "supplier_id": selectedSupplierId,
        "category_id": selectedCatId,
        "shop_id": LoginUserDetails.isAdmin ? selectedShopId : LoginUserDetails.shopId,
        "counter_id": selectedCounterId,
        "shelf_life_days": shelfLifeController.text.trim().isEmpty ? "0" : shelfLifeController.text.trim(),
        "unit": selectedUnit,
        "bulk_unit": selectedBulkUnit ?? "",
        "Bulk_conversion": bulkConversionController.text.trim(),
        "return_type": selectedReturnType,
        "image_url": attachments_uploaded.isNotEmpty ? attachments_uploaded.first['foPa'] : "",
      };

      var res = await ApiController.addSweets(params: productData);
      if (res != null && res['status'] == 0) {
        _showToast("Sweet Item Saved Successfully!", Colors.green);
        _resetForm();
        ref.read(master_Provider).fetchSweets();
      } else if (res != null && res['status'] == 1) {
        _showToast("${res['msg']}", Colors.red);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _resetForm() {
    nameController.clear();
    hindiNameController.clear();
    hsnCodeController.clear();
    bulkConversionController.clear();
    descController.clear();
    priceController.clear();
    shelfLifeController.clear();
    attachments_uploaded.clear();
    selectedCatId = null;
    selectedDepartmentId = null;
    selectedSupplierId = null;
    selectedUnit = "KG";
    selectedBulkUnit = null;
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
        bool isMobile = constraints.maxWidth < 700;
        bool isTab = constraints.maxWidth >= 700 && constraints.maxWidth < 1100;

        return Scaffold(
          backgroundColor: const Color(0xffF4F7FA),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 12 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader("Sweet Master", sweets.length),
                const SizedBox(height: 20),
                _buildResponsiveForm(isMobile, masterProv),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle("REGISTERED INVENTORY"),
                    // Toggle Grid / List View
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderCol),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.grid_view_rounded, size: 20, color: isGridView ? accentGold : Colors.grey),
                            onPressed: () => setState(() => isGridView = true),
                            tooltip: "Grid View",
                          ),
                          Container(width: 1, height: 20, color: borderCol),
                          IconButton(
                            icon: Icon(Icons.format_list_bulleted_rounded, size: 20, color: !isGridView ? accentGold : Colors.grey),
                            onPressed: () => setState(() => isGridView = false),
                            tooltip: "List View",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                isGridView
                    ? _buildGridView(sweets, masterProv.loading, isMobile, isTab)
                    : _buildScrollableList(sweets, masterProv.loading, isMobile),
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
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
        const SizedBox(width: 25),
        Expanded(child: _buildFormInputs(isMobile, masterProv)),
      ]),
    );
  }

  Widget _buildFormInputs(bool isMobile, var masterProv) {
    final List<dynamic> allCategoriesList = masterProv.allCategories ?? [];
    final List<dynamic> allDepartmentsList = masterProv.allDepartments ?? [];

    // --- Dynamic filtering logic for Vice-Versa condition ---
    List<dynamic> filteredCategories = List.from(allCategoriesList);
    List<dynamic> filteredDepartments = List.from(allDepartmentsList);

    // 1. Agar Department selected hai, to sirf us Department ki Categories filter honge
    if (selectedDepartmentId != null) {
      filteredCategories = allCategoriesList.where((cat) {
        return cat.department_id?.toString() == selectedDepartmentId.toString();
      }).toList();
    }

    // 2. Agar Category selected hai aur Department pehle se select nahi tha, to Department list filter hogi
    if (selectedCatId != null && selectedDepartmentId == null) {
      final selectedCategoryObj = allCategoriesList.cast<dynamic?>().firstWhere(
            (cat) => cat?.row_id?.toString() == selectedCatId,
        orElse: () => null,
      );
      if (selectedCategoryObj != null && selectedCategoryObj.department_id != null) {
        filteredDepartments = allDepartmentsList.where((dept) {
          return dept.row_id?.toString() == selectedCategoryObj.department_id.toString();
        }).toList();
      }
    }

    return Column(
      children: [
        _formGrid(isMobile, [
          _box("SWEET NAME", nameController, hint: "Name"),
          _box("HINDI SWEET NAME", hindiNameController, hint: "हिन्दी नाम"),
          _commonDropdown(
            label: "DEPARTMENT",
            items: filteredDepartments,
            itemLabel: (v) => v.department_name ?? "",
            // --- FIXED: Safe type conversion to avoid DDC TypeError ---
            selectedItem: selectedDepartmentId == null
                ? null
                : allDepartmentsList.cast<dynamic?>().firstWhere(
                  (d) => d?.row_id?.toString() == selectedDepartmentId,
              orElse: () => null,
            ),
            onSelected: (v) {
              setState(() {
                selectedDepartmentId = v?.row_id?.toString();
                // Reset category if selected category doesn't match selected department
                if (selectedCatId != null) {
                  final catObj = allCategoriesList.cast<dynamic?>().firstWhere(
                        (c) => c?.row_id?.toString() == selectedCatId,
                    orElse: () => null,
                  );
                  if (catObj != null && catObj.department_id?.toString() != selectedDepartmentId) {
                    selectedCatId = null;
                  }
                }
              });
            },
          ),
          // if(LoginUserDetails.isAdmin)
          // // _commonDropdown("SHOP *", masterProv.allShops ?? [], (v) => v.shop_name, (v) => selectedShopId = v.row_id.toString()),
          //   _commonDropdown(
          //     label: "SHOP *",
          //     items: masterProv.allShops ?? [],
          //     itemLabel: (v) => v.shop_name,
          //     // is logic ko dhyan se dekhein
          //     selectedItem: selectedShopId == null
          //         ? null
          //         : (masterProv.allShops ?? []).cast<FetchShopModel?>().firstWhere(
          //             (s) => s?.row_id.toString() == selectedShopId,
          //         orElse: () => null
          //     ),
          //     onSelected: (val) {
          //       setState(() {
          //         selectedShopId = val?.row_id.toString();
          //         selectedCatId = null;
          //         selectedCounterId = null;
          //       });
          //
          //       if (selectedShopId != null) {
          //         ref.read(master_Provider).fetchCategoryAndCounterAccoridngToShopIdWhenAddSweet(
          //             params: {'shop_id': selectedShopId}
          //         );
          //       }
          //     },
          //   ),



          // _commonDropdown("CATEGORY *", masterProv.allCategories ?? [], (v) => v.category_name, (v) => selectedCatId = v.row_id.toString()),
          _commonDropdown(
            label: "CATEGORY",
            items: filteredCategories,
            itemLabel: (v) => v.category_name ?? "",
            // --- FIXED: Safe type conversion to avoid DDC TypeError ---
            selectedItem: selectedCatId == null
                ? null
                : filteredCategories.cast<dynamic?>().firstWhere(
                  (c) => c?.row_id?.toString() == selectedCatId,
              orElse: () => null,
            ),
            onSelected: (v) {
              setState(() {
                selectedCatId = v?.row_id?.toString();
                if (v != null && v.department_id != null) {
                  selectedDepartmentId = v.department_id.toString();
                }
              });
            },
          ),
          _commonDropdown(
            label: "SUPPLIER",
            items: masterProv.allSuppliers ?? [],
            itemLabel: (v) => v.supplier_name ?? "",
            selectedItem: (masterProv.allSuppliers ?? []).cast<dynamic>().firstWhere(
                  (s) => s.row_id.toString() == selectedSupplierId,
              orElse: () => null,
            ),
            onSelected: (v) => setState(() => selectedSupplierId = v?.row_id.toString()),
          ),
        ]),
        const SizedBox(height: 14),
        _formGrid(isMobile, [
          _simpleDropdown("BASIC UNIT", basicUnitList, selectedUnit, (v) => setState(() => selectedUnit = v ?? "KG")),
          _simpleDropdown("BULK UNIT", bulkUnitList, selectedBulkUnit, (v) => setState(() => selectedBulkUnit = v)),
          _box("BULK CONVERSION", bulkConversionController, isNum: true, hint: "e.g. 67"),
        ]),
        const SizedBox(height: 14),
        _formGrid(isMobile, [
          _box("HSN CODE", hsnCodeController, hint: "21069099"),
          _box("SHELF LIFE (days)", shelfLifeController, isNum: true),
          _simpleDropdown("RETURN TYPE", ["RETURNABLE", "NON-RETURNABLE", "NONE"], selectedReturnType, (v) => setState(() => selectedReturnType = v)),
        ]),
        const SizedBox(height: 14),
        _formGrid(isMobile, [
          _box("PRICE (₹)", priceController, isNum: true),
          _box("DESCRIPTION", descController, hint: "Short notes..."),
        ]),
        const SizedBox(height: 20),
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
                width: 120,
                height: 120,
                decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderCol, width: 1.5)),
                child: attachments_uploaded.isEmpty
                    ? const Icon(Icons.add_a_photo_outlined, size: 32, color: Colors.grey)
                    : ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(url + attachments_uploaded.first['foPa'], fit: BoxFit.cover)),
              ),
            ),
            if (attachments_uploaded.isNotEmpty)
              Positioned(
                top: 5,
                right: 5,
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

  // --- DEFAULT GRID VIEW ---
  Widget _buildGridView(List sweets, bool loading, bool isMobile, bool isTab) {
    int crossCount = isMobile ? 1 : (isTab ? 2 : 3);

    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      child: Column(
        children: [
          if (loading) const LinearProgressIndicator(minHeight: 2, color: accentGold),
          sweets.isEmpty && !loading
              ? Container(
            height: 250,
            alignment: Alignment.center,
            child: Text("No items found", style: TextStyle(color: Colors.grey[400])),
          )
              : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sweets.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 145,
            ),
            itemBuilder: (context, index) {
              final item = sweets[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (item.image_url != null && item.image_url.toString().isNotEmpty) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _showImageDialog(item.image_url);
                          });
                        }
                      },
                      child: Hero(
                        tag: "img_${item.row_id}_$index",
                        child: _tableImg(item.image_url, size: 80),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.sweet_name ?? "-",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryDark),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xffFEF3C7), borderRadius: BorderRadius.circular(4)),
                                child: Text("${item.shelf_life_days ?? '0'} D", style: const TextStyle(fontSize: 10, color: Color(0xffB45309), fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          if (item.hindi_sweets_name != null && item.hindi_sweets_name.toString().isNotEmpty)
                          Text(item.hindi_sweets_name.toString(), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          Wrap(
                            spacing: 4,
                            children: [
                              _badge(item.department_name ?? "-", const Color(0xff2563EB), const Color(0xffEFF6FF)),
                              _badge(item.category_name ?? "-", const Color(0xff475569), const Color(0xffF1F5F9)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("₹${item.price ?? '0'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: successGreen)),
                              Text("Unit: ${item.unit ?? 'KG'}", style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                            ],
                          ),
                        ],
                      ),
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

  Widget _badge(String text, Color textCol, Color bgCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bgCol, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(fontSize: 10, color: textCol, fontWeight: FontWeight.w600)),
    );
  }

  // --- LIST VIEW ---
  Widget _buildScrollableList(List sweets, bool loading, bool isMobile) {
    return Container(
      height: 400,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderCol)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            color: bgLight,
            child: Row(
              children: [
                const SizedBox(width: 50, child: Text("IMG", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
                const SizedBox(width: 20),
                const Expanded(flex: 3, child: Text("ITEM NAME", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
                const Expanded(flex: 2, child: Text("DEPARTMENT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
                const Expanded(flex: 2, child: Text("CATEGORY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
                const Expanded(flex: 2, child: Text("SUPPLIER", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
                const Expanded(flex: 1, child: Text("PRICE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
                const Expanded(flex: 1, child: Text("S.LIFE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
              ],
            ),
          ),
          if (loading) const LinearProgressIndicator(minHeight: 2, color: accentGold),
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
                      SizedBox(
                        width: 50,
                        child: GestureDetector(
                          onTap: () {
                            if (item.image_url != null && item.image_url != "") {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _showImageDialog(item.image_url);
                              });
                            }
                          },
                          child: Hero(
                            tag: "img_list_${item.row_id}_$i",
                            child: _tableImg(item.image_url, size: 42),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.sweet_name ?? "-", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryDark)),
                            if (item.hindi_sweets_name != null && item.hindi_sweets_name.toString().isNotEmpty)
                              Text(item.hindi_sweets_name.toString(), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Expanded(flex: 2, child: Text(item.department_name ?? "-", style: const TextStyle(fontSize: 12, color: Colors.blueGrey))),
                      Expanded(flex: 2, child: Text(item.category_name ?? "-", style: const TextStyle(fontSize: 12))),
                      Expanded(flex: 2, child: Text(item.supplier_name ?? "-", style: const TextStyle(fontSize: 12, color: Colors.blueGrey))),
                      Expanded(flex: 1, child: Text("₹${item.price ?? '0'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: successGreen))),
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

  Widget _tableImg(String? path, {double size = 42}) {
    final bool hasImage = path != null && path.trim().isNotEmpty;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffE2E8F0), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: hasImage
            ? Image.network(
          "$serverUrlMedia$path",
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => const Icon(Icons.fastfood_outlined, size: 18, color: Color(0xff94A3B8)),
        )
            : const Icon(Icons.fastfood_outlined, size: 18, color: Color(0xff94A3B8)),
      ),
    );
  }

  void _showImageDialog(String path) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(onTap: () => Navigator.pop(context), child: Container(color: Colors.transparent)),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75, maxWidth: 600),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: InteractiveViewer(child: Image.network("$serverUrlMedia$path", fit: BoxFit.contain)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.cancel, color: Colors.white, size: 38)),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'^\s+')),
              if (isNum) FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _commonDropdown({
    required String label,
    required List items,
    required String Function(dynamic) itemLabel,
    required Function(dynamic) onSelected,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.white,
              menuMaxHeight: 250,
              isExpanded: true,
              value: currentValue,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              hint: const Text("Select", style: TextStyle(fontSize: 12, color: Colors.grey)),
              items: items
                  .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 12, color: Color(0xff1A2B4C)))))
                  .toList(),
              onChanged: (v) => onSel(v),
            ),
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
        for (var e in data) {
          attachments_uploaded.add({"foPa": e['foPa'].toString()});
        }
        setState(() {});
      }
    }
  }
}