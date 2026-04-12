class ChalanDataModel {
  var chalanId;
  var dispatchDate;
  var transportDetails;
  var orderId;
  var orderStatus;
  var orderDate;
  var shopName;
  var city;
  var state;
  var supplierId;
  var supplierName;
  var is_verified;
  var verification_code;
  List<ChalanItem>? items;

  ChalanDataModel({
    this.chalanId,
    this.dispatchDate,
    this.transportDetails,
    this.orderId,
    this.orderStatus,
    this.orderDate,
    this.shopName,
    this.city,
    this.state,
    this.supplierId,
    this.supplierName,
    this.is_verified,
    this.verification_code,
    this.items,
  });

  ChalanDataModel.fromJson(Map<String, dynamic> json) {
    chalanId = json['chalan_id'];
    dispatchDate = json['dispatch_date'];
    transportDetails = json['transport_details'];
    orderId = json['order_id'];
    orderStatus = json['order_status'];
    orderDate = json['order_date'];
    shopName = json['shop_name'];
    city = json['city'];
    state = json['state'];
    supplierId = json['supplier_id'];
    supplierName = json['supplier_name'];
    is_verified = json['is_verified'] ?? false;
    verification_code = json['verification_code'] ?? false;
    if (json['items'] != null) {
      items = <ChalanItem>[];
      json['items'].forEach((v) {
        items!.add(ChalanItem.fromJson(v));
      });
    }
  }
}

class ChalanItem {
  var sweetId;
  var sweetName;
  var unit;
  var quantity;

  ChalanItem({this.sweetId, this.sweetName, this.unit, this.quantity});

  ChalanItem.fromJson(Map<String, dynamic> json) {
    sweetId = json['sweet_id'];
    sweetName = json['sweet_name'];
    unit = json['unit'];
    quantity = json['quantity'];
  }
}