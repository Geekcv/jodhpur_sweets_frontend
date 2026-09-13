class ChalanDataModel {
  var chalanId;
  var dispatchDate;
  var transportDetails;
  var orderId;
  var orderStatus;
  var orderDate;
  var shopId;
  var shopName;
  var city;
  var state;
  var supplierId;
  var supplierName;
  var isVerified;
  var verificationCode;
  List<ChalanItem>? items;

  ChalanDataModel({
    this.chalanId,
    this.dispatchDate,
    this.transportDetails,
    this.orderId,
    this.orderStatus,
    this.orderDate,
    this.shopId,
    this.shopName,
    this.city,
    this.state,
    this.supplierId,
    this.supplierName,
    this.isVerified,
    this.verificationCode,
    this.items,
  });

  ChalanDataModel.fromJson(Map<String, dynamic> json) {
    chalanId = json['chalan_id'];
    dispatchDate = json['dispatch_date'];
    transportDetails = json['transport_details'];
    orderId = json['order_id'];
    orderStatus = json['order_status'];
    orderDate = json['order_date'];
    isVerified = json['is_verified'] ?? false;
    verificationCode = json['verification_code'];

    // Nested 'shop' Object Mapping
    if (json['shop'] != null) {
      shopId = json['shop']['shop_id'];
      shopName = json['shop']['shop_name'];
      city = json['shop']['city'];
      state = json['shop']['state'];
    }

    // Nested 'supplier' Object Mapping
    if (json['supplier'] != null) {
      supplierId = json['supplier']['supplier_id'];
      supplierName = json['supplier']['supplier_name'];
    }

    // Items Mapping
    if (json['items'] != null) {
      items = <ChalanItem>[];
      json['items'].forEach((v) {
        items!.add(ChalanItem.fromJson(v));
      });
    }
  }
}

class ChalanItem {
  var orderItemId;
  var requestId;
  var sweetId;
  var sweetName;
  var unit;
  var requestedQuantity;
  var suppliedQuantity;
  var itemStatus;
  var rejectReason;
  var counterId;
  var counterName;
  var counterLocation;

  ChalanItem({
    this.orderItemId,
    this.requestId,
    this.sweetId,
    this.sweetName,
    this.unit,
    this.requestedQuantity,
    this.suppliedQuantity,
    this.itemStatus,
    this.rejectReason,
    this.counterId,
    this.counterName,
    this.counterLocation,
  });

  ChalanItem.fromJson(Map<String, dynamic> json) {
    orderItemId = json['order_item_id'];
    requestId = json['request_id'];
    sweetId = json['sweet_id'];
    sweetName = json['sweet_name'];
    unit = json['unit'];
    requestedQuantity = json['requested_quantity'];
    suppliedQuantity = json['supplied_quantity'];
    itemStatus = json['item_status'];
    rejectReason = json['reject_reason'];

    // Nested 'counter' Object Mapping
    if (json['counter'] != null) {
      counterId = json['counter']['counter_id'];
      counterName = json['counter']['counter_name'];
      counterLocation = json['counter']['location'];
    }
  }
}