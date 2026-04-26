// Admin Dashboard Model
import '../Screens/LoginUserDetails.dart';

class DashboardAccordingToRoleModel {
  final List<Summary> summary;
  final Map<String, List<ChartData>> charts;
  final List<Order> recentOrders;

  DashboardAccordingToRoleModel({required this.summary, required this.charts, required this.recentOrders});

  factory DashboardAccordingToRoleModel.fromJson(Map<String, dynamic> json) {
    return DashboardAccordingToRoleModel(
      // summary list ke liye safe casting
      summary: (json['summary'] as List?)?.map((i) => Summary.fromJson(i)).toList() ?? [],

      // charts map ke liye safe casting
      charts: (json['charts'] as Map<String, dynamic>?)?.map((key, value) =>
          MapEntry(key, (value as List?)?.map((i) => ChartData.fromJson(i)).toList() ?? [])) ?? {},

      // recent_orders ke liye safe casting
      recentOrders: (json['recent_orders'] as List?)?.map((i) => Order.fromJson(i)).toList() ?? [],
    );
  }
}


class Summary {
  var totalShops, activeShops, totalUsers, totalSuppliers,
      totalOrders, pending, approved, rejected, totalItems;

  Summary({
    this.totalShops = '0',
    this.activeShops = '0',
    this.totalUsers = '0',
    this.totalSuppliers = '0',
    this.totalOrders = '0',
    this.pending = '0',
    this.approved = '0',
    this.rejected = '0',
    this.totalItems = '0',
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    // .toString() handle kar leta hai chahe API int de ya string
    totalItems: json['total_items']?.toString() ?? '0',
    totalShops: json['total_shops']?.toString() ?? '0',
    activeShops: json['active_shops']?.toString() ?? '0',
    totalUsers: json['total_users']?.toString() ?? '0',
    totalSuppliers: json['total_suppliers']?.toString() ?? '0',
    totalOrders: json['total_orders']?.toString() ?? '0',
    pending: json['pending']?.toString() ?? '0',
    approved: json['approved']?.toString() ?? '0',
    rejected: json['rejected']?.toString() ?? '0',
  );
}


class InventoryItem {
  var id, rowId, counterId, sweetId, quantity, expiryDate, crOn, upOn, minStock, maxStock, sweetName;

  InventoryItem({
    this.id, this.rowId, this.counterId, this.sweetId, this.quantity,
    this.expiryDate, this.crOn, this.upOn, this.minStock, this.maxStock, this.sweetName
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
      id: json['id'], rowId: json['row_id'], counterId: json['counter_id'],
      sweetId: json['sweet_id'], quantity: json['quantity'], expiryDate: json['expiry_date'],
      crOn: json['cr_on'], upOn: json['up_on'], minStock: json['min_stock'],
      maxStock: json['max_stock'], sweetName: json['sweet_name']
  );
}



class Order {
  var rowId, status, date, shop_name, counter_name, sweets;
  Order({this.rowId, this.status, this.date,this.shop_name,this.counter_name,this.sweets});

  factory Order.fromJson(Map<String, dynamic> json) => Order(
      rowId: json['row_id'], status: json['order_status'], date: json['order_date'],
    shop_name: json['shop_name'], counter_name: json['counter_name'], sweets: json['sweets'],
  );
}



class ChartData {
  var date;
  var transaction_type;
  var count;

  ChartData({this.date, this.count,this.transaction_type});

  factory ChartData.fromJson(Map<String, dynamic> json) => ChartData(
      date: json['date'],
      count: LoginUserDetails.isCounterUser  ? double.tryParse(json['total']?.toString() ?? '0.0') ?? 0.0 : json['count'],
      // count: double.tryParse(json['total']?.toString() ?? '0.0') ?? 0.0,
    transaction_type: json['transaction_type']?.toString() ?? 'N/A',
  );
}




// ADMIN DASHBOARD
class AdminDashboardModel {
  final List<Summary> summary;
  final List<ChartData> orderTrend;
  final List<Order> recentOrders;

  AdminDashboardModel({required this.summary, required this.orderTrend, required this.recentOrders});

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) => AdminDashboardModel(
    summary: (json['summary'] as List?)?.map((i) => Summary.fromJson(i)).toList() ?? [],
    orderTrend: (json['charts']?['orders_trend'] as List?)?.map((i) => ChartData.fromJson(i)).toList() ?? [],
    recentOrders: (json['recent_orders'] as List?)?.map((i) => Order.fromJson(i)).toList() ?? [],
  );
}



// SHOP ADMIN DASHBOARD
class ShopDashboardModel {
  final List<Summary> summary;
  final List<InventoryItem> lowStock;
  final List<InventoryItem> outOfStock;
  final double totalAmount;
  final List<ChartData> orderTrend;
  final List<InventoryItem> expiryAlerts;

  ShopDashboardModel({required this.summary, required this.lowStock, required this.outOfStock, required this.totalAmount, required this.orderTrend, required this.expiryAlerts});

