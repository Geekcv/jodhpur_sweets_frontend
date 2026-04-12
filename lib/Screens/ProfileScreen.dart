import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/static.dart';
import '../controllers/api_controller.dart';
import '../provider/provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool isEditing = false;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  void _fetchProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(master_Provider).fetchOwnProfile().then((data) {
        if (data != null && data.isNotEmpty) {
          _initializeControllers(data[0]);
        }
      });
    });
  }

  void _initializeControllers(dynamic user) {
    if (user == null) return;
    setState(() {
      _controllers['name'] = TextEditingController(text: user.name ?? "");
      _controllers['email'] = TextEditingController(text: user.email ?? "");
      _controllers['phone'] = TextEditingController(text: user.phone ?? "");
      _controllers['password'] = TextEditingController(text: user.password ?? "");

      if (user.role == "SHOP_ADMIN") {
        _controllers['shop_name'] = TextEditingController(text: user.shopName ?? "");
        _controllers['address'] = TextEditingController(text: user.address ?? "");
        _controllers['city'] = TextEditingController(text: user.city ?? "");
        _controllers['pincode'] = TextEditingController(text: user.pincode ?? "");
        _controllers['owner_name'] = TextEditingController(text: user.ownerName ?? "");
      } else if (user.role == "COUNTER_USER") {
        _controllers['counter_name'] = TextEditingController(text: user.counterName ?? "");
      } else if (user.role == "SUPPLIER") {
        _controllers['supplier_name'] = TextEditingController(text: user.name ?? "");
        _controllers['address'] = TextEditingController(text: user.address ?? "");
      }
    });
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  // --- Style Constants ---
  static const Color kPrimary = Color(0xff6366F1);
  static const Color kSlateBg = Color(0xffF8FAFC);
  static const Color kTextDark = Color(0xff1E293B);
  static const Color kTextMuted = Color(0xff64748B);
  static const Color kBorderColor = Color(0xffE2E8F0);

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(master_Provider);
    final user = provider.userProfileData.isNotEmpty ? provider.userProfileData[0] : null;
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 900;

    if (provider.loading) return Scaffold(body: buildShimmerEffect(context: context));
    if (user == null) return const Scaffold(body: Center(child: Text("Profile data not found")));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPremiumHeader(user, isDesktop),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? size.width * 0.15 : 20,
                vertical: 40,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader("Personal Account", "Basic credentials and login details"),
                    const SizedBox(height: 10),
                    _buildGrid([
                      _inputField("Full Name", _controllers['name'], Icons.person_outline, validator: (v) => v!.isEmpty ? "Name required" : null),
                      _inputField("Email Address", _controllers['email'], Icons.alternate_email, validator: (v) => !v!.contains("@") ? "Invalid email" : null),
                      _inputField("Mobile Number", _controllers['phone'], Icons.phone_android_outlined, isPhone: true, validator: (v) => v!.length != 10 ? "10 digits required" : null),
                      _inputField("Password", _controllers['password'], Icons.lock_open_rounded, isPass: true, validator: (v) => v!.length < 4 ? "Min 4 characters" : null),
                    ]),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 30), child: Divider(color: kBorderColor)),
                    _sectionHeader("${user.role?.replaceAll("_", " ")} Workspace", "Professional role-based information"),
                    const SizedBox(height: 10),
                    _buildGrid(_buildRoleFields(user)),
                    const SizedBox(height: 50),
                    if (isEditing) _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(dynamic user, bool isDesktop) {
    final size = MediaQuery.of(context).size;
    // Content alignment adjustments
    double profileLeftPosition = isDesktop ? 40 : 20;

    return Stack(
      alignment: Alignment.bottomLeft,
      clipBehavior: Clip.none,
      children: [
        // --- Background Cover: Deep Obsidian Mesh ---
        Container(
          height: 95, // Height aur bhi compact kar di
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff0F172A), // Deep Midnight Navy
                Color(0xff1E293B), // Slate Navy
                Color(0xff020617), // Pure Obsidian
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Stack(
            children: [
              // Subtly Glowing Aura in background
              Positioned(
                top: -40,
                right: 20,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xff6366F1).withOpacity(0.06),
                  ),
                ),
              ),
            ],
          ),
        ),

        // --- Edit Button: Fixed Position ---
        Positioned(
          top: 30,
          right: isDesktop ? 40 : 20,
          child: _buildEditToggleButton(),
        ),

        // --- Profile Info: Fixed Role-Cutting Issue ---
        Positioned(
          bottom: -35,
          left: profileLeftPosition,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar with High-Contrast Border
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xff818CF8), Color(0xff4F46E5)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: CircleAvatar(
                    radius: 40, // More compact size
                    backgroundColor: const Color(0xffF8FAFC),
                    child: Text(
                      user.name?[0].toUpperCase() ?? "?",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xff0F172A),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),

              // Text Details with Overflow Fix
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name: Pure White for Obsidian Background
                    Text(
                      user.name ?? "User",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 3))],
                      ),
                    ),
                    const SizedBox(height: 5),

                    // ROLE BADGE: Fixed logic using IntrinsicWidth & Flexible
                    IntrinsicWidth(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12), // Glass effect
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Shield Icon: Soft Indigo/Cyan touch
                            const Icon(
                              Icons.verified_user_rounded, // Thoda aur premium icon
                              size: 12,
                              color: Color(0xff818CF8), // Electric Indigo (High Contrast)
                            ),
                            const SizedBox(width: 6),

                            // Flexible: Ensures text doesn't push the icon out or cut abruptly
                            Flexible(
                              child: Text(
                                user.role?.replaceAll("_", " ") ?? "MEMBER",
                                overflow: TextOverflow.ellipsis, // Safe guard for very long roles
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800, // Thoda extra bold for premium look
                                  color: Colors.black87, // Pure Slate White (Readability fix)
                                  letterSpacing: 0.8, // Enterprise style spacing
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildEditToggleButton() {
    return InkWell(
      onTap: () => setState(() => isEditing = !isEditing),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(isEditing ? Icons.close : Icons.edit_note_rounded, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(isEditing ? "Discard" : "Edit Profile",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
        // Text(sub, style: const TextStyle(fontSize: 13, color: kTextMuted)),
      ],
    );
  }

  Widget _buildGrid(List<Widget> children) {
    return LayoutBuilder(builder: (context, constraints) {
      return Wrap(
        spacing: 20,
        children: children.map((c) => SizedBox(
            width: constraints.maxWidth > 700 ? (constraints.maxWidth - 20) / 2 : constraints.maxWidth,
            child: c)).toList(),
      );
    });
  }

  List<Widget> _buildRoleFields(dynamic user) {
    if (user.role == "SHOP_ADMIN") {
      return [
        _inputField("Shop Name", _controllers['shop_name'], Icons.store),
        _inputField("Owner Name", _controllers['owner_name'], Icons.badge_outlined),
        _inputField("Address", _controllers['address'], Icons.location_on_outlined),
        _inputField("City", _controllers['city'], Icons.location_city_outlined),
        _inputField("Pincode", _controllers['pincode'], Icons.pin_drop_outlined, isNumber: true),
      ];
    }
    else if (user.role == "COUNTER_USER") {
      return [_inputField("Counter Name", _controllers['counter_name'], Icons.storefront_rounded)];
    }
    else if (user.role == "SUPPLIER") {
      return [
        _inputField("Supplier Business Name", _controllers['supplier_name'], Icons.local_shipping_outlined),
        _inputField("Warehouse Address", _controllers['address'], Icons.business_outlined),
      ];
    }
    return [const Text("Administrative rights active.")];
  }

  Widget _inputField(String label, TextEditingController? controller, IconData icon,
      {bool isPass = false, bool isPhone = false, bool isNumber = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kTextDark)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            enabled: isEditing,
            obscureText: isPass ? _obscurePassword : false,
            validator: validator,
            keyboardType: (isPhone || isNumber) ? TextInputType.number : TextInputType.text,
            inputFormatters: isPhone ? [LengthLimitingTextInputFormatter(10), FilteringTextInputFormatter.digitsOnly] : null,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kTextDark),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 19, color: isEditing ? kPrimary : kTextMuted),
              suffixIcon: isPass && isEditing
                  ? IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword))
                  : null,
              filled: true,
              fillColor: isEditing ? Colors.white : kSlateBg.withOpacity(0.5),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorderColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorderColor)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
              disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 50,
          width: 180,
          child: ElevatedButton(
            onPressed: _handleUpdate,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  void _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(master_Provider).userProfileData[0];
    Map<String, dynamic> updateData = {
      "name": _controllers['name']?.text,
      "email": _controllers['email']?.text,
      "phone": _controllers['phone']?.text,
      "password": _controllers['password']?.text,
    };

    if (user.role == "SHOP_ADMIN") {
      updateData.addAll({
        "shop_name": _controllers['shop_name']?.text,
        "address": _controllers['address']?.text,
        "city": _controllers['city']?.text,
        "pincode": _controllers['pincode']?.text,
        "owner_name": _controllers['owner_name']?.text,
      });
    }

    if (user.role == "COUNTER_USER") {
      updateData.addAll({
        // "counter_name": _controllers['counter_name']?.text,
        "counter_name": user.counterName,
      });
    }

    if (user.role == "SUPPLIER") {
      updateData.addAll({
        "supplier_name": _controllers['supplier_name']?.text,
        "address": _controllers['address']?.text,
      });
    }

    var res = await ApiController.updateProfile(params: updateData);

    if (res != null) {
      if (res['status'] == 0) { // Logic fixed for 1
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated Successfully!"), backgroundColor: Colors.green));
        setState(() => isEditing = false);
        ref.read(master_Provider).fetchOwnProfile();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Error updating profile"), backgroundColor: Colors.red));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Server error occurred"), backgroundColor: Colors.orange));
    }
  }
}