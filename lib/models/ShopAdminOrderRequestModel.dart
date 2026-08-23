// Inner Item Model (Aapka original name exact same rakha hai)
class ShopAdminOrderRequestModel {
  var rowId;
  var requestedQuantity;
  var suppliedQuantity;
  var pendingQuantity;
  var status;
  var requestGroup;
  var crOn;
  var sweetId;
  var sweetName;
  var unit;
  var counterId;
  var counterName;
  var location;
  var shopId;

  ShopAdminOrderRequestModel({
    this.rowId,
    this.requestedQuantity,
    this.suppliedQuantity,
    this.pendingQuantity,
    this.status,
    this.requestGroup,
    this.crOn,
    this.sweetId,
    this.sweetName,
    this.unit,
    this.counterId,
    this.counterName,
    this.location,
    this.shopId,
  });

  factory ShopAdminOrderRequestModel.fromJson(Map<String, dynamic> json) {
    return ShopAdminOrderRequestModel(
      rowId: json['row_id'],
      requestedQuantity: json['requested_quantity'],
      suppliedQuantity: json['supplied_quantity'],
      pendingQuantity: json['pending_quantity'],
      status: json['status'],
      requestGroup: json['request_group'],
      crOn: json['cr_on'],
      sweetId: json['sweet_id'],
      sweetName: json['sweet_name'],
      unit: json['unit'],
      counterId: json['counter_id'],
      counterName: json['counter_name'],
      location: json['location'],
      shopId: json['shop_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['row_id'] = rowId;
    data['requested_quantity'] = requestedQuantity;
    data['supplied_quantity'] = suppliedQuantity;
    data['pending_quantity'] = pendingQuantity;
    data['status'] = status;
    data['request_group'] = requestGroup;
    data['cr_on'] = crOn;
    data['sweet_id'] = sweetId;
    data['sweet_name'] = sweetName;
    data['unit'] = unit;
    data['counter_id'] = counterId;
    data['counter_name'] = counterName;
    data['location'] = location;
    data['shop_id'] = shopId;
    return data;
  }
}

// Outer Group Model (JSON ke top-level objects ke liye)
class ShopAdminOrderGroupModel {
  var requestGroup;
  var crOn;
  var totalRequests;
  var totalRequestedQuantity;
  var totalSuppliedQuantity;
  var totalPendingQuantity;
  List<ShopAdminOrderRequestModel>? requests;

  ShopAdminOrderGroupModel({
    this.requestGroup,
    this.crOn,
    this.totalRequests,
    this.totalRequestedQuantity,
    this.totalSuppliedQuantity,
    this.totalPendingQuantity,
    this.requests,
  });

  factory ShopAdminOrderGroupModel.fromJson(Map<String, dynamic> json) {
    return ShopAdminOrderGroupModel(
      requestGroup: json['request_group'],
      crOn: json['cr_on'],
      totalRequests: json['total_requests'],
      totalRequestedQuantity: json['total_requested_quantity'],
      totalSuppliedQuantity: json['total_supplied_quantity'],
      totalPendingQuantity: json['total_pending_quantity'],
      requests: json['requests'] != null
          ? (json['requests'] as List)
          .map((v) => ShopAdminOrderRequestModel.fromJson(v))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request_group'] = requestGroup;
    data['cr_on'] = crOn;
    data['total_requests'] = totalRequests;
    data['total_requested_quantity'] = totalRequestedQuantity;
    data['total_supplied_quantity'] = totalSuppliedQuantity;
    data['total_pending_quantity'] = totalPendingQuantity;
    if (requests != null) {
      data['requests'] = requests!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}