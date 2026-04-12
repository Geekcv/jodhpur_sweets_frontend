class InventoryModel {
  var rowId;
  var quantity; // dynamic because it could be int or double
  var minStock;
  var maxStock;
  var expiryDate;
  var sweetId;
  var sweetName;
  var unit;
  var price;
  var imageUrl;
  var counterId;
  var counterName;
  var location;
  var shopId;
  var crOn;

  InventoryModel({
    this.rowId,
    this.quantity,
    this.minStock,
    this.maxStock,
    this.expiryDate,
    this.sweetId,
    this.sweetName,
    this.unit,
    this.price,
    this.imageUrl,
    this.counterId,
    this.counterName,
    this.location,
    this.shopId,
    this.crOn,
  });

  // From JSON
  InventoryModel.fromJson(Map<String, dynamic> json) {
    rowId = json['row_id'];
    quantity = json['quantity'];
    minStock = json['min_stock'];
    maxStock = json['max_stock'];
    expiryDate = json['expiry_date'];
    sweetId = json['sweet_id'];
    sweetName = json['sweet_name'];
    unit = json['unit'];
    price = json['price'];
    imageUrl = json['image_url'];
    counterId = json['counter_id'];
    counterName = json['counter_name'];
    location = json['location'];
    shopId = json['shop_id'];
    crOn = json['cr_on'];
  }

  // To JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['row_id'] = rowId;
    data['quantity'] = quantity;
    data['min_stock'] = minStock;
    data['max_stock'] = maxStock;
    data['expiry_date'] = expiryDate;
    data['sweet_id'] = sweetId;
    data['sweet_name'] = sweetName;
    data['unit'] = unit;
    data['price'] = price;
    data['image_url'] = imageUrl;
    data['counter_id'] = counterId;
    data['counter_name'] = counterName;
    data['location'] = location;
    data['shop_id'] = shopId;
    data['cr_on'] = crOn;
    return data;
  }
}