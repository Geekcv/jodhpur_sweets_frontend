class FetchCounterModel {
  var row_id;
  var counter_name;
  var location;
  var shop_id;
  var shop_name;
  var mobile_number;

  FetchCounterModel({this.row_id,this.counter_name,this.location,this.shop_id,this.shop_name,this.mobile_number});

  factory FetchCounterModel.fromJson(Map<String, dynamic> json) {
    return FetchCounterModel(
      row_id: json['row_id'] ?? "",
      shop_name: json['shop_name'] ?? "Unknown Shop",
      counter_name: json['counter_name'],
      location: json['location'],
      shop_id: json['shop_id'],
      mobile_number: json['mobile_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'row_id': row_id,
      'shop_name': shop_name,
      'counter_name': counter_name,
      'location': location,
      'shop_id': shop_id,
      'mobile_number': mobile_number,
    };
  }
}