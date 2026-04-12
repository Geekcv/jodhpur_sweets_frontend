class FetchSupplierModel{
  var row_id;
  var supplier_name;
  var phone;
  var email;
  var address;

  FetchSupplierModel({this.row_id,this.supplier_name,this.email,this.phone,this.address});

  factory FetchSupplierModel.fromJson(Map<String, dynamic> json) {
    return FetchSupplierModel(
      row_id: json['row_id'] ?? "",
      supplier_name: json['supplier_name'] ?? " ",
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'row_id': row_id,
      'supplier_name': supplier_name,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }
}