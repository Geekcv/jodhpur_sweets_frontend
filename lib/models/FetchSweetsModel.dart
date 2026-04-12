class FetchSweetsModel {
  var row_id;
  var sweet_name;
  var unit;
  var price;
  var shelf_life_days;
  var description;
  var image_url;
  var category_id;
  var category_name;
  var department_id;
  var department_name;
  var is_active;
  var cr_on;
  var up_on;
  var shop_id;
  var shop_name;
  var counter_name;
  var counter_id;

  FetchSweetsModel({
    this.row_id,
    this.sweet_name,
    this.unit,
    this.price,
    this.shelf_life_days,
    this.description,
    this.image_url,
    this.category_id,
    this.category_name,
    this.department_id,
    this.department_name,
    this.is_active,
    this.cr_on,
    this.up_on,
    this.shop_id,
    this.shop_name,
    this.counter_id,
    this.counter_name,
  });

  factory FetchSweetsModel.fromJson(Map<String, dynamic> json) {
    return FetchSweetsModel(
      row_id: json['row_id'] ?? "",
      sweet_name: json['sweet_name'] ?? "",
      unit: json['unit'] ?? "",
      price: json['price'] ?? 0,
      shelf_life_days: json['shelf_life_days'] ?? 0,
      description: json['description'] ?? "",
      image_url: json['image_url'] ?? "",
      category_id: json['category_id'] ?? "",
      category_name: json['category_name'] ?? "",
      department_id: json['department_id'] ?? "",
      department_name: json['department_name'] ?? "",
      is_active: json['is_active'],
      cr_on: json['cr_on'] ?? "",
      up_on: json['up_on'] ?? "",
      shop_name: json['shop_name'] ?? "",
      shop_id: json['shop_id'] ?? "",
      counter_name: json['counter_name'] ?? "",
      counter_id: json['counter_id'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'row_id': row_id,
      'sweet_name': sweet_name,
      'unit': unit,
      'price': price,
      'shelf_life_days': shelf_life_days,
      'description': description,
      'image_url': image_url,
      'category_id': category_id,
      'category_name': category_name,
      'department_id': department_id,
      'department_name': department_name,
      'is_active': is_active,
      'cr_on': cr_on,
      'up_on': up_on,
      'shop_name': shop_name,
      'shop_id': shop_id,
      'counter_name': counter_name,
      'counter_id': counter_id,
    };
  }
}