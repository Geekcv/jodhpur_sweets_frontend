import 'package:flutter/material.dart';
import 'package:js_order_website/models/FetchCategoryModel.dart';
import 'package:js_order_website/models/FetchCounterModel.dart';
import 'package:js_order_website/models/FetchDepartmentModel.dart';
import 'package:js_order_website/models/FetchShopModel.dart';
import 'package:js_order_website/models/FetchSupplierModel.dart';
import 'package:js_order_website/models/FetchSweetsModel.dart';
import 'package:js_order_website/models/UserProfileModel.dart';
import '../Screens/LoginUserDetails.dart';
import '../app.dart';
import '../models/ChalanDataModel.dart';
import '../models/DashboardAccordingToRoleModel.dart';
import '../models/DashboardModel.dart';
import '../models/ExpiredItemModel.dart';
import '../models/FetchNotificationModel.dart';
import '../models/FetchOrderRequestModel.dart';
import '../models/InventoryModel.dart';
import '../models/ShopAdminOrderRequestModel.dart';
import '../models/StockHistoryModel.dart';
import '../models/SupplierOrder.dart';
import '../models/TrackOwnOrdersByShopAdminModel.dart';
import '../services/api_services.dart';
import '../utilities/AppSharedPreferences.dart';

class ApiController {


  static getloggedinUserToken() async {
    var val = await AppSharedPreferences.instance.getStringValue('token');
    return (val == null || val.isEmpty) ? null : val;
  }

  static getloggedInUserRole() async {
    var val = await AppSharedPreferences.instance.getStringValue('role');
    return (val == null || val.isEmpty) ? null : val;
  }

  static getloggedInUserId() async {
    var val = await AppSharedPreferences.instance.getStringValue('user_id');
    return (val == null || val.isEmpty) ? null : val;
  }

  static getloggedInCounterId() async {
    var val = await AppSharedPreferences.instance.getStringValue('counter_id');
    return (val == null || val.isEmpty) ? null : val;
  }

  static getloggedInShopId() async {
    var val = await AppSharedPreferences.instance.getStringValue('shop_id');
    return (val == null || val.isEmpty) ? null : val;
  }

  static getloggedInSupplierId() async {
    var val = await AppSharedPreferences.instance.getStringValue('supplier_id');
    return (val == null || val.isEmpty) ? null : val;
  }




  static setLoggedInAppUserToken(token) async {
    await AppSharedPreferences.instance.setStringValue('token', token?.toString() ?? "");
  }

  static setLoggedInUserRole(role) async {
    await AppSharedPreferences.instance.setStringValue('role', role?.toString() ?? "");
  }

  static setLoggedInUserId(userId) async {
    await AppSharedPreferences.instance.setStringValue('user_id', userId?.toString() ?? "");
  }

  static setLoggedInCounterId(counterId) async {
    // Agar null hai toh empty string save karo taaki "null" string na ban jaye
    await AppSharedPreferences.instance.setStringValue('counter_id', counterId?.toString() ?? "");
  }

  static setLoggedInShopId(shopId) async {
    await AppSharedPreferences.instance.setStringValue('shop_id', shopId?.toString() ?? "");
  }

  static setLoggedInSupplierId(supplierId) async {
    await AppSharedPreferences.instance.setStringValue('supplier_id', supplierId?.toString() ?? "");
  }







