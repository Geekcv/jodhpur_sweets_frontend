import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:js_order_website/controllers/api_controller.dart';
import '../provider/provider.dart';
import '../widgets/TextInputField.dart';

class AddShopScreen extends ConsumerStatefulWidget {
  const AddShopScreen({super.key});

  @override
  ConsumerState<AddShopScreen> createState() => _AddShopScreenState();
}

class _AddShopScreenState extends ConsumerState<AddShopScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool showErrors = false;
  bool show_password = false;

  static const Color primaryDark = Color(0xff1A2B4C);
  static const Color borderCol = Color(0xffE2E8F0);
  static const Color tableHeaderBg = Color(0xffF8FAFC);

  final Map<String, TextEditingController> controllers = {
    'shop_name': TextEditingController(),
    'owner_name': TextEditingController(),
    'password': TextEditingController(),
    'phone': TextEditingController(),
    'email': TextEditingController(),
    'gst_number': TextEditingController(),
    'pincode': TextEditingController(),
    'city': TextEditingController(),
    'state': TextEditingController(),
    'address': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(master_Provider).fetchShop();
    });
  }

  Future<void> _submitShop() async {
    // Check if all fields are filled
    bool isFormInvalid = controllers.values.any((ctrl) => ctrl.text.trim().isEmpty) ||
        controllers['phone']!.text.length < 10;

    if (isFormInvalid) {
      setState(() => showErrors = true);
      Timer(const Duration(seconds: 3), () => setState(() => showErrors = false));
      return;
    }

    setState(() => isLoading = true);

    final shopData = {
      "shop_name": controllers['shop_name']!.text.trim(),
      "address": controllers['address']!.text.trim(),
      "city": controllers['city']!.text.trim(),
      "state": controllers['state']!.text.trim(),
      "pincode": controllers['pincode']!.text.trim(),
      "phone": controllers['phone']!.text.trim(),
      "email": controllers['email']!.text.trim(),
      "gst_number": controllers['gst_number']!.text.trim(),
      "owner_name": controllers['owner_name']!.text.trim(),
      "password": controllers['password']!.text.trim(),
      "logo_url": ""
    };

    var response = await ApiController.addShop(params: shopData);
    if (response != null && response['status'] == 0) {
      _showToast("${response['msg']}", Colors.green);
      _clearForm();
      await ref.read(master_Provider).fetchShop();
    }
      if (response != null && response['status'] == 1) {
        _showToast("${response['msg']}", Colors.red);
      }
    if (mounted) setState(() => isLoading = false);
  }

  void _clearForm() {
    controllers.forEach((key, ctrl) => ctrl.clear());
    setState(() => showErrors = false);
  }

  void _showToast(String msg, Color col) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: col));
  }

  @override
  Widget build(BuildContext context) {
    final masterProv = ref.watch(master_Provider);
    final allShops = masterProv.allShops ?? [];

    return Scaffold(
      backgroundColor: const Color(0xffF9FBFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(allShops.length),
            const SizedBox(height: 20),

            // --- 1. QUICK ADD FORM SECTION ---
            _buildQuickAddForm(),

            if (showErrors)
              const Padding(
                padding: EdgeInsets.only(top: 8, left: 5),
                child: Text("* All fields are required correctly", style: TextStyle(color: Colors.red, fontSize: 11)),
              ),

            const SizedBox(height: 25),

            // --- 2. REGISTERED SHOPS LIST ---
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
                    itemCount: allShops.length,
                    separatorBuilder: (c, i) => const Divider(height: 1, color: borderCol),
                    itemBuilder: (c, i) => _buildShopRow(allShops[i], i + 1),
                  ),
                  if (allShops.isEmpty && !masterProv.loading) _buildEmptyState(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Desktop: 4, Tablet: 2, Mobile: 1
          int crossAxisCount = constraints.maxWidth > 1000 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 10, // Thodi spacing badha di hai readability ke liye
                  mainAxisExtent: 70, // Label + Input + Error space ke liye 70 safe hai
                ),
                children: [
                  _box("SHOP NAME", controllers['shop_name']!),
                  _box("OWNER NAME", controllers['owner_name']!),
                  _box("PASSWORD", controllers['password']!, isPass: true),
                  _box("PHONE", controllers['phone']!, isPhone: true),
                  _box("EMAIL", controllers['email']! ,isEmail: true),
                  _box("GST NUMBER", controllers['gst_number']! , isGst: true),
                  _box("PINCODE", controllers['pincode']!, isDigits: true, length: 6),
                  _box("CITY", controllers['city']!),
                  _box("STATE", controllers['state']!),
                  _box("FULL ADDRESS", controllers['address']!),

                  // --- SAVE BUTTON AS A GRID ITEM ---
                  // Isko Align mein wrap kiya hai taaki height fixed rahe aur parent error na aaye
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: double.infinity,
                      height: 42, // Consistent height
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _submitShop,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff108548),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        icon: isLoading
                            ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                            : const Icon(Icons.check_circle_outline, size: 18),
                        label: Text(
                            isLoading ? "SAVING..." : "SAVE SHOP",
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)
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

// Updated _box: width nikal di hai kyunki Grid handle karega
  Widget _box(String label, TextEditingController ctrl, {bool isPass = false, bool isPhone = false, bool isDigits = false, bool isEmail = false,
    bool isGst = false, int? length}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(height: 5),
        CustomTextInput(
          hintText: label.toLowerCase(),
          obscureText: isPass ? !show_password : false,
          controller: ctrl,
          height: 38,
          maxLines: 1,
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
          maxLength: isGst ? 15 : length ?? (isPhone ? 10 : null),
          // maxLength: length ?? (isPhone ? 10 : null),
          keyboardType: (isPhone || isDigits) ? TextInputType.number : TextInputType.text,
          inputFormatters: [
            if (isPhone || isDigits) FilteringTextInputFormatter.digitsOnly,
            FilteringTextInputFormatter.deny(RegExp(r'^\s')),
            if (isEmail) FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9@._-]')),
            if (isGst) FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            if (isGst) TextInputFormatter.withFunction((old, newValue) =>
                TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection)),
          ],
        ),
      ],
    );
  }


  Widget _buildHeader(int count) {
    return Row(
      children: [
        const Text("Shop Master", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryDark)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text("$count Total", style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold)),
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
          Expanded(flex: 2, child: Text("OWNER", style: _hStyle)),
          Expanded(flex: 2, child: Text("CONTACT", style: _hStyle)),
          Expanded(flex: 2, child: Text("CITY", style: _hStyle)),
          Expanded(flex: 2, child: Text("GST NO.", style: _hStyle)),
          // SizedBox(width: 80, child: Text("ACTIONS", textAlign: TextAlign.right, style: _hStyle)),
        ],
      ),
    );
  }

  Widget _buildShopRow(dynamic shop, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(index.toString().padLeft(2, '0'), style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(flex: 3, child: Text(shop.shop_name ?? "-", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryDark))),
          Expanded(flex: 2, child: Text(shop.owner_name ?? "-", style: const TextStyle(fontSize: 13, color: Colors.black87))),
          Expanded(flex: 2, child: Text(shop.phone ?? "-", style: const TextStyle(fontSize: 13, color: Colors.black54))),
          Expanded(flex: 2, child: Text(shop.city ?? "-", style: const TextStyle(fontSize: 13, color: Colors.black87))),
          Expanded(flex: 2, child: Text(shop.gst_number ?? "-", style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold))),
          // SizedBox(
          //   width: 80,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     children: [
          //       _actionBtn(Icons.edit_outlined, Colors.blue, () {}),
          //       const SizedBox(width: 8),
          //       _actionBtn(Icons.delete_outline, Colors.redAccent, () {}),
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
      child: Center(child: Text("No shops found.", style: TextStyle(color: Colors.grey))),
    );
  }
}