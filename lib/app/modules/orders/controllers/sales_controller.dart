import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

import '../../../product/constants/list_constants.dart';

class SalesController extends GetxController {
  RxList orderCardList = [].obs;
  RxString isFilteredStatusName = "".obs;
  RxBool isFiltered = false.obs;
  RxList productList = [].obs;
  RxList selectedProductsList = [].obs;
  RxBool loadingDataSelectProductView = false.obs;
  RxBool loadingDataOrders = false.obs;
  List statuses = ['Preparing', 'Ready to ship', 'Shipped', 'Refund', 'Canceled'];
  CollectionReference collectionReference = FirebaseFirestore.instance.collection('sales');
  @override
  void onInit() async {
    super.onInit();
    getData();
  }

  Future<void> updateOrderStatus(SortOptions newStatus, String orderID) async {
    if (newStatus == SortOptions.canceled || newStatus == SortOptions.refund) {
      await _restoreProductQuantities(orderID);
    }
    await FirebaseFirestore.instance.collection('sales').doc(orderID).update({
      "status": ListConstants.statusMapping[newStatus.name]!,
    });
    showSnackBar("Done", "Status changed successfully", Colors.green);
    getData();
    Get.back();
  }

  Future<void> _restoreProductQuantities(String orderID) async {
    final productsSnapshot = await FirebaseFirestore.instance.collection('sales').doc(orderID).collection('products').get();
    for (var productDoc in productsSnapshot.docs) {
      final productName = productDoc['name'];
      final productQuantity = productDoc['quantity'];
      final productQuery = await FirebaseFirestore.instance.collection('products').where('name', isEqualTo: productName).get();
      if (productQuery.docs.isNotEmpty) {
        final productRef = productQuery.docs.first.reference;
        final currentQuantity = productQuery.docs.first['quantity'];
        await productRef.update({'quantity': currentQuantity + productQuantity});
      }
    }
  }

  sortSalesCards(int index) async {
    orderCardList.clear();
    loadingDataOrders.value = true;
    isFiltered.value = true;
    isFilteredStatusName.value = statuses[index];
    await FirebaseFirestore.instance.collection('sales').where('status', isEqualTo: statuses[index]).get().then((value) {
      if (value.docs.isEmpty) {
        orderCardList.clear();
      } else {
        orderCardList.value = value.docs;
      }
    });
    loadingDataOrders.value = false;
    Get.back();
  }

  getData() {
    loadingDataOrders.value = true;
    orderCardList.clear();
    collectionReference.orderBy("date", descending: true).limit(limit).get().then((value) {
      orderCardList.value = value.docs;
    });
    loadingDataOrders.value = false;
  }

  getDataSelectProductsView() async {
    productList.clear();

    loadingDataSelectProductView.value = true;
    await FirebaseFirestore.instance.collection('products').orderBy("date", descending: true).get().then((value) {
      for (var element in value.docs) {
        final product = ProductModel.fromDocument(element);
        productList.add({'product': product, 'count': 0});
      }
      for (var element in selectedProductsList) {
        final ProductModel product = element['product'];
        upgradeCount(product.documentID.toString(), int.parse(element['count'].toString()));
      }
    });
    loadingDataSelectProductView.value = false;
  }

  Future<void> onRefreshController() async {
    orderCardList.clear();
    loadingDataOrders.value = true;
    await collectionReference.orderBy("date", descending: true).limit(limit).get().then((value) {
      orderCardList.value = value.docs;
    });
    isFiltered.value = false;
    loadingDataOrders.value = false;
  }

  Future<void> onLoadingController() async {
    int length = orderCardList.length;
    loadingDataOrders.value = true;
    if (isFiltered.value == true) {
      collectionReference.where("status", isEqualTo: isFilteredStatusName.value.toLowerCase()).startAfterDocument(orderCardList.last).limit(limit).get().then((value) {
        orderCardList.addAll(value.docs);
        if (length == orderCardList.length) {
          showSnackBar("done", "endOFProduct", Colors.green);
        }
      });
    } else {
      collectionReference.orderBy("date", descending: true).startAfterDocument(orderCardList.last).limit(limit).get().then((value) {
        orderCardList.addAll(value.docs);
        if (length == orderCardList.length) {
          showSnackBar("done", "endOFProduct", Colors.green);
        }
      });
    }
    loadingDataOrders.value = false;
  }

  upgradeCount(String id, int count) {
    for (var element in productList) {
      final ProductModel product = element['product'];
      if (product.documentID.toString() == id.toString()) {
        element['count'] = count.toString();
      }
    }
    productList.refresh();
  }

  decreaseCount(String id, int count) {
    upgradeCount(id, count);
    if (selectedProductsList.isNotEmpty) {
      for (var element in selectedProductsList) {
        final ProductModel product = element['product'];
        if (product.documentID.toString() == id.toString()) {
          element['count'] = count;
        }
      }
      selectedProductsList.removeWhere((element) => element['count'].toString() == '0');
      selectedProductsList.refresh();
    }
  }

  addProductMain({required int count, required ProductModel product}) {
    if (selectedProductsList.isEmpty) {
      selectedProductsList.add({'product': product, 'count': count});
    } else {
      bool value = false;

      for (var element in selectedProductsList) {
        final ProductModel productMine = element['product'];
        if (product.documentID.toString() == productMine.documentID) {
          element['count'] = count;
          value = true;
        }
      }
      if (value == false) {
        selectedProductsList.add({'product': product, 'count': count});
      }
    }
    upgradeCount(product.documentID.toString(), count);

    selectedProductsList.refresh();
  }
}
