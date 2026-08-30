class FetchOrderRequestModel {
  dynamic requestGroup;
  dynamic crOn;
  dynamic totalRequests;
  dynamic totalRequestedQuantity;
  dynamic totalSuppliedQuantity;
  dynamic totalPendingQuantity;
  List<OrderItemModel>? requests;

  FetchOrderRequestModel({
    this.requestGroup,
    this.crOn,
    this.totalRequests,
    this.totalRequestedQuantity,
    this.totalSuppliedQuantity,
    this.totalPendingQuantity,
    this.requests,
  });

  factory FetchOrderRequestModel.fromJson(Map<String, dynamic> json) {
    return FetchOrderRequestModel(
      requestGroup: json['request_group'],
      crOn: json['cr_on'],
      totalRequests: json['total_requests'],
      totalRequestedQuantity: json['total_requested_quantity'],
      totalSuppliedQuantity: json['total_supplied_quantity'],
      totalPendingQuantity: json['total_pending_quantity'],
      requests: json['requests'] != null
          ? (json['requests'] as List)
          .map((i) => OrderItemModel.fromJson(i))
          .toList()
          : [],
    );
  }
}

class OrderItemModel {
  dynamic rowId;
  dynamic requestedOrder;
  dynamic requestedQuantity;
  dynamic shopStatus;
  dynamic supplierStatus;
  dynamic suppliedQuantity;
  dynamic pendingQuantity;
  dynamic crOn;
  dynamic requestGroup;
  dynamic counterId;
  dynamic counterName;
  dynamic sweetId;
  dynamic sweetName;
  dynamic unit;

  OrderItemModel({
    this.rowId,
    this.requestedOrder,
    this.requestedQuantity,
    this.shopStatus,
    this.supplierStatus,
    this.suppliedQuantity,
    this.pendingQuantity,
    this.crOn,
    this.requestGroup,
    this.counterId,
    this.counterName,
    this.sweetId,
    this.sweetName,
    this.unit,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      rowId: json['row_id'],
      requestedOrder: json['requested_order'],
      requestedQuantity: json['requested_quantity'],
      shopStatus: json['shop_status'],
      supplierStatus: json['supplier_status'],
      suppliedQuantity: json['supplied_quantity'],
      pendingQuantity: json['pending_quantity'],
      crOn: json['cr_on'],
      requestGroup: json['request_group'],
      counterId: json['counter_id'],
      counterName: json['counter_name'],
      sweetId: json['sweet_id'],
      sweetName: json['sweet_name'],
      unit: json['unit'],
    );
  }
}