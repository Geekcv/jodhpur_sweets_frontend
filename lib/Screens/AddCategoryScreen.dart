import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:js_order_website/models/FetchDepartmentModel.dart';
import 'package:js_order_website/models/FetchShopModel.dart';
import '../controllers/api_controller.dart';
import '../provider/provider.dart';
import '../widgets/CustomDropDownSearch.dart';
import '../widgets/TextInputField.dart';
import 'LoginUserDetails.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {

  bool isLoading = false;
  bool showErrors = false;

  final TextEditingController catNameController = TextEditingController();
  String? selectedDeptId;
  String? shop_id;
  var editingRowId;

  static const Color primaryDark = Color(0xff1A2B4C);
  static const Color successGreen = Color(0xff108548);
  static const Color borderCol = Color(0xffE2E8F0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(master_Provider).fetchDepartment();
      ref.read(master_Provider).fetchCategory();
      // ref.read(master_Provider).fetchShop();
      if(LoginUserDetails.isAdmin) {
        ref.read(master_Provider).fetchShop();
      }
    });
  }




  Future<void> _submitCategory() async {
    if ((shop_id == null && LoginUserDetails.isAdmin) || selectedDeptId == null || catNameController.text.trim().isEmpty) {
      setState(() => showErrors = true);
      Timer(const Duration(seconds: 3), () => setState(() => showErrors = false));
      return;
    }

    setState(() => isLoading = true);
    final tobeSendData = {
      if (editingRowId != null) "row_id": editingRowId,
      "department_id": selectedDeptId,
      "shop_id": LoginUserDetails.isAdmin ? shop_id : LoginUserDetails.shopId,
      "category_name": catNameController.text.trim(),
    };

    var response = await ApiController.addCategory(params: tobeSendData);
    if (response != null && response['status'] == 0) {
      _showToast("${response['msg']}", Colors.green);
      catNameController.clear();
      setState(() {
        selectedDeptId = null;
        shop_id = null;
        showErrors = false;
        editingRowId = null;
      });
      ref.read(master_Provider).fetchCategory();
    }
    if (response != null && response['status'] == 1) {
      _showToast("${response['msg']}", Colors.red);
    }
    if (mounted) setState(() => isLoading = false);
  }


  void _showToast(String msg, Color col) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: col));
  }


  @override
  Widget build(BuildContext context) {
    final masterProv = ref.watch(master_Provider);
    final List<FetchDepartmentModel> departments = List<FetchDepartmentModel>.from(masterProv.allDepartments ?? []);
    final List<FetchShopModel> shops = List<FetchShopModel>.from(masterProv.allShops ?? []);
    final List<dynamic> allCats = masterProv.allCategories ?? [];

    return Scaffold(
      backgroundColor: const Color(0xffF9FBFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(allCats.length),
            const SizedBox(height: 20),

            // --- 1. QUICK ADD FORM ---
            _buildQuickAddForm(departments,shops),

            if (showErrors)
              const Padding(
                padding: EdgeInsets.only(top: 8, left: 5),
                child: Text("* Please select department and enter name", style: TextStyle(color: Colors.red, fontSize: 11)),
              ),

            const SizedBox(height: 25),

            // --- 2. CATEGORY LIST TABLE ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                children: [
                  _buildTableHeader(),
                  const Divider(height: 1, color: borderCol),
                  masterProv.loading
                      ? const Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())
                      : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allCats.length,
                    separatorBuilder: (c, i) => const Divider(height: 1, color: borderCol),
                    itemBuilder: (c, i) => _buildCategoryRow(allCats[i], i + 1),
                  ),
                  if (allCats.isEmpty && !masterProv.loading)
                    const Padding(padding: EdgeInsets.all(40), child: Text("No categories found.")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildQuickAddForm(List<FetchDepartmentModel> departments, List<FetchShopModel> shops) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderCol),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 800;

          return Wrap(
            spacing: 15,
            runSpacing: 15,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              // 1. Department Dropdown
              if(LoginUserDetails.isAdmin)
                _dropdownBoxFoShop("SELECT SHOP", shops, isWide ? 250 : double.infinity),

              _dropdownBox("SELECT DEPARTMENT", departments, isWide ? 250 : double.infinity),

              // 2. Category Name (Using CustomTextInput)
              _box(isWide ? 250 : double.infinity, "CATEGORY NAME", catNameController),

              // 3. Save Button
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _submitCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: successGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      elevation: 0,
                    ),
                    icon: isLoading
                        ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.save, size: 16),
                    label: const Text("SAVE CATEGORY", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

// Custom Dropdown Box
  Widget _dropdownBox(String label, List<FetchDepartmentModel> departments, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(height: 5),
        SizedBox(
          width: width,
          height: 38,
          child: CustomDropdownSearch<FetchDepartmentModel>(
            items: departments,
            itemLabelBuilder: (dept) => dept.department_name,
            compareFn: (a, b) => a.row_id == b.row_id,
            selectedItem: selectedDeptId != null
                ? departments.firstWhere((d) => d.row_id.toString() == selectedDeptId)
                : null,
            onChanged: (val) => setState(() => selectedDeptId = val?.row_id.toString()),
            hintText: "Select Department",
          ),
        ),
      ],
    );
  }


  Widget _dropdownBoxFoShop(String label, List<FetchShopModel> shop, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(height: 5),
        SizedBox(
          width: width,
          height: 38,
          child: CustomDropdownSearch<FetchShopModel>(
            items: shop,
            itemLabelBuilder: (dept) => dept.shop_name,
            compareFn: (a, b) => a.row_id == b.row_id,
            selectedItem: shop_id != null
                ? shop.firstWhere((d) => d.row_id.toString() == shop_id)
                : null,
            onChanged: (val) {
              setState(() {
                shop_id = val?.row_id.toString();
                selectedDeptId = null;
              });

              if (shop_id != null) {
                ref.read(master_Provider).fetchDeptAccoridngToShopIdWhenAddCategory(params: {'shop_id': shop_id});
              }
            },
            // onChanged: (val) => setState(() => shop_id = val?.row_id.toString()),
            hintText: "Select Shop",
          ),
        ),
      ],
    );
  }

