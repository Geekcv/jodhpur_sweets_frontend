class FetchOrderRequestModel {
  var row_id;
  var quantity;
  var status;
  var cr_on;
  var counter_id;
  var counter_name;
  var sweet_id;
  var sweet_name;
  var unit;

  FetchOrderRequestModel({
    this.row_id,
    this.quantity,
    this.status,
    this.cr_on,
    this.counter_id,
    this.counter_name,
    this.sweet_id,
    this.sweet_name,
    this.unit,
  });

  // JSON se Model banane ke liye
  factory FetchOrderRequestModel.fromJson(Map<String, dynamic> json) {
    return FetchOrderRequestModel(
      row_id: json['row_id'],
      quantity: json['quantity'],
      status: json['status'],
      cr_on: json['cr_on'],
      counter_id: json['counter_id'],
      counter_name: json['counter_name'],
      sweet_id: json['sweet_id'],
      sweet_name: json['sweet_name'],
      unit: json['unit'],
    );
  }

  // Model se wapis JSON banane ke liye (Optional)
  Map<String, dynamic> toJson() {
    return {
      'row_id': row_id,
      'quantity': quantity,
      'status': status,
      'cr_on': cr_on,
      'counter_id': counter_id,
      'counter_name': counter_name,
      'sweet_id': sweet_id,
      'sweet_name': sweet_name,
      'unit': unit,
    };
  }
}