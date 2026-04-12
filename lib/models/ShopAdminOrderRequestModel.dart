class ShopAdminOrderRequestModel {
  var rowId;
  var quantity;
  var status;
  var crOn;
  var sweetId;
  var sweetName;
  var unit;
  var counterId;
  var counterName;
  var location;

  ShopAdminOrderRequestModel({
    this.rowId,
    this.quantity,
    this.status,
    this.crOn,
    this.sweetId,
    this.sweetName,
    this.unit,
    this.counterId,
    this.counterName,
    this.location,
  });

  // JSON se Object banane ke liye
  factory ShopAdminOrderRequestModel.fromJson(Map<String, dynamic> json) {
    return ShopAdminOrderRequestModel(
      rowId: json['row_id'],
      quantity: json['quantity'],
      status: json['status'],
      crOn: json['cr_on'],
      sweetId: json['sweet_id'],
      sweetName: json['sweet_name'],
      unit: json['unit'],
      counterId: json['counter_id'],
      counterName: json['counter_name'],
      location: json['location'],
    );
  }

  // Object se JSON banane ke liye (API bhejte waqt kaam aayega)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['row_id'] = rowId;
    data['quantity'] = quantity;
    data['status'] = status;
    data['cr_on'] = crOn;
    data['sweet_id'] = sweetId;
    data['sweet_name'] = sweetName;
    data['unit'] = unit;
    data['counter_id'] = counterId;
    data['counter_name'] = counterName;
    data['location'] = location;
    return data;
  }
}