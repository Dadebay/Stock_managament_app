import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:stock_managament_app/api_constants.dart';
import 'package:stock_managament_app/api_service.dart';
import 'package:stock_managament_app/app/modules/auth/views/auth_service.dart';
import 'package:stock_managament_app/app/modules/home/controllers/search_model.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/order_controller.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/order_model.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class OrderService {
  final OrderController orderController = Get.find();

  Future<List<OrderModel>> getOrders() async {
    final data = await ApiService().getRequest(ApiConstants.order, requiresToken: true);
    if (data is Map && data['results'] != null) {
      return (data['results'] as List).map((item) => OrderModel.fromJson(item)).toList().reversed.toList();
    } else if (data is List) {
      return (data).map((item) => OrderModel.fromJson(item)).toList().reversed.toList();
    } else {
      return [];
    }
  }

  Future<List<SearchModel>> getOrderProduct(int id) async {
    final data = await ApiService().getRequest("${ApiConstants.getOrderProducts}$id/", requiresToken: true);
    print(id);
    print(id);
    print(data);
    if (data is List) {
      print(data);
      return (data).map((item) => SearchModel.fromJson(item['product'])).toList();
    } else {
      return [];
    }
  }

  Future createOrder({required OrderModel model, required List<Map<String, dynamic>> products}) async {
    final body = <String, dynamic>{
      'status': model.status,
      'gaplama': model.gaplama,
      'date': model.date,
      'datetime': model.date,
      'name': model.name,
      'clientName': model.clientDetailModel!.name,
      'clientAddress': model.clientDetailModel!.address,
      'clientPhone': model.clientDetailModel!.phone,
      'discount': double.tryParse(model.discount.toString()),
      'coupon': model.coupon,
      'description': model.description,
      "count": int.parse(model.count.toString()),
      'products': products,
    };
    print(body);
    return ApiService().handleApiRequest(
      endpoint: ApiConstants.order,
      method: 'POST',
      body: body,
      requiresToken: true,
      handleSuccess: (responseJson) {
        print(responseJson);
        print(responseJson);
        print(responseJson);
        print(responseJson);
        print(responseJson);
        if (responseJson.isNotEmpty) {
          orderController.addOrder(OrderModel.fromJson(responseJson));
          Get.back();
          showSnackBar('success'.tr, 'Order added successfully'.tr, Colors.green);
        } else {
          showSnackBar('error'.tr, 'Order not added'.tr, Colors.red);
        }
      },
    );
  }

  Future<OrderModel?> editOrderManually({required OrderModel model}) async {
    final AuthStorage auth = AuthStorage();

    final token = await auth.getToken();
    final url = Uri.parse("${ApiConstants.order}${model.id}/");
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    final body = json.encode({
      'status': int.parse(model.status),
      'gaplama': model.gaplama,
      'date': model.date,
      'datetime': model.date,
      'name': model.name,
      'clientName': model.clientDetailModel?.name,
      'clientAddress': model.clientDetailModel?.address,
      'clientPhone': model.clientDetailModel?.phone,
      'discount': double.tryParse(model.discount),
      'coupon': model.coupon,
      'description': model.description,
      "count": model.count,
      // 'products': model.products
    });
    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      final updatedOrder = OrderModel.fromJson(jsonResponse);
      Get.back();

      return updatedOrder;
    } else {
      return null;
    }
  }
}