  factory ShopDashboardModel.fromJson(Map<String, dynamic> json) => ShopDashboardModel(
    summary: (json['summary'] as List?)?.map((i) => Summary.fromJson(i)).toList() ?? [],
    lowStock: (json['inventory']?['low_stock'] as List?)?.map((i) => InventoryItem.fromJson(i)).toList() ?? [],
    outOfStock: (json['inventory']?['out_of_stock'] as List?)?.map((i) => InventoryItem.fromJson(i)).toList() ?? [],
    totalAmount: double.tryParse(json['financials']?['total_amount']?.toString() ?? '0') ?? 0.0,
    orderTrend: (json['charts']?['orders_trend'] as List?)?.map((i) => ChartData.fromJson(i)).toList() ?? [],
    expiryAlerts: (json['alerts']?['expiry'] as List?)?.map((i) => InventoryItem.fromJson(i)).toList() ?? [],
  );
}



// COUNTER DASHBOARD
class CounterDashboardModel {
  final List<Summary> summary;
  final List<InventoryItem> inventory;
  final List<RequestItem> requests; // Dynamic se RequestItem mein update kar diya
  final List<ChartData> stockMovement;
  final List<InventoryItem> expiryAlerts;

  CounterDashboardModel({required this.summary, required this.inventory, required this.requests, required this.stockMovement, required this.expiryAlerts});

  factory CounterDashboardModel.fromJson(Map<String, dynamic> json) => CounterDashboardModel(
    summary: (json['summary'] as List?)?.map((i) => Summary.fromJson(i)).toList() ?? [],
    inventory: (json['inventory'] as List?)?.map((i) => InventoryItem.fromJson(i)).toList() ?? [],
    requests: (json['requests'] as List?)?.map((i) => RequestItem.fromJson(i)).toList() ?? [],
    stockMovement: (json['charts']?['stock_movement'] as List?)?.map((i) => ChartData.fromJson(i)).toList() ?? [],
    expiryAlerts: (json['alerts']?['expiry'] as List?)?.map((i) => InventoryItem.fromJson(i)).toList() ?? [],
  );
}




// SUPPLIER DASHBOARD
class SupplierDashboardModel {
  final List<Summary> summary;
  final List<SupplierOrdersModel> orders;
  final List<ChartData> orderTrend;
  var pendingItems;
  var unverifiedChalans;

  SupplierDashboardModel({required this.summary, required this.orders, required this.orderTrend, this.pendingItems, this.unverifiedChalans});

  factory SupplierDashboardModel.fromJson(Map<String, dynamic> json) => SupplierDashboardModel(
    summary: (json['summary'] as List?)?.map((i) => Summary.fromJson(i)).toList() ?? [],
    orders: (json['orders'] as List?)?.map((i) => SupplierOrdersModel.fromJson(i)).toList() ?? [],
    orderTrend: (json['charts']?['orders_trend'] as List?)?.map((i) => ChartData.fromJson(i)).toList() ?? [],
    pendingItems: json['stats']?['pending_items'] ?? '0',
    unverifiedChalans: json['stats']?['unverified_chalans'] ?? '0',
  );
}


class SupplierOrdersModel {
  final String? rowId, status, date, shopName;
  final List<String> counters;

  SupplierOrdersModel({
    this.rowId,
    this.status,
    this.date,
    this.shopName,
    this.counters = const []
  });

  factory SupplierOrdersModel.fromJson(Map<String, dynamic> json) {
    // Counters ko comma se split karke list bana rahe hain
    final countersRaw = json['counters']?.toString() ?? "";
    final countersList = countersRaw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return SupplierOrdersModel(
      rowId: json['row_id']?.toString(),
      status: json['order_status']?.toString(),
      date: json['order_date']?.toString(),
      shopName: json['shop_name']?.toString(),
      counters: countersList,
    );
  }
}




class RequestItem {
  String id;
  String rowId;
  String counterId;
  String sweetId;
  String quantity;
  String sweet_name;
  String status;
  String crOn;
  String upOn;

  RequestItem({
    this.id = '',
    this.rowId = '',
    this.counterId = '',
    this.sweetId = '',
    this.quantity = '0',
    this.status = '',
    this.crOn = '',
    this.sweet_name = '',
    this.upOn = '',
  });

  factory RequestItem.fromJson(Map<String, dynamic> json) => RequestItem(
    id: json['id']?.toString() ?? '',
    rowId: json['row_id']?.toString() ?? '',
    counterId: json['counter_id']?.toString() ?? '',
    sweetId: json['sweet_id']?.toString() ?? '',
    sweet_name: json['sweet_name']?.toString() ?? 'Unknown Item', // Yahan map kiya
    quantity: json['quantity']?.toString() ?? '0',
    status: json['status']?.toString() ?? '',
    crOn: json['cr_on']?.toString() ?? '',
    upOn: json['up_on']?.toString() ?? '',
  );
}