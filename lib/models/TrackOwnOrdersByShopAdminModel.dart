class TrackOwnOrdersByShopAdminModel {
  var orderId;
  var orderStatus;
  var orderDate;
  var shopName;
  var supplierId;
  var supplierName;
  List<OrderItem>? items;

  TrackOwnOrdersByShopAdminModel({
    this.orderId,
    this.orderStatus,
    this.orderDate,
    this.shopName,
    this.supplierId,
    this.supplierName,
    this.items,
  });

  // JSON se Model mein convert karne ke liye
  TrackOwnOrdersByShopAdminModel.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    orderStatus = json['order_status'];
    orderDate = json['order_date'];
    shopName = json['shop_name'];
    supplierId = json['supplier_id'];
    supplierName = json['supplier_name'];
    if (json['items'] != null) {
      items = <OrderItem>[];
      json['items'].forEach((v) {
        items!.add(OrderItem.fromJson(v));
      });
    }
  }

  // Model se JSON mein convert karne ke liye (API Post ke liye)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_id'] = orderId;
    data['order_status'] = orderStatus;
    data['order_date'] = orderDate;
    data['shop_name'] = shopName;
    data['supplier_id'] = supplierId;
    data['supplier_name'] = supplierName;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderItem {
  var sweetId;
  var sweetName;
  var unit;
  var quantity;

  OrderItem({
    this.sweetId,
    this.sweetName,
    this.unit,
    this.quantity,
  });

  OrderItem.fromJson(Map<String, dynamic> json) {
    sweetId = json['sweet_id'];
    sweetName = json['sweet_name'];
    unit = json['unit'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sweet_id'] = sweetId;
    data['sweet_name'] = sweetName;
    data['unit'] = unit;
    data['quantity'] = quantity;
    return data;
  }
}