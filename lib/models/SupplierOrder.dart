class SupplierOrder {
  var orderId;
  var orderStatus;
  var orderDate;
  ShopDetails? shop;
  List<OrderItem>? items;

  SupplierOrder({
    this.orderId,
    this.orderStatus,
    this.orderDate,
    this.shop,
    this.items,
  });

  SupplierOrder.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    orderStatus = json['order_status'];
    orderDate = json['order_date'];
    shop = json['shop'] != null ? ShopDetails.fromJson(json['shop']) : null;
    if (json['items'] != null) {
      items = <OrderItem>[];
      json['items'].forEach((v) {
        items!.add(OrderItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_id'] = orderId;
    data['order_status'] = orderStatus;
    data['order_date'] = orderDate;
    if (shop != null) {
      data['shop'] = shop!.toJson();
    }
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ShopDetails {
  var shopId;
  var shopName;
  var city;
  var state;

  ShopDetails({this.shopId, this.shopName, this.city, this.state});

  ShopDetails.fromJson(Map<String, dynamic> json) {
    shopId = json['shop_id'];
    shopName = json['shop_name'];
    city = json['city'];
    state = json['state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['shop_id'] = shopId;
    data['shop_name'] = shopName;
    data['city'] = city;
    data['state'] = state;
    return data;
  }
}

class OrderItem {
  var sweetId;
  var sweetName;
  var unit;
  var quantity;

  OrderItem({this.sweetId, this.sweetName, this.unit, this.quantity});

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