import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:js_order_website/Screens/LoginUserDetails.dart';
import '../constants/static.dart';
import '../models/FetchShopModel.dart';
import '../provider/provider.dart';
import '../controllers/api_controller.dart';
import '../widgets/CustomDropDownSearch.dart';
import '../widgets/TextInputField.dart';

class AddCounterScreen extends ConsumerStatefulWidget {
  const AddCounterScreen({super.key});

  @override
  ConsumerState<AddCounterScreen> createState() => _AddCounterScreenState();
}

class _AddCounterScreenState extends ConsumerState<AddCounterScreen> {
  bool isLoading = false;
  String? selectedShopId;
  bool showErrors = false;
  bool show_password = false;

  final Map<String, TextEditingController> controllers = {
    'counter_name': TextEditingController(),
    'location': TextEditingController(),
    'staff_name': TextEditingController(),
    'email': TextEditingController(),
    'phone': TextEditingController(),
    'password': TextEditingController(),
  };

  static const Color primaryDark = Color(0xff1A2B4C);
  static const Color successGreen = Color(0xff108548);
  static const Color borderCol = Color(0xffE2E8F0);
  static const Color tableHeaderBg = Color(0xffF8FAFC);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(LoginUserDetails.isAdmin) {
        ref.read(master_Provider).fetchShop();
      }
      // ref.read(master_Provider).fetchShop();
      ref.read(master_Provider).fetchCounter();
    });
  }

  Future<void> _submitCounter() async {


    final String? effectiveShopId = LoginUserDetails.isAdmin ? selectedShopId : LoginUserDetails.shopId;

    // print("DEBUG: Role is Admin? ${LoginUserDetails.isAdmin}");
    // print("DEBUG: Effective Shop ID to be used: $effectiveShopId");

    if (controllers['phone']!.text.trim().length != 10) {
      showToast(context: context,msg: "Phone number must be exactly 10 digits!",color: Colors.redAccent);
      return;
    }

    bool isFormInvalid = effectiveShopId == null ||
        controllers['counter_name']!.text.trim().isEmpty ||
        controllers['location']!.text.trim().isEmpty ||
        controllers['staff_name']!.text.trim().isEmpty ||
        controllers['email']!.text.trim().isEmpty ||
        controllers['phone']!.text.trim().length < 10 ||
        controllers['password']!.text.trim().isEmpty;

    if (isFormInvalid) {
      setState(() => showErrors = true);
      Timer(const Duration(seconds: 3), () => setState(() => showErrors = false));
      return;
    }

    setState(() => isLoading = true);

    final Map<String, dynamic> counterData = {
      "shop_id": LoginUserDetails.isAdmin ? selectedShopId : LoginUserDetails.shopId,
      "counter_name": controllers['counter_name']!.text.trim(),
      "location": controllers['location']!.text.trim(),
      "name": controllers['staff_name']!.text.trim(),
      "email": controllers['email']!.text.trim(),
      "phone": controllers['phone']!.text.trim(),
      "password": controllers['password']!.text.trim(),
    };

    var response = await ApiController.addCounter(params: counterData);

    if (response != null && response['status'] == 0) {
      showToast(context: context, msg: "Counter Added Successfully!",color: Colors.green);
      _clearForm();
      await ref.read(master_Provider).fetchCounter();
    } else {
      showToast(context: context, msg: response?['msg'] ?? "Error Occurred",color: Colors.redAccent);
    }
    if (mounted) setState(() => isLoading = false);
  }

  void _clearForm() {
    controllers.forEach((key, ctrl) => ctrl.clear());
    setState(() => selectedShopId = null);
  }

  @override
  Widget build(BuildContext context) {
    final masterProv = ref.watch(master_Provider);
    final allCounters = masterProv.allCounters ?? [];

    return Scaffold(
      backgroundColor: const Color(0xffF9FBFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(allCounters.length),
            const SizedBox(height: 20),

            // 1. QUICK ADD FORM
            _buildQuickAddForm(masterProv.allShops),

            if (showErrors)
              const Padding(
                padding: EdgeInsets.only(top: 8, left: 5),
                child: Text("* Please fill all required fields correctly", style: TextStyle(color: Colors.red, fontSize: 11)),
              ),

            const SizedBox(height: 25),

            // 2. COUNTERS LIST (Scrollable Card)
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
                    itemCount: allCounters.length,
                    separatorBuilder: (c, i) => const Divider(height: 1, color: borderCol),
                    itemBuilder: (c, i) => _buildCounterRow(allCounters[i], i + 1),
                  ),
                  if (allCounters.isEmpty && !masterProv.loading) _buildEmptyState(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Row(
      children: [
        const Text("Counter Master",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryDark)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text("$count Total", style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }


  Widget _buildQuickAddForm(List<FetchShopModel> shops) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderCol),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Desktop: 4 fields, Tablet: 2, Mobile: 1
          int crossAxisCount = constraints.maxWidth > 1100 ? 4 : (constraints.maxWidth > 700 ? 2 : 1);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 15,
                  mainAxisExtent: 60, // Label + Input ki height fix kar di
                ),
                children: [
                  if(LoginUserDetails.role == 'ADMIN')
                  _dropdownBox("SELECT SHOP", shops),
                  _box("COUNTER NAME", controllers['counter_name']!),
                  _box("LOCATION", controllers['location']!),
                  _box("STAFF NAME", controllers['staff_name']!),
                  _box("EMAIL", controllers['email']!),
                  _box("PHONE", controllers['phone']!, isPhone: true),
                  _box("PASSWORD", controllers['password']!, isPass: true),

                  // Save Button ko Grid ke last cell mein set kiya
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: SizedBox(
                        height: 38,
                        width: double.infinity, // Cell ki puri width lega
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _submitCounter,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: successGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            elevation: 0,
                          ),
                          icon: isLoading
                              ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.save, size: 16),
                          label: const Text("SAVE COUNTER", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _box(String label, TextEditingController ctrl, {bool isPass = false, bool isPhone = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(height: 5),
        CustomTextInput(
          hintText: label.toLowerCase(),
          controller: ctrl,
          height: 38,
          obscureText: isPass ? !show_password : false,
          maxLines: 1,
          maxLength: isPhone ? 10 : null,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          inputFormatters: [
            if (isPhone) FilteringTextInputFormatter.digitsOnly,
            FilteringTextInputFormatter.deny(RegExp(r'^\s')),
          ],
          suffixicon: isPass ? IconButton(
            onPressed: () => setState(() => show_password = !show_password),
            icon: Icon(
              show_password ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 18,
              color: Colors.grey,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ) : null,
        ),
      ],
    );
  }


  Widget _dropdownBox(String label, List<FetchShopModel> shops) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(height: 5),
        SizedBox(
          // width: 200,
          height: 38,
          child: CustomDropdownSearch<FetchShopModel>(
            items: shops,
            itemLabelBuilder: (shop) => shop.shop_name,
            compareFn: (a, b) => a.row_id == b.row_id,
            selectedItem: selectedShopId != null ? shops.firstWhere((s) => s.row_id == selectedShopId) : null,
            onChanged: (val) => setState(() => selectedShopId = val?.row_id),
            hintText: "Select Shop",
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: tableHeaderBg,
      child: const Row(
        children: [
          SizedBox(width: 40, child: Text("S.N.", style: _hStyle)),
          Expanded(flex: 3, child: Text("SHOP NAME", style: _hStyle)),
          Expanded(flex: 3, child: Text("COUNTER NAME", style: _hStyle)),
          Expanded(flex: 3, child: Text("COUNTER NUMBER", style: _hStyle)),
          Expanded(flex: 2, child: Text("LOCATION", style: _hStyle)),
          // SizedBox(width: 80, child: Text("ACTIONS", textAlign: TextAlign.right, style: _hStyle)),
        ],
      ),
    );
  }

  Widget _buildCounterRow(dynamic counter, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(index.toString().padLeft(2, '0'), style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(flex: 3, child: Text(counter.shop_name ?? "-", style: const TextStyle(fontSize: 13, color: Colors.black87))),
          Expanded(flex: 3, child: Text(counter.counter_name ?? "-", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryDark))),
          Expanded(flex: 3, child: Text(counter.mobile_number ?? "-", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54))),
          Expanded(flex: 2, child: Text(counter.location ?? "N/A", style: const TextStyle(fontSize: 13, color: Colors.black54))),

          // SizedBox(
          //   width: 80,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     children: [
          //       _actionBtn(Icons.edit_outlined, Colors.blue, () {
          //         // TODO: Edit Logic
          //       }),
          //       const SizedBox(width: 8),
          //       _actionBtn(Icons.delete_outline, Colors.redAccent, () {
          //         // TODO: Delete Logic
          //       }),
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