  static addShop({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().addShop(param: params,token: token);
    print("Add shop response:----$res");
    if(res['status']==0){
      return res;
    }
    else{
      return res;
    }
  }

  static fetchShop({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().fetchShop(param: params,token: token);
    print("fetchShop response:-----$res");

    List<FetchShopModel> shopData = [];
    if (res != null && res['status'] == 0) {
      for (var i = 0; i < res['data'].length; i++) {
        shopData.add(FetchShopModel.fromJson(res['data'][i]));
      }
      return shopData;
    } else {
      return shopData;
    }
  }






  static addCounter({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().addCounter(param: params,token: token);
    print("Add shop response:- $res");
    if(res['status']==0){
      return res;
    }
    else{
      return res;
    }
  }

  static fetchCounter({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().fetchCounters(param: params,token: token);
    print("fetchCounters response:-----$res");

    List<FetchCounterModel> counterDataList = [];
    if (res != null && res['status'] == 0) {
      for (var i = 0; i < res['data'].length; i++) {
        counterDataList.add(FetchCounterModel.fromJson(res['data'][i]));
      }
      return counterDataList;
    } else {
      return counterDataList;
    }
  }






  static addSupplier({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().addSupplier(param: params,token: token);
    print("Add addSupplier response:- $res");
    if(res['status']==0){
      return res;
    }
    else{
      return res;
    }
  }

  static fetchSupplier({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().fetchSupplier(param: params,token: token);
    print("fetchSupplier response:-----$res");
    List<FetchSupplierModel> supplierDataList = [];
    if (res != null && res['status'] == 0) {
      for (var i = 0; i < res['data'].length; i++) {
        supplierDataList.add(FetchSupplierModel.fromJson(res['data'][i]));
      }
      return supplierDataList;
    } else {
      return supplierDataList;
    }
  }






  static addDepartment({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().addDepartment(param: params,token: token);
    print("addDepartment response:- $res");
    if(res['status']==0){
      return res;
    }
    else{
      return res;
    }
  }

  static fetchDepartments({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().fetchDepartments(param: params,token: token);
    print("fetchDepartments response:-----$res");
    List<FetchDepartmentModel> data = [];
    if (res != null && res['status'] == 0) {
      for (var i = 0; i < res['data'].length; i++) {
        data.add(FetchDepartmentModel.fromJson(res['data'][i]));
      }
      return data;
    } else {
      return data;
    }
  }





  static addCategory({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().addCategory(param: params,token: token);
    print("addCategory response:- $res");
    if(res['status']==0){
      return res;
    }
    else{
      return res;
    }
  }


  static fetchCategory({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().fetchCategory(param: params,token: token);
    print("fetchCategory response:-----$res");
    List<FetchCategoryModel> data = [];
    if (res != null && res['status'] == 0) {
      for (var i = 0; i < res['data'].length; i++) {
        data.add(FetchCategoryModel.fromJson(res['data'][i]));
      }
      return data;
    } else {
      return data;
    }
  }






  static addSweets({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().addSweets(param: params,token: token);
    print("addSweets response:- $res");
    if(res['status']==0){
      return res;
    }
    else{
      return res;
    }
  }

  static fetchSweets({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().fetchSweets(param: params,token: token);
    print("fetchSweets response:-----$res");
    List<FetchSweetsModel> data = [];
    if (res != null && res['status'] == 0) {
      for (var i = 0; i < res['data'].length; i++) {
        data.add(FetchSweetsModel.fromJson(res['data'][i]));
      }
      return data;
    } else {
      return data;
    }
    // return res;
  }






  static addInventory({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().addInventory(param: params,token: token);
    print("addInventory response:- $res");
    if(res['status']==0){
      return res;
    }
    else{
      return res;
    }
  }



  static creteOrderRequestByCounterUser({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().creteOrderRequestByCounterUser(param: params,token: token);
    print("creteOrderRequestByCounterUser response:- $res");
    if(res['status']==0){
      return res;
    }
    else{
      return res;
    }
  }







  static fetchOrderRequest({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().fetchOrderRequest(param: params,token: token);
    print("fetchOrderRequest response:-----$res");
    List<FetchOrderRequestModel> data = [];
    if (res != null && res['status'] == 0) {
      for (var i = 0; i < res['data'].length; i++) {
        data.add(FetchOrderRequestModel.fromJson(res['data'][i]));
      }
      return data;
    } else {
      return data;
    }
    // return res;
  }




  static createFinalOrderByShopAdmin({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().createFinalOrderByShopAdmin(param: params,token: token);
    print("createFinalOrderByShopAdmin response:- $res");
    if(res['status']==0){
      return res;
    }
    else{
      return res;
    }
  }







  static fetchAllRequestOrderByShopAdmin({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().fetchAllRequestOrderByShopAdmin(param: params,token: token);
    print("fetchAllRequestOrderByShopAdmin response:-----$res");
    List<ShopAdminOrderRequestModel> data = [];
    if (res != null && res['status'] == 0) {
      for (var i = 0; i < res['data'].length; i++) {
        data.add(ShopAdminOrderRequestModel.fromJson(res['data'][i]));
      }
      return data;
    } else {
      return data;
    }
    // return res;
  }




  static Future<DashboardModel?> fetchDashboard({params}) async {
    var token = await getloggedinUserToken();
    var res = await ApiService().fetchDashboard(param: params, token: token);
    print("fetchDashboard response:-----$res");

    if (res != null && res['status'] == 0) {
      // Response['data'] ek Map hai, List nahi. Isliye loop nahi chalega.
      return DashboardModel.fromJson(res['data']);
    } else {
      return null;
    }
  }


  static fetchMyOrderSupplier({context, params}) async {
    var token = await getloggedinUserToken();
    var res = await ApiService().fetchMyOrderSupplier(param: params, token: token);

    print("fetchMyOrderSupplier response:-----$res");

    List<SupplierOrder> data = [];

    if (res != null && res['status'] == 0 && res['data'] != null) {
      var rawList = res['data'];

      for (var i = 0; i < rawList.length; i++) {
        var orderJson = rawList[i];
        var orderModel = SupplierOrder.fromJson(orderJson);
        data.add(orderModel);
      }

      return data;
    } else {
      // Agar status 1 hai ya data null hai toh khali list bhej do
      return data;
    }
  }


  static fetchInventory({context,params}) async{
    var token = await getloggedinUserToken();
    var res = await ApiService().fetchInventory(param: params,token: token);
    print("fetchInventory response:-----$res");
    List<InventoryModel> data = [];
    if (res != null && res['status'] == 0) {
      for (var i = 0; i < res['data'].length; i++) {
        data.add(InventoryModel.fromJson(res['data'][i]));
      }
      return data;
    } else {
      return data;
    }
    // return res;
  }


  static fetchStockHistory({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().fetchStockHistory(param: params,token: token);
    print("fetchStockHistory response:-----$res");
    List<StockHistoryModel> data = [];
    if (res != null && res['status'] == 0) {
      for (var i = 0; i < res['data'].length; i++) {
        data.add(StockHistoryModel.fromJson(res['data'][i]));
      }
      return data;
    } else {
      return data;
    }
    // return res;
  }






  static updateOrderStatus({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().updateOrderStatus(param: params,token: token);
    print("updateOrderStatus response:-----$res");
    if (res != null && res['status'] == 0) {
      return res;
    } else {
      return res;
    }
    // return res;
  }



  static createChalanBySupplier({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().createChalanBySupplier(param: params,token: token);
    print("createChalanBySupplier response:-----$res");
    if (res != null && res['status'] == 0) {
      return res;
    } else {
      return res;
    }
    // return res;
  }





  static fetchChallan({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().fetchChallan(param: params,token: token);
    print("fetchChallan response:-----$res");
    List<ChalanDataModel> data = [];
    if (res != null && res['status'] == 0) {
      for (var i = 0; i < res['data'].length; i++) {
        data.add(ChalanDataModel.fromJson(res['data'][i]));
      }
      return data;
    } else {
      return data;
    }
    // return res;
  }



  static downLoadChalan({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().downloadChalan(param: params,token: token);
    print("downloadChalan response:-----$res");

    if (res != null && res['status'] == 0) {
      return res;
    } else {
      return res;
    }
  }




  static trackOrderStatusShopAdminSendToSupplier({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().trackOrderStatusShopAdminSendToSupplier(param: params,token: token);
    print("trackOrderStatusShopAdminSendToSupplier response:-----$res");
    List<TrackOwnOrdersByShopAdminModel> data = [];
    if (res != null && res['status'] == 0) {
      for (var i = 0; i < res['data'].length; i++) {
        data.add(TrackOwnOrdersByShopAdminModel.fromJson(res['data'][i]));
      }
      return data;
    } else {
      return data;
    }
    // return res;
  }



  static fetchOwnProfile({context, params}) async {
    var token = await getloggedinUserToken();
    var res = await ApiService().fetchOwnProfile(param: params, token: token);

    print("fetchOwnProfile response:-----$res");

    List<UserProfileModel> data = [];

    if (res != null && res['status'] == 0 && res['data'] != null) {
      var rawData = res['data'];

      // AGAR DATA LIST HAI
      if (rawData is List) {
        for (var item in rawData) {
          data.add(UserProfileModel.fromJson(item));
        }
      }
      // AGAR DATA SINGLE MAP (OBJECT) HAI -> Jaisa aapka response dikha raha hai
      else if (rawData is Map<String, dynamic>) {
        data.add(UserProfileModel.fromJson(rawData));
      }

      return data;
    } else {
      return data;
    }
  }


  static updateProfile({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().updateProfile(param: params,token: token);
    print("$res");
    if (res != null && res['status'] == 0) {
      return res;
    } else {
      return res;
    }
  }






  static fetchDeptAccoridngToShopIdWhenAddCategory({context, params}) async {
    var token = await getloggedinUserToken();
    var res = await ApiService().fetchDeptAccoridngToShopIdWhenAddCategory(param: params, token: token);

    print("fetchDeptAccoridngToShopIdWhenAddCategory response:-----$res");

    List<FetchDepartmentModel> data = [];

    if (res != null && res['status'] == 0) {
      for (var i = 0; i < res['data'].length; i++) {
        data.add(FetchDepartmentModel.fromJson(res['data'][i]));
      }
      return data;
    } else {
      return data;
    }
  }




  static fetchCategoryAndCounterAccoridngToShopIdWhenAddSweet({context, params}) async {
    var token = await getloggedinUserToken();
    var res = await ApiService().fetchCategoryAndCounterAccoridngToShopIdWhenAddSweet(param: params, token: token);

    print("API Response: $res");

    Map<String, List<dynamic>> finalData = {
      'categories': [],
      'counters': []
    };

    if (res != null && res['status'] == 0) {
      var rawData = res['data']; // data: { counters: [], categories: [] }

      if (rawData['categories'] != null) {
        finalData['categories'] = (rawData['categories'] as List).map((item) => FetchCategoryModel.fromJson(item)).toList();
      }

      if (rawData['counters'] != null) {
        finalData['counters'] = (rawData['counters'] as List).map((item) => FetchCounterModel.fromJson(item)).toList();
      }
    }
    return finalData;
  }



  static fetchExpireItems({context, params}) async {
    var token = await getloggedinUserToken();
    var res = await ApiService().fetchExpireItems(param: params, token: token);

    print("fetchExpireItems response:-----$res");

    List<ExpiredItemModel> data = [];

    if (res != null && res['status'] == 0) {
      for (var i = 0; i < res['data'].length; i++) {
        data.add(ExpiredItemModel.fromJson(res['data'][i]));
      }
      return data;
    } else {
      return data;
    }
  }




  static fetchNotification({context, params}) async {
    var token = await getloggedinUserToken();
    var res = await ApiService().fetchNotification(param: params, token: token);

    print("fetchNotification response:-----$res");

    if (res != null && (res['status'] == 0 || res['status'] == "0")) {
      return FetchNotificationModel.fromJson(res['data']);
    } else {
      return FetchNotificationModel(notifications: [],unread: 0,total: 0,page: 1,limit: 10);
    }
  }


    static markAsReadNotification({context, params}) async {
    var token = await getloggedinUserToken();
    var res = await ApiService().markAsReadNotification(param: params, token: token);

    print("fetchNotification response:-----$res");

    if (res != null && (res['status'] == 0 || res['status'] == "0")) {
      return res;
    } else {
      return res;
    }
  }



  static updateOrderItemBySupplier({context, params}) async {
    var token = await getloggedinUserToken();
    var res = await ApiService().updateOrderItemBySupplier(param: params, token: token);

    print("updateOrderItemBySupplier response:-----$res");

    if (res != null && (res['status'] == 0 || res['status'] == "0")) {
      return res;
    } else {
      return res;
    }
  }




  static verifyChallanForAutoInv({context, params}) async {
    var token = await getloggedinUserToken();
    var res = await ApiService().verifyChallanForAutoInv(param: params, token: token);

    print("verifyChallanForAutoInv response:-----$res");

    if (res != null && (res['status'] == 0 || res['status'] == "0")) {
      return res;
    } else {
      return res;
    }
  }



  // static fetchDashboardAccordingToRole({context, params}) async {
  //   var token = await getloggedinUserToken();
  //   var res = await ApiService().fetchDashboardAccordingToRole(param: params, token: token);
  //
  //   print("fetchDashboardAccordingToRole response:-----$res");
  //
  //   if (res != null && (res['status'] == 0 || res['status'] == "0")) {
  //     return res;
  //   } else {
  //     return res;
  //   }
  // }

  static Future<dynamic> fetchDashboardAccordingToRole({required BuildContext context,Map<String, dynamic>? params,required String role}) async {
    try {
      var token = await getloggedinUserToken();
      var res = await ApiService().fetchDashboardAccordingToRole(param: params, token: token);

      print("role-----$role");
      print("fetchDashboardAccordingToRole response:-----$res");

      if (res != null && (res['status'] == 0 || res['status'] == "0")) {
        final data = res['data'];

        // Role mapping logic (Case insensitive)
        switch (role.toLowerCase()) {
          case 'admin':
            return AdminDashboardModel.fromJson(data);
          case 'shop_admin':
            return ShopDashboardModel.fromJson(data);
          case 'counter_user':
            return CounterDashboardModel.fromJson(data);
          case 'supplier':
            return SupplierDashboardModel.fromJson(data);
          default:
            return data;
        }
      } else {
        return null;
      }
    } catch (e) {
      print("Error in fetchDashboardAccordingToRole: $e");
      return null;
    }
  }



  static downloadOrderRequestSupplierSide({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().downloadOrderRequestSupplierSide(param: params,token: token);
    print("downloadOrderRequestSupplierSide response:-----$res");

    if (res != null && res['status'] == 0) {
      return res;
    } else {
      return res;
    }
  }



  static factoryReset({context,params})async{
    var token = await getloggedinUserToken();
    var res = await ApiService().factoryReset(param: params,token: token);
    print("factoryReset response:-----$res");

    if (res != null && res['status'] == 0) {
      return res;
    } else {
      return res;
    }
  }





  static logOut(context) async {
    LoginUserDetails.clear();
    await AppSharedPreferences.instance.removeAll();
    // Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (context) => App()));
    Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (context) => const App()), (route) => false,
    );
  }


}
