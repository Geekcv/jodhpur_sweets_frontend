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

  // --- ADDED MISSING FIELDS FROM API RESPONSE ---
  dynamic orderId;
  dynamic orderNumber;
  dynamic orderType;
  dynamic parentOrderId;
  dynamic orderStatus;
  dynamic resolutionStatus;
  dynamic supplierId;
  dynamic supplierName;
  dynamic cancelledQuantity;
  dynamic reorderSuppliedQuantity;
  dynamic totalSuppliedQuantity;
  dynamic remainingQuantity;
  dynamic remainingAction;
  dynamic remainingActionOn;
  dynamic chalanId;
  bool? challanCreated;
  bool? challanVerified;
  dynamic challanStatus;
  dynamic dispatchDate;
  dynamic orderCreatedAt;
  dynamic orderUpdatedAt;

  // Nested Reorder orders list
  List<ReorderOrderModel>? reorderOrders;

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
    this.orderId,
    this.orderNumber,
    this.orderType,
    this.parentOrderId,
    this.orderStatus,
    this.resolutionStatus,
    this.supplierId,
    this.supplierName,
    this.cancelledQuantity,
    this.reorderSuppliedQuantity,
    this.totalSuppliedQuantity,
    this.remainingQuantity,
    this.remainingAction,
    this.remainingActionOn,
    this.chalanId,
    this.challanCreated,
    this.challanVerified,
    this.challanStatus,
    this.dispatchDate,
    this.orderCreatedAt,
    this.orderUpdatedAt,
    this.reorderOrders,
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

      // --- MAP ADDED FIELDS IN FROMJSON ---
      orderId: json['order_id'],
      orderNumber: json['order_number'],
      orderType: json['order_type'],
      parentOrderId: json['parent_order_id'],
      orderStatus: json['order_status'],
      resolutionStatus: json['resolution_status'],
      supplierId: json['supplier_id'],
      supplierName: json['supplier_name'],
      cancelledQuantity: json['cancelled_quantity'],
      reorderSuppliedQuantity: json['reorder_supplied_quantity'],
      totalSuppliedQuantity: json['total_supplied_quantity'],
      remainingQuantity: json['remaining_quantity'],
      remainingAction: json['remaining_action'],
      remainingActionOn: json['remaining_action_on'],
      chalanId: json['chalan_id'],
      challanCreated: json['challan_created'],
      challanVerified: json['challan_verified'],
      challanStatus: json['challan_status'],
      dispatchDate: json['dispatch_date'],
      orderCreatedAt: json['order_created_at'],
      orderUpdatedAt: json['order_updated_at'],
      reorderOrders: json['reorder_orders'] != null
          ? (json['reorder_orders'] as List)
          .map((i) => ReorderOrderModel.fromJson(i))
          .toList()
          : [],
    );
  }
}


class ReorderOrderModel {
  dynamic orderId;
  dynamic orderNumber;
  dynamic orderType;
  dynamic parentOrderId;
  dynamic orderStatus;
  dynamic resolutionStatus;
  dynamic requestedQuantity;
  dynamic suppliedQuantity;
  dynamic cancelledQuantity;
  dynamic remainingQuantity;
  dynamic itemStatus;
  dynamic remainingAction;
  dynamic chalanId;
  dynamic challanStatus;
  dynamic dispatchDate;
  dynamic createdAt;

  ReorderOrderModel({
    this.orderId,
    this.orderNumber,
    this.orderType,
    this.parentOrderId,
    this.orderStatus,
    this.resolutionStatus,
    this.requestedQuantity,
    this.suppliedQuantity,
    this.cancelledQuantity,
    this.remainingQuantity,
    this.itemStatus,
    this.remainingAction,
    this.chalanId,
    this.challanStatus,
    this.dispatchDate,
    this.createdAt,
  });

  factory ReorderOrderModel.fromJson(Map<String, dynamic> json) {
    return ReorderOrderModel(
      orderId: json['order_id'],
      orderNumber: json['order_number'],
      orderType: json['order_type'],
      parentOrderId: json['parent_order_id'],
      orderStatus: json['order_status'],
      resolutionStatus: json['resolution_status'],
      requestedQuantity: json['requested_quantity'],
      suppliedQuantity: json['supplied_quantity'],
      cancelledQuantity: json['cancelled_quantity'],
      remainingQuantity: json['remaining_quantity'],
      itemStatus: json['item_status'],
      remainingAction: json['remaining_action'],
      chalanId: json['chalan_id'],
      challanStatus: json['challan_status'],
      dispatchDate: json['dispatch_date'],
      createdAt: json['created_at'],
    );
  }
}