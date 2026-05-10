import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:js_order_website/models/FetchDepartmentModel.dart';
import '../constants/static.dart';
import '../controllers/api_controller.dart';
import '../models/FetchShopModel.dart';
import '../provider/provider.dart';
import '../widgets/CustomDropDownSearch.dart';
import 'LoginUserDetails.dart';

class AddDepartmentScreen extends ConsumerStatefulWidget {
  const AddDepartmentScreen({super.key});

  @override
  ConsumerState<AddDepartmentScreen> createState() => _AddDepartmentScreenState();
}

class _AddDepartmentScreenState extends ConsumerState<AddDepartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  static const Color primaryDark = Color(0xff1A2B4C);
  static const Color successGreen = Color(0xff108548);
  static const Color tableHeaderBg = Color(0xffF8FAFC);
  static const Color borderCol = Color(0xffE2E8F0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(master_Provider).fetchDepartment();
      // ref.read(master_Provider).fetchShop();
      if(LoginUserDetails.isAdmin) {
        ref.read(master_Provider).fetchShop();
      }
    });
  }

  String? shop_id;
  var editingRowId;

  // Helper function for Date Formatting (DD-MM-YYYY)
  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
    } catch (e) {
      return dateStr.split('T')[0];
    }
  }



  // Future<void> _submitDepartment() async {
  //   if (shop_id == null && LoginUserDetails.isAdmin) {
  //     showToast(context: context, msg: "Please Select a Shop!", color: Colors.orange);
  //     return;
  //   }
  //
  //   if (!_formKey.currentState!.validate()) return;
  //   setState(() => isLoading = true);
  //   final tobeSendData = {
  //     "shop_id": LoginUserDetails.isAdmin ? shop_id : LoginUserDetails.shopId,
  //     "department_name": nameController.text.trim(),
  //     "description": descController.text.trim(),
  //   };
  //
  //   var response = await ApiController.addDepartment(params: tobeSendData);
  //   if (response != null && response['status'] == 0) {
  //     showToast(context: context, msg: "Department Created Successfully!",color: Colors.green);
  //     shop_id = null;
  //     nameController.clear();
  //     descController.clear();
  //     await ref.read(master_Provider).fetchDepartment();
  //   } else {
  //     showToast(context: context, msg: response?['msg'] ?? "Error Occurred",color: Colors.redAccent);
  //   }
  //   if (mounted) setState(() => isLoading = false);
  // }



  Future<void> handleDepartmentSubmit() async {
    // 1. Validation Logic
    if (LoginUserDetails.isAdmin && shop_id == null) {
      showToast(context: context, msg: "Please Select a Shop!", color: Colors.orange);
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final tobeSendData = {
        if (editingRowId != null) "row_id": editingRowId, // Edit mode ke liye
        "shop_id": LoginUserDetails.isAdmin ? shop_id : LoginUserDetails.shopId,
        "department_name": nameController.text.trim(),
        "description": descController.text.trim(),
      };

      // 3. API Call (Single Controller Method)
      var response = await ApiController.addDepartment(params: tobeSendData);

      if (response != null && response['status'] == 0) {
        String successMsg = editingRowId == null
            ? "Department Created Successfully!"
            : "Department Updated Successfully!";

        showToast(context: context, msg: successMsg, color: Colors.green);

        // 4. Reset Form and Refresh Data
        _clearForm();
        await ref.read(master_Provider).fetchDepartment();
      } else {
        showToast(context: context, msg: response?['msg'] ?? "Operation Failed", color: Colors.redAccent);
      }
    } catch (e) {
      showToast(context: context, msg: "Something went wrong!", color: Colors.redAccent);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _clearForm() {
    nameController.clear();
    descController.clear();
    shop_id = null;
    editingRowId = null;
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    final masterProv = ref.watch(master_Provider);
    final allDepts = masterProv.allDepartments ?? [];
    final List<FetchShopModel> shops = List<FetchShopModel>.from(masterProv.allShops ?? []);

    return Scaffold(
      backgroundColor: const Color(0xffF9FBFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Form Row (Responsive)
            _buildResponsiveHeader(context,shops),
            const SizedBox(height: 25),

            // Main Table Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderCol),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)],
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
                    itemCount: allDepts.length,
                    separatorBuilder: (c, i) => const Divider(height: 1, color: borderCol),
                    itemBuilder: (c, i) => _buildDeptRow(allDepts[i], i + 1),
                  ),
                  if (allDepts.isEmpty && !masterProv.loading) _buildEmptyState(),
                ],
              ),
            ),
          ],
        ),
      ),
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
            onChanged: (val) => setState(() => shop_id = val?.row_id.toString()),
            hintText: "Select Shop",
          ),
        ),
      ],
    );
  }


  Widget _buildResponsiveHeader(BuildContext context, List<FetchShopModel> shops) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 950; // Increased breakpoint for better spacing

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Department Master",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryDark)),
          const SizedBox(height: 20),

          // Form and Button Section
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: isMobile
                    ? _buildQuickAddForm(isMobile,shops)
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [_buildQuickAddForm(isMobile,shops)],
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildQuickAddForm(bool isMobile, List<FetchShopModel> shops) {
    return Form(
      key: _formKey,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: isMobile ? WrapAlignment.start : WrapAlignment.end, // Push to right on Desktop
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          if(LoginUserDetails.isAdmin)
          _dropdownBoxFoShop("SELECT SHOP *", shops, isMobile ? double.infinity : 270),
          _compactField("NAME", nameController, "Department Name", 200),
          _compactField("DESCRIPTION", descController, "Short description...", 350),

          // Save Button
          Padding(
            padding: const EdgeInsets.only(bottom: 2), // Align with textfields
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : handleDepartmentSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: successGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 0,
              ),
              icon: isLoading
                  ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save, size: 16),
              label: const Text("SAVE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactField(String label, TextEditingController ctrl, String hint, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(height: 5),
        SizedBox(
          width: width,
          child: TextFormField(
            controller: ctrl,
            validator: (v) => v!.isEmpty ? "*" : null,
            // Precaution: Block leading space
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'^\s+')),
            ],
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 12,color: Colors.grey),
              isDense: true,
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: borderCol)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: borderCol)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.blue, width: 1.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: tableHeaderBg,
      child: Row(
        children: [
          SizedBox(width: 40, child: Text("S.N.", style: _hStyle)),
          Expanded(flex: 3, child: Text("SHOP NAME", style: _hStyle)),
          Expanded(flex: 3, child: Text("DEPARTMENT NAME", style: _hStyle)),
          Expanded(flex: 4, child: Text("DESCRIPTION", style: _hStyle)),
          Expanded(flex: 2, child: Text("CREATED DATE", style: _hStyle)),
          // if(LoginUserDetails.isAdmin)
          // SizedBox(width: 80, child: Text("ACTIONS", textAlign: TextAlign.right, style: _hStyle)),
        ],
      ),
    );
  }

  Widget _buildDeptRow(dynamic dept, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(index.toString().padLeft(2, '0'), style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(flex: 3, child: Text(dept.shop_name ?? "-", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryDark))),
          Expanded(flex: 3, child: Text(dept.department_name ?? "-", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryDark))),
          Expanded(flex: 4, child: Text(dept.description ?? "N/A", style: TextStyle(fontSize: 13, color: Colors.grey[700]), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(formatDate(dept.cr_on.toString()), style: const TextStyle(fontSize: 13, color: Colors.black87))),

          // if(LoginUserDetails.isAdmin)
          // SizedBox(
          //   width: 80,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     children: [
          //       _actionBtn(Icons.edit_outlined, Colors.blue, () {
          //         nameController.text = dept.department_name ?? "";
          //         descController.text = dept.description ?? "";
          //         if (LoginUserDetails.isAdmin) {
          //           shop_id = dept.shop_id;
          //         }
          //         setState(() {
          //           editingRowId = dept.row_id;
          //         });
          //       }),
          //       // const SizedBox(width: 8),
          //       // _actionBtn(Icons.delete_outline, Colors.redAccent, () {
          //       //   // TODO: Map Delete Logic
          //       // }),
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

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(40.0),
      child: Center(child: Text("No records found.", style: TextStyle(color: Colors.grey))),
    );
  }
}