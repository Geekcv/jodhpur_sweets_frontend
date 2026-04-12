class StockHistoryModel {
  var transaction_id;
  var counter_id;
  var sweet_id;
  var transaction_type;
  var quantity;
  var reference_id;
  var notes;
  var cr_on;
  var sweet_name;
  var shop_name;
  var unit;
  var counter_name;
  var shop_id;

  StockHistoryModel({
    this.transaction_id,
    this.counter_id,
    this.sweet_id,
    this.transaction_type,
    this.quantity,
    this.reference_id,
    this.notes,
    this.cr_on,
    this.sweet_name,
    this.shop_name,
    this.unit,
    this.counter_name,
    this.shop_id,
  });

  // --- FROM JSON ---
  factory StockHistoryModel.fromJson(Map<String, dynamic> json) {
    return StockHistoryModel(
      transaction_id: json['transaction_id'],
      counter_id: json['counter_id'],
      sweet_id: json['sweet_id'],
      transaction_type: json['transaction_type'],
      quantity: json['quantity'],
      reference_id: json['reference_id'],
      notes: json['notes'],
      cr_on: json['cr_on'],
      sweet_name: json['sweet_name'],
      shop_name: json['shop_name'],
      unit: json['unit'],
      counter_name: json['counter_name'],
      shop_id: json['shop_id'],
    );
  }

  // --- TO JSON ---
  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transaction_id,
      'counter_id': counter_id,
      'sweet_id': sweet_id,
      'transaction_type': transaction_type,
      'quantity': quantity,
      'reference_id': reference_id,
      'notes': notes,
      'cr_on': cr_on,
      'sweet_name': sweet_name,
      'shop_name': shop_name,
      'unit': unit,
      'counter_name': counter_name,
      'shop_id': shop_id,
    };
  }
}