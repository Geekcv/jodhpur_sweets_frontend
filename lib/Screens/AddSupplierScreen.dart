import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/api_controller.dart';
import '../provider/provider.dart';
import '../widgets/TextInputField.dart';

class AddSupplierScreen extends ConsumerStatefulWidget {
  const AddSupplierScreen({super.key});

  @override
  ConsumerState<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends ConsumerState<AddSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool showErrors = false;
  bool show_password = false;

  final Map<String, TextEditingController> controllers = {
    'name': TextEditingController(),
    'phone': TextEditingController(),
    'email': TextEditingController(),
    'address': TextEditingController(),
    'password': TextEditingController(),
  };

  static const Color primaryDark = Color(0xff1A2B4C);
  static const Color successGreen = Color(0xff108548);
  static const Color borderCol = Color(0xffE2E8F0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(master_Provider).fetchSuppliers();
    });
  }

  Future<void> _submitSupplier() async {
    // Sabhi fields required hain validation
    bool isFormInvalid = controllers.values.any((ctrl) => ctrl.text.trim().isEmpty) ||
        controllers['phone']!.text.length < 10;

    if (isFormInvalid) {
      setState(() => showErrors = true);
      Timer(const Duration(seconds: 3), () => setState(() => showErrors = false));
      return;
    }

    setState(() => isLoading = true);

    final tobeSendData = {
      "supplier_name": controllers['name']!.text.trim(),
      "phone": controllers['phone']!.text.trim(),
      "email": controllers['email']!.text.trim(),
      "address": controllers['address']!.text.trim(),
      "password": controllers['password']!.text.trim(),
    };

    var response = await ApiController.addSupplier(params: tobeSendData);

    if (response != null && response['status'] == 0) {
      _clearForm();
      await ref.read(master_Provider).fetchSuppliers();
    }
    if (mounted) setState(() => isLoading = false);
  }

  void _clearForm() {
    controllers.forEach((key, controller) => controller.clear());
    setState(() => showErrors = false);
  }

  @override
  Widget build(BuildContext context) {
    final masterProv = ref.watch(master_Provider);
    final allSuppliers = masterProv.allSuppliers ?? [];

    return Scaffold(
      backgroundColor: const Color(0xffF9FBFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(allSuppliers.length),
            const SizedBox(height: 20),

            // --- 1. QUICK ADD FORM ---
            _buildQuickAddForm(),

            if (showErrors)
              const Padding(
                padding: EdgeInsets.only(top: 8, left: 5),
                child: Text("* All fields are mandatory with valid 10-digit phone",
                    style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
              ),

            const SizedBox(height: 25),

            // --- 2. SUPPLIERS LIST TABLE ---
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
                    itemCount: allSuppliers.length,
                    separatorBuilder: (c, i) => const Divider(height: 1, color: borderCol),
                    itemBuilder: (c, i) => _buildSupplierRow(allSuppliers[i], i + 1),
                  ),
                  if (allSuppliers.isEmpty && !masterProv.loading) _buildEmptyState(),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderCol),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1);

          return Wrap(
            spacing: 15,
            runSpacing: 18,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              _box(220, "SUPPLIER NAME", controllers['name']!),
              _box(140, "PHONE", controllers['phone']!, isPhone: true),
              _box(200, "EMAIL", controllers['email']!),
              _box(180, "PASSWORD", controllers['password']!, isPass: true),
              _box(350, "FULL ADDRESS", controllers['address']!),

              // SAVE BUTTON
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _submitSupplier,
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
                    label: const Text("SAVE SUPPLIER", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _box(double width, String label, TextEditingController ctrl, {bool isPass = false, bool isPhone = false}) {
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
        ),
      ],
    );
  }

  Widget _buildHeader(int count) {
    return Row(
      children: [
        const Text("Supplier Master", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryDark)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text("$count Registered", style: const TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: const Color(0xffF8FAFC),
      child: const Row(
        children: [
          SizedBox(width: 50, child: Text("S.N.", style: _hStyle)),
          Expanded(flex: 3, child: Text("SUPPLIER NAME", style: _hStyle)),
          Expanded(flex: 2, child: Text("CONTACT", style: _hStyle)),
          Expanded(flex: 4, child: Text("ADDRESS", style: _hStyle)),
          // SizedBox(width: 80, child: Text("ACTIONS", textAlign: TextAlign.right, style: _hStyle)),
        ],
      ),
    );
  }

  Widget _buildSupplierRow(dynamic s, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          SizedBox(width: 50, child: Text(index.toString().padLeft(2, '0'), style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(flex: 3, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.supplier_name ?? "-", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryDark)),
              Text(s.email ?? "", style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          )),
          Expanded(flex: 2, child: Text(s.phone ?? "-", style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500))),
          Expanded(flex: 4, child: Text(s.address ?? "-", style: const TextStyle(fontSize: 12, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis)),
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
      child: Center(child: Text("No suppliers found.", style: TextStyle(color: Colors.grey))),
    );
  }
}