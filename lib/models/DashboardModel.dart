class DashboardModel {
  String? role;
  DashboardCards? cards;

  DashboardModel({this.role, this.cards});

  DashboardModel.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    cards = json['cards'] != null ? DashboardCards.fromJson(json['cards']) : null;
  }
}

class DashboardCards {
  var totalShops, totalUsers, totalOrders, totalSuppliers, lowStockItems; // ADMIN
  var totalStock, lowStock, pendingRequests, totalCounters; // SHOP_ADMIN
  var availableStock, myRequests; // COUNTER_USER
  var pendingOrders, acceptedOrders, dispatchedOrders; // SUPPLIER

  DashboardCards.fromJson(Map<String, dynamic> json) {
    // Admin Fields
    totalShops = json['total_shops'];
    totalUsers = json['total_users'];
    totalSuppliers = json['total_suppliers'];

    // Shop Admin Fields
    totalStock = json['total_stock'];
    totalCounters = json['total_counters'];

    // Counter User Fields
    availableStock = json['available_stock'] ?? json['total_stock'];
    myRequests = json['my_requests'];

    // Supplier Fields
    pendingOrders = json['pending_orders'];
    acceptedOrders = json['accepted_orders'];
    dispatchedOrders = json['dispatched_orders'];

    // Common Fields
    totalOrders = json['total_orders'];
    lowStockItems = json['low_stock_items'] ?? json['low_stock'];
    pendingRequests = json['pending_requests'];
  }
}