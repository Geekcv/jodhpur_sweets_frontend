class FetchShopModel {
  var row_id;
  var shop_name;
  var address;
  var city;
  var state;
  var pincode;
  var phone;
  var email;
  var gst_number;
  var owner_name;
  var logo_url;
  var is_active;
  var cr_on;
  var up_on;

  FetchShopModel({this.row_id,this.shop_name,this.address, this.city, this.state,
    this.pincode, this.phone, this.email, this.gst_number, this.owner_name, this.logo_url,
    this.is_active, this.cr_on,this.up_on});

  factory FetchShopModel.fromJson(Map<String, dynamic> json) {
    return FetchShopModel(
      row_id: json['row_id'] ?? "",
      shop_name: json['shop_name'] ?? "Unknown Shop",
      address: json['address'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode']?.toString(), // Pincode can be int or string
      phone: json['phone']?.toString(),
      email: json['email'],
      gst_number: json['gst_number'],
      owner_name: json['owner_name'],
      logo_url: json['logo_url'],
      is_active: json['is_active'] ?? false,
      cr_on: json['cr_on'] != null ? DateTime.parse(json['cr_on']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'row_id': row_id,
      'shop_name': shop_name,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'phone': phone,
      'email': email,
      'gst_number': gst_number,
      'owner_name': owner_name,
      'logo_url': logo_url,
      'is_active': is_active,
      'cr_on': cr_on?.toIso8601String(),
    };
  }
}