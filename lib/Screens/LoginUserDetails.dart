class LoginUserDetails {
  static String? token;
  static String? userId;
  static String? role;
  static String? counterId;
  static String? shopId;
  static String? supplierId;

  static void storeUserData(Map<String, dynamic> response) {
    var data = response['data'];

    token = data['token'];
    userId = data['user_id']?.toString();
    role = data['role']?.toString();
    counterId = data['counter_id']?.toString();
    shopId = data['shop_id']?.toString();
    supplierId = data['supplier_id']?.toString();

    _printDetails("STORED FROM LOGIN");
  }

  static void loadDataFromStorage({
    required String t,
    required String r,
    String? uId,
    String? cId,
    String? sId,
    String? supId,
  }) {
    token = t;
    role = r;
    userId = uId;
    counterId = (cId == "" || cId == "null") ? null : cId;
    shopId = (sId == "" || sId == "null") ? null : sId;
    supplierId = (supId == "" || supId == "null") ? null : supId;

    _printDetails("LOADED FROM STORAGE");
  }

  static void _printDetails(String source) {
    // print("------- $source -------");
    // print("Token: $token");
    // print("User ID: $userId");
    // print("Role: $role");
    // print("Shop ID: $shopId");
    // print("Counter ID: $counterId");
    // print("Supplier ID: $supplierId");
    // print("-----------------------------------------");
  }

  static void clear() {
    token = userId = role = counterId = shopId = supplierId = null;
  }

  static bool get isAdmin => role == "ADMIN";
  static bool get isShopAdmin => role == "SHOP_ADMIN";
  static bool get isCounterUser => role == "COUNTER_USER";
  static bool get isSupplier => role == "SUPPLIER";
}