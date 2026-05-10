import 'package:flutter/cupertino.dart';
import '../utilities/functions.dart';

class ApiService extends ChangeNotifier {


  userLogin({mobilenumber, password}) async {
    var endpoint = "create-user";
    var data = {
      "fn": "common_fn",
      "se": "lo_ap_us",
      "data": {
        "phone": mobilenumber,
        "password": password,
      }
    };

    print("dataaaaaaaaaaaaaaaaaa:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPost(data: encodedData,endPoint: endpoint);
    var decodedData = await Functions.decodeData(res);
    print("this is the response:--------$decodedData");
    return decodedData;
  }



  addShop({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "cr_shop",
      "data": {
        "shop_name": param['shop_name'],
        "address": param['address'],
        "city": param['city'],
        "state": param['state'],
        "pincode": param['pincode'],
        "phone": param['phone'],
        "email": param['email'],
        "gst_number": param['gst_number'],
        "owner_name": param['owner_name'],
        "password": param['password'],
        "logo_url": param['logo_url'],
      }
    };

    print("data send:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }



  fetchShop({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "fe_shop",
      "data": {}
    };

    print("data send fe_shop:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }




  addCounter({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "cr_counter",
      "data": {
        "shop_id": param['shop_id'],
        "counter_name": param['counter_name'],
        "location": param['location'],
        "name": param['name'],
        "email": param['email'],
        "phone": param['phone'],
        "password": param['password'],
      }
    };

    print("data send:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }



  fetchCounters({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "fe_counter",
      "data": {}
    };

    print("data send fe_counter:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }



  addSupplier({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "cr_supplier",
      "data": {
        if (param['row_id'] != null)
        "row_id": param['row_id'],
        "supplier_name": param['supplier_name'],
        "phone": param['phone'],
        "email": param['email'],
        "address": param['address'],
        "password": param['password'],
      }
    };

    print("data send addSupplier:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }



  fetchSupplier({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "fe_supplier",
      "data": {}
    };

    print("data send fetchSupplier:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }




  addDepartment({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "cr_dep",
      "data": {
        if (param['row_id'] != null)
        "row_id": param['row_id'],
        "shop_id": param['shop_id'],
        "department_name": param['department_name'],
        "description": param['description'],
      }
    };

    print("data send addDepartment:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }



  fetchDepartments({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "fe_dep",
      "data": {}
    };

    print("data send fe_dep:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    // print("this is the data:-----------$decodedData");
    return decodedData;
  }




  fetchDeptAccoridngToShopIdWhenAddCategory({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "fe_dep_by_admin",
      "data": {
        'shop_id':param['shop_id'].toString(),
      }
    };

    print("data send fetchDeptAccoridngToShopIdWhenAddCategory:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }





  addCategory({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "cr_cat",
      "data": {
        if (param['row_id'] != null)
        "row_id": param['row_id'],
        "shop_id": param['shop_id'],
        "department_id": param['department_id'],
        "category_name": param['category_name'],
      }
    };

    print("data send addCategory:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }


  fetchCategory({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "fe_cat",
      "data": {}
    };

    print("data send fetchCategory:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }






  addSweets({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "cr_sweets",
      "data": {
        "category_id": param['category_id'].toString(),
        "shop_id": param['shop_id'].toString(),
        "sweet_name": param['sweet_name'].toString(),
        "unit": param['unit'].toString(),
        "price": param['price'].toString(),
        "shelf_life_days": param['shelf_life_days'].toString(),
        "description": param['description'].toString(),
        "image_url": param['image_url'],
        "counter_id": param['counter_id'],
        "return_type": param['return_type'],
      }
    };

    print("data send addSweets:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }



  fetchSweets({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "fe_sweets",
      "data": {}
    };

    print("data send fetchSweets:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }






  addInventory({token, param}) async {
    var transactionType = param['transaction_type'];
    print("This is the tran type:-----$transactionType");
    var data = {
      "fn": "common_fn",
      "se": "add_in",
      "data": {
        "counter_id": param['counter_id'].toString(),
        "sweet_id": param['sweet_id'].toString(),
        "transaction_type": param['transaction_type'].toString(),
        "quantity": param['quantity'].toString(),
        if(transactionType!='OUT' && transactionType!='ADJUST')
        "expiry_date": param['expiry_date'].toString(),
        if(transactionType!='OUT')
        "reference_id": param['reference_id'].toString(),
        "notes": param['notes'],
        if(transactionType!='OUT')
        "min_stock": param['min_stock'],
        if(transactionType!='OUT')
        "max_stock": param['max_stock'],
      }
    };

    print("data send addInventory:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }





  // Request by counters users
  creteOrderRequestByCounterUser({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "cr_counter_req",
      "data": {
        "counter_id": param['counter_id'].toString(),
        "items": param['items'],
      }
    };

    print("data send creteOrderRequestByCounterUser:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }








  createFinalOrderByShopAdmin({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "cr_final_order",
      "data": {
        "supplier_id": param['supplier_id'],
        "request_ids": param['request_ids'],
      }
    };

    print("data send createFinalOrderByShopAdmin:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }





  fetchMyOrderSupplier({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "fe_my_ord",
      "data": {
      }
    };

    print("data send fetchMyOrderSupplier:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }







  updateOrderStatus({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "up_ord_stu",
      "data": {
        "order_id": param['order_id'],
        "status": param['status'],
      }
    };

    print("data send updateOrderStatus:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }





  createChalanBySupplier({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "cr_challan",
      "data": {
        "order_id": param['order_id'],
        "dispatch_date": param['dispatch_date'],
        "transport_details": param['transport_details'],
      }
    };

    print("data send createChalanBySupplier:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }






  fetchInventory({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "fet_inv",
      "data": {}
    };

    print("data send fetchInventory:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }





  fetchStockHistory({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "fet_stock_his",
      "data": {}
    };

    print("data send fetchStockHistory:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }






  fetchOrderRequest({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "fe_order_req",
      "data": {
      }
    };

    print("data send fetchOrderRequest:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }







  fetchAllRequestOrderByShopAdmin({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "fe_all_req_counter",
      "data": {
      }
    };

    print("data send fetchAllRequestOrderByShopAdmin:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }





  fetchDashboard({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "fe_dash",
      "data": {
      }
    };

    print("data send fetchDashboard:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }








  fetchChallan({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "fe_challan",
      "data": {
      }
    };

    print("data send fetchChallan:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }





  downloadChalan({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "dow_ch_pdf",
      "data": {
        'chalan_id':param['chalan_id']
      }
    };

    print("data send downLoadChalan:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }





  /////////////  fetch Order status which approvied or reject by supplier /////////////////
  trackOrderStatusShopAdminSendToSupplier({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "fe_or_details",
      "data": {
      }
    };

    print("data send trackOrderStatusShopAdminSendToSupplier:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }






  fetchOwnProfile({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "fe_pro",
      "data": {
      }
    };

    print("data send fetchOwnProfile:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }



  updateProfile({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "up_profile",
      "data": param
    };

    print("data send updateProfile:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }





  fetchCategoryAndCounterAccoridngToShopIdWhenAddSweet({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "fe_cat_con_by_admin",
      "data": {
        'shop_id':param['shop_id'].toString(),
      }
    };

    print("data send fe_cat_con_by_admin:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }





  fetchExpireItems({token, param}) async {
    var data = {
    "fn": "common_fn",
    "se": "fe_expairy_items",
    "data": {
      'counter_id':param['counter_id']
      }
    };

    print("data send fetchExpireItems:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }







  fetchNotification({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "fe_notif",
      "data": {}
    };

    print("data send fetchNotification:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }


  markAsReadNotification({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "read_notify",
      "data": {
        'notification_id':param['notification_id']
      }
    };

    print("data send markAsReadNotification:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }




  updateOrderItemBySupplier({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "up_or_items",
      "data": {
        'order_id':param['order_id'],
        'items':param['items']
      }
    };

    print("data send updateOrderItemBySupplier:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }





  verifyChallanForAutoInv({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "verfiy_challan",
      "data": {
        'chalan_id':param['chalan_id'],
        'otp':param['otp']
      }
    };

    print("data send verifyChallanForAutoInv:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }




  fetchDashboardAccordingToRole({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "fe_dash_role",
      "data": {}
    };

    print("data send fetchDashboardAccordingToRole:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }



  downloadOrderRequestSupplierSide({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "dow_ord_req",
      "data": {
        'order_id':param['order_id']
      }
    };

    print("data send downloadOrderRequestSupplierSide:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }


  factoryReset({token, param}) async {
    var data = {
      "fn": "common_fn",
      "se": "de_ness_data",
      "data": {}
    };

    print("data send factoryReset:----------$data");
    var encodedData = await Functions.encodeData(data);
    var res = await Functions.httpPostToken(data: encodedData,token: token);
    var decodedData = await Functions.decodeData(res);
    return decodedData;
  }


}