// Custom Text Input Box
  Widget _box(double width, String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(height: 5),
        SizedBox(
          width: width,
          child: CustomTextInput(
            hintText: label.toLowerCase(),
            controller: ctrl,
            height: 38,
            maxLines: 1,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'^\s')), // No leading space
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(int count) {
    return Row(
      children: [
        const Text("Category Master", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryDark)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text("$count Categories", style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: const Color(0xffF8FAFC),
      child: Row(
        children: [
          const SizedBox(width: 50, child: Text("S.N.", style: _hStyle)),
          const Expanded(flex: 3, child: Text("SHOP NAME", style: _hStyle)),
          const Expanded(flex: 3, child: Text("CATEGORY NAME", style: _hStyle)),
          const Expanded(flex: 2, child: Text("DEPARTMENT", style: _hStyle)),
          // if(LoginUserDetails.isAdmin)
          // const SizedBox(width: 80, child: Text("ACTIONS", textAlign: TextAlign.right, style: _hStyle)),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(dynamic cat, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 50, child: Text(index.toString().padLeft(2, '0'), style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(flex: 3, child: Text(cat.shop_name ?? "-", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryDark))),
          Expanded(flex: 3, child: Text(cat.category_name ?? "-", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryDark))),
          Expanded(flex: 2, child: Text(cat.department_name ?? "-", style: const TextStyle(fontSize: 13, color: Colors.black54))),
          // if(LoginUserDetails.isAdmin)
          // SizedBox(
          //   width: 80,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     children: [
          //       _actionBtn(Icons.edit_outlined, Colors.blue, () {
          //         setState(() {
          //           editingRowId = cat.row_id;
          //           catNameController.text = cat.category_name ?? "";
          //           selectedDeptId = cat.department_id;
          //
          //           if (LoginUserDetails.isAdmin) {
          //             shop_id = cat.shop_id;
          //           }
          //         });
          //       }),
          //       // const SizedBox(width: 8),
          //       // _actionBtn(Icons.delete_outline, Colors.redAccent, () {}),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color col, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
        child: Icon(icon, color: col, size: 18),
      ),
    );
  }

  static const _hStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xff64748B));
}