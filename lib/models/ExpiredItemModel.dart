class ExpiredItemModel {
  // Saare fields 'var' ke saath as per requirement
  var id;
  var row_id;
  var counter_id;
  var sweet_id;
  var inventory_id;
  var quantity;
  var expiry_date;
  var loss_amount;
  var reason;
  var cr_on;
  var up_on;
  var sweet_name;
  var counter_name;

  ExpiredItemModel({
    this.id,
    this.row_id,
    this.counter_id,
    this.sweet_id,
    this.inventory_id,
    this.quantity,
    this.expiry_date,
    this.loss_amount,
    this.reason,
    this.cr_on,
    this.up_on,
    this.sweet_name,
    this.counter_name,
  });

  // JSON se Model banane ke liye (API Response handle karne ke liye)
  factory ExpiredItemModel.fromJson(Map<String, dynamic> json) {
    return ExpiredItemModel(
      id: json['id'],
      row_id: json['row_id'],
      counter_id: json['counter_id'],
      sweet_id: json['sweet_id'],
      inventory_id: json['inventory_id'],
      quantity: json['quantity'],
      expiry_date: json['expiry_date'],
      loss_amount: json['loss_amount'],
      reason: json['reason'],
      cr_on: json['cr_on'],
      up_on: json['up_on'],
      sweet_name: json['sweet_name'],
      counter_name: json['counter_name'],
    );
  }

  // Model se JSON banane ke liye (Data bhejne ke liye)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'row_id': row_id,
      'counter_id': counter_id,
      'sweet_id': sweet_id,
      'inventory_id': inventory_id,
      'quantity': quantity,
      'expiry_date': expiry_date,
      'loss_amount': loss_amount,
      'reason': reason,
      'cr_on': cr_on,
      'up_on': up_on,
      'sweet_name': sweet_name,
      'counter_name': counter_name,
    };
  }
}