import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:js_order_website/models/FetchCounterModel.dart';
import 'package:js_order_website/models/FetchDepartmentModel.dart';
import 'package:js_order_website/models/FetchNotificationModel.dart';
import 'package:js_order_website/models/FetchShopModel.dart';
import 'package:js_order_website/models/FetchSupplierModel.dart';
import 'package:js_order_website/models/FetchSweetsModel.dart';
import '../controllers/api_controller.dart';
import '../models/ChalanDataModel.dart';
import '../models/ExpiredItemModel.dart';
import '../models/FetchCategoryModel.dart';
import '../models/FetchOrderRequestModel.dart';
import '../models/InventoryModel.dart';
import '../models/ShopAdminOrderRequestModel.dart';
import '../models/StockHistoryModel.dart';
import '../models/SupplierOrder.dart';
import '../models/TrackOwnOrdersByShopAdminModel.dart';
import '../models/UserProfileModel.dart';
import '../services/api_services.dart';
import '../utilities/AppSharedPreferences.dart';

final master_Provider = ChangeNotifierProvider((ref) {
  return ProviderClass();
});

class ProviderClass extends ChangeNotifier {
  var token;
  bool loading = false;
  String? loggedInUserRole;
  String? loggedInUserDepartment;


  loading_status({required status}) {
    loading = status;
    notifyListeners();
  }


  notify_Listners() {
    notifyListeners();
  }



  List<FetchShopModel> allShops=[];
  fetchShop({params}) async {
    loading = true;
    allShops.clear();
    notifyListeners();

    allShops = await ApiController.fetchShop(params: params);

    loading = false;
    notifyListeners();
    return allShops;
  }


  List<FetchCounterModel> allCounters=[];
  fetchCounter({params}) async {
    loading = true;
    allCounters.clear();
    notifyListeners();

    allCounters = await ApiController.fetchCounter(params: params);

    loading = false;
    notifyListeners();
    return allCounters;
  }


  List<FetchDepartmentModel> allDepartments=[];
  fetchDepartment({params}) async {
    loading = true;
    allDepartments.clear();
    notifyListeners();

    allDepartments = await ApiController.fetchDepartments(params: params);

    loading = false;
    notifyListeners();
    return allDepartments;
  }



  fetchDeptAccoridngToShopIdWhenAddCategory({params}) async {
    loading = true;
    allDepartments = [];
    notifyListeners();

    allDepartments = await ApiController.fetchDeptAccoridngToShopIdWhenAddCategory(params: params);

    loading = false;
    notifyListeners();
  }



  fetchCategoryAndCounterAccoridngToShopIdWhenAddSweet({params}) async {
    loading = true;
    allCategories = [];
    allCounters = [];
    notifyListeners();

    var res = await ApiController.fetchCategoryAndCounterAccoridngToShopIdWhenAddSweet(params: params);

    if (res != null) {
      allCategories = res['categories'] ?? [];
      allCounters = res['counters'] ?? [];
    }

    loading = false;
    notifyListeners();
  }



  List<FetchCategoryModel> allCategories=[];
  fetchCategory({params}) async {
    loading = true;
    allCategories.clear();
    notifyListeners();

    allCategories = await ApiController.fetchCategory(params: params);

    loading = false;
    notifyListeners();
    return allCategories;
  }


  List<FetchSupplierModel> allSuppliers=[];
  fetchSuppliers({params}) async {
    loading = true;
    allSuppliers.clear();
    notifyListeners();

    allSuppliers = await ApiController.fetchSupplier(params: params);

    loading = false;
    notifyListeners();
    return allSuppliers;
  }




  List<FetchSweetsModel> allSweets=[];
  fetchSweets({params}) async {
    loading = true;
    allSweets.clear();
    notifyListeners();

    allSweets = await ApiController.fetchSweets(params: params);

    loading = false;
    notifyListeners();
    return allSweets;
  }



  List<FetchOrderRequestModel> allOrdersOfCounterUser=[];
  fetchOrderRequest({params}) async {
    loading = true;
    allOrdersOfCounterUser.clear();
    notifyListeners();

    allOrdersOfCounterUser = await ApiController.fetchOrderRequest(params: params);

    loading = false;
    notifyListeners();
    return allOrdersOfCounterUser;
  }


  List<InventoryModel> allInventory=[];
  fetchInventory({params}) async {
    loading = true;
    allInventory.clear();
    notifyListeners();

    allInventory = await ApiController.fetchInventory(params: params);

    loading = false;
    notifyListeners();
    return allInventory;
  }




  List<StockHistoryModel> stockHistoryData=[];
  fetchStockHistory({params}) async {
    loading = true;
    stockHistoryData.clear();
    notifyListeners();

    stockHistoryData = await ApiController.fetchStockHistory(params: params);

    loading = false;
    notifyListeners();
    return stockHistoryData;
  }



  List<ShopAdminOrderRequestModel> orderRequest=[];
  fetchAllRequestOrderByShopAdmin({params}) async {
    loading = true;
    orderRequest.clear();
    notifyListeners();

    orderRequest = await ApiController.fetchAllRequestOrderByShopAdmin(params: params);

    loading = false;
    notifyListeners();
    return orderRequest;
  }



  List<SupplierOrder> supplierOrders=[];
  fetchMyOrderSupplier({params}) async {
    loading = true;
    supplierOrders.clear();
    notifyListeners();

    supplierOrders = await ApiController.fetchMyOrderSupplier(params: params);

    loading = false;
    notifyListeners();
    return supplierOrders;
  }




  List<ChalanDataModel> challanData=[];
  fetchChallan({params}) async {
    loading = true;
    challanData.clear();
    notifyListeners();

    challanData = await ApiController.fetchChallan(params: params);

    loading = false;
    notifyListeners();
    return challanData;
  }




  List<TrackOwnOrdersByShopAdminModel> ownOrdersShopAdmin=[];
  trackOrderStatusShopAdminSendToSupplier({params}) async {
    loading = true;
    ownOrdersShopAdmin.clear();
    notifyListeners();

    ownOrdersShopAdmin = await ApiController.trackOrderStatusShopAdminSendToSupplier(params: params);

    loading = false;
    notifyListeners();
    return ownOrdersShopAdmin;
  }




  List<UserProfileModel> userProfileData=[];
  fetchOwnProfile({params}) async {
    loading = true;
    userProfileData.clear();
    notifyListeners();

    userProfileData = await ApiController.fetchOwnProfile(params: params);

    loading = false;
    notifyListeners();
    return userProfileData;
  }





  List<ExpiredItemModel> expireItmesData=[];
  fetchExpireItems({params}) async {
    loading = true;
    expireItmesData.clear();
    notifyListeners();

    expireItmesData = await ApiController.fetchExpireItems(params: params);

    loading = false;
    notifyListeners();
    return expireItmesData;
  }



  FetchNotificationModel? allNotifications;
  fetchNotification({params}) async {
    loading = true;
    // allNotifications.clear();
    notifyListeners();

    allNotifications = await ApiController.fetchNotification(params: params);

    loading = false;
    notifyListeners();
    return allNotifications;
  }


}
