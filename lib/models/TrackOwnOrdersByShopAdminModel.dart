class TrackOwnOrdersByShopAdminModel {
  var orderId;
  var orderStatus;
  var orderDate;
  var shopName;
  var supplierId;
  var supplierName;
  var orderType;
  var parentOrderId;
  var resolutionStatus;
  var shopId;
  List<OrderItem>? items;

  TrackOwnOrdersByShopAdminModel({
    this.orderId,
    this.orderStatus,
    this.orderDate,
    this.shopName,
    this.supplierId,
    this.supplierName,
    this.items,
    this.orderType,
    this.parentOrderId,
    this.resolutionStatus,
    this.shopId,
  });

  // JSON se Model mein convert karne ke liye
  TrackOwnOrdersByShopAdminModel.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    orderStatus = json['order_status'];
    orderDate = json['order_date'];
    shopName = json['shop_name'];
    supplierId = json['supplier_id'];
    supplierName = json['supplier_name'];
    orderType = json['order_type'];
    parentOrderId = json['parent_order_id'];
    resolutionStatus = json['resolution_status'];
    shopId = json['shop_id'];
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
    data['order_type'] = orderType;
    data['parent_order_id'] = parentOrderId;
    data['resolution_status'] = resolutionStatus;
    data['shop_id'] = shopId;
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
  var orderItemId;
  var requestId;
  var suppliedQuantity;
  var reorderSuppliedQuantity;
  var cancelledQuantity;
  var remainingQuantity;
  var parentOrderItemId;
  var remainingAction;
  var remainingActionOn;
  var counterId;
  var counterName;
  var location;
  var itemStatus;
  var rejectReason;

  OrderItem({
    this.sweetId,
    this.sweetName,
    this.unit,
    this.quantity,
    this.orderItemId,
    this.requestId,
    this.suppliedQuantity,
    this.reorderSuppliedQuantity,
    this.cancelledQuantity,
    this.remainingQuantity,
    this.parentOrderItemId,
    this.remainingAction,
    this.remainingActionOn,
    this.counterId,
    this.counterName,
    this.location,
    this.itemStatus,
    this.rejectReason,
  });

  OrderItem.fromJson(Map<String, dynamic> json) {
    sweetId = json['sweet_id'];
    sweetName = json['sweet_name'];
    unit = json['unit'];
    quantity = json['quantity'];
    orderItemId = json['order_item_id'];
    requestId = json['request_id'];
    suppliedQuantity = json['supplied_quantity'];
    reorderSuppliedQuantity = json['reorder_supplied_quantity'];
    cancelledQuantity = json['cancelled_quantity'];
    remainingQuantity = json['remaining_quantity'];
    parentOrderItemId = json['parent_order_item_id'];
    remainingAction = json['remaining_action'];
    remainingActionOn = json['remaining_action_on'];
    counterId = json['counter_id'];
    counterName = json['counter_name'];
    location = json['location'];
    itemStatus = json['item_status'];
    rejectReason = json['reject_reason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sweet_id'] = sweetId;
    data['sweet_name'] = sweetName;
    data['unit'] = unit;
    data['quantity'] = quantity;

    data['order_item_id'] = orderItemId;
    data['request_id'] = requestId;
    data['supplied_quantity'] = suppliedQuantity;
    data['reorder_supplied_quantity'] = reorderSuppliedQuantity;
    data['cancelled_quantity'] = cancelledQuantity;
    data['remaining_quantity'] = remainingQuantity;
    data['parent_order_item_id'] = parentOrderItemId;
    data['remaining_action'] = remainingAction;
    data['remaining_action_on'] = remainingActionOn;
    data['counter_id'] = counterId;
    data['counter_name'] = counterName;
    data['location'] = location;
    data['item_status'] = itemStatus;
    data['reject_reason'] = rejectReason;
    return data;
  }
}