import 'package:flutter/material.dart';

class FetchDepartmentModel{
  var row_id;
  var department_name;
  var description;
  var shop_id;
  var shop_name;
  var cr_on;

  FetchDepartmentModel({this.row_id,this.department_name,this.cr_on,this.description,this.shop_id,this.shop_name});

  factory FetchDepartmentModel.fromJson(Map<String, dynamic> json) {
    return FetchDepartmentModel(
      row_id: json['row_id'] ?? "",
      department_name: json['department_name'] ?? " ",
      cr_on: json['cr_on'],
      description: json['description'],
      shop_name: json['shop_name'],
      shop_id: json['shop_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'row_id': row_id,
      'department_name': department_name,
      'cr_on': cr_on,
      'description': description,
      'shop_name': shop_name,
      'shop_id': shop_id,
    };
  }
}


