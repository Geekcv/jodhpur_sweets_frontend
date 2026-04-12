class UserProfileModel {
  String? role;
  String? rowId;
  String? name;
  String? email;
  String? phone;
  String? password;

  // Shop Admin Specific
  String? shopId;
  String? shopName;
  String? address;
  String? city;
  String? state;
  String? pincode;
  String? ownerName;
  String? logoUrl;

  // Counter User Specific
  String? counterId;
  String? counterName;
  String? location;

  // Supplier Specific
  String? supplierId;

  // Admin Specific
  String? crOn;

  UserProfileModel({
    this.role,
    this.rowId,
    this.name,
    this.email,
    this.phone,
    this.password,
    this.shopId,
    this.shopName,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.ownerName,
    this.logoUrl,
    this.counterId,
    this.counterName,
    this.location,
    this.supplierId,
    this.crOn,
  });

  // From JSON
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      role: json['role']?.toString(),
      rowId: json['row_id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      password: json['password']?.toString(),

      // Shop Admin Fields
      shopId: json['shop_id']?.toString(),
      shopName: json['shop_name']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
      ownerName: json['owner_name']?.toString(),
      logoUrl: json['logo_url']?.toString(),

      // Counter User Fields
      counterId: json['counter_id']?.toString(),
      counterName: json['counter_name']?.toString(),
      location: json['location']?.toString(),

      // Supplier Fields
      supplierId: json['supplier_id']?.toString(),

      // Admin Fields
      crOn: json['cr_on']?.toString(),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['role'] = role;
    data['row_id'] = rowId;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['password'] = password;

    // Shop Admin Fields
    if (shopId != null) data['shop_id'] = shopId;
    if (shopName != null) data['shop_name'] = shopName;
    if (address != null) data['address'] = address;
    if (city != null) data['city'] = city;
    if (state != null) data['state'] = state;
    if (pincode != null) data['pincode'] = pincode;
    if (ownerName != null) data['owner_name'] = ownerName;
    if (logoUrl != null) data['logo_url'] = logoUrl;

    // Counter User Fields
    if (counterId != null) data['counter_id'] = counterId;
    if (counterName != null) data['counter_name'] = counterName;
    if (location != null) data['location'] = location;

    // Supplier Fields
    if (supplierId != null) data['supplier_id'] = supplierId;

    // Admin Fields
    if (crOn != null) data['cr_on'] = crOn;

    return data;
  }
}