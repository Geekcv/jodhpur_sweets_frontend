class FetchCategoryModel {
  var row_id;
  var category_name;
  var department_id;
  var department_name;
  var cr_on;
  var shop_name;
  var shop_id;

  FetchCategoryModel({
    this.row_id,
    this.category_name,
    this.department_id,
    this.department_name,
    this.cr_on,
    this.shop_name,
    this.shop_id
  });

  factory FetchCategoryModel.fromJson(Map<String, dynamic> json) {
    return FetchCategoryModel(
      row_id: json['row_id'] ?? "",
      category_name: json['category_name'] ?? "",
      department_id: json['department_id'] ?? "",
      department_name: json['department_name'] ?? "",
      cr_on: json['cr_on'] ?? "",
      shop_id: json['shop_id'] ?? "",
      shop_name: json['shop_name'] ?? "-",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'row_id': row_id,
      'category_name': category_name,
      'department_id': department_id,
      'department_name': department_name,
      'cr_on': cr_on,
      'shop_name': shop_name,
      'shop_id': shop_id,
    };
  }
}