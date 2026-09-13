class SupplierOrder {
  var orderId;
  var orderStatus;
  var orderDate;
  ShopDetails? shop;
  SupplierDetails? supplier;
  List<OrderItem>? items;

  SupplierOrder({
    this.orderId,
    this.orderStatus,
    this.orderDate,
    this.shop,
    this.supplier,
    this.items,
  });

  SupplierOrder.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    orderStatus = json['order_status'];
    orderDate = json['order_date'];
    supplier = json['supplier'] != null ? SupplierDetails.fromJson(json['supplier']) : null;
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
    if (supplier != null) {
      data['supplier'] = supplier!.toJson();
    }
    if (shop != null) {
      data['shop'] = shop!.toJson();
    }
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


class SupplierDetails {
  dynamic supplierId;
  dynamic supplierName;

  SupplierDetails({this.supplierId, this.supplierName});

  SupplierDetails.fromJson(Map<String, dynamic> json) {
    supplierId = json['supplier_id'];
    supplierName = json['supplier_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['supplier_id'] = supplierId;
    data['supplier_name'] = supplierName;
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
  var orderItemId;
  var requestId;
  var sweetId;
  var sweetName;
  var unit;
  var quantity;
  var counterId;
  var counterName;
  var location;
  var itemStatus;
  var suppliedQuantity;
  var rejectReason;

  OrderItem({
    this.orderItemId,
    this.requestId,
    this.sweetId,
    this.sweetName,
    this.unit,
    this.quantity,
    this.counterId,
    this.counterName,
    this.location,
    this.itemStatus,
    this.suppliedQuantity,
    this.rejectReason,
  });

  OrderItem.fromJson(Map<String, dynamic> json) {
    orderItemId = json['order_item_id'];
    requestId = json['request_id'];
    sweetId = json['sweet_id'];
    sweetName = json['sweet_name'];
    unit = json['unit'];
    quantity = json['quantity'];
    counterId = json['counter_id'];
    counterName = json['counter_name'];
    location = json['location'];
    itemStatus = json['item_status'];
    suppliedQuantity = json['supplied_quantity'];
    rejectReason = json['reject_reason'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_item_id'] = orderItemId;
    data['request_id'] = requestId;
    data['sweet_id'] = sweetId;
    data['sweet_name'] = sweetName;
    data['unit'] = unit;
    data['quantity'] = quantity;
    data['counter_id'] = counterId;
    data['counter_name'] = counterName;
    data['location'] = location;
    data['item_status'] = itemStatus;
    data['supplied_quantity'] = suppliedQuantity;
    data['reject_reason'] = rejectReason;
    return data;
  }
}