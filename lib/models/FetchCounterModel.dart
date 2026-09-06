class FetchCounterModel {
  var row_id;
  var counter_name;
  var location;
  var shop_id;
  var shop_name;
  var user_phone;
  var password;

  FetchCounterModel({this.row_id,this.counter_name,this.location,this.shop_id,this.shop_name,this.user_phone,this.password});

  factory FetchCounterModel.fromJson(Map<String, dynamic> json) {
    return FetchCounterModel(
      row_id: json['row_id'] ?? "",
      shop_name: json['shop_name'] ?? "Unknown Shop",
      counter_name: json['counter_name'],
      location: json['location'],
      shop_id: json['shop_id'],
      user_phone: json['user_phone'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'row_id': row_id,
      'shop_name': shop_name,
      'counter_name': counter_name,
      'location': location,
      'shop_id': shop_id,
      'user_phone': user_phone,
      'password': password,
    };
  }
}