import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/modules/home/controllers/search_model.dart';
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
  CollectionReference productsReference = FirebaseFirestore.instance.collection('products');
  @override
  void onInit() async {
    super.onInit();
    getData();
  }

  Future<void> updateOrderStatus(SortOptions newStatus, String orderID) async {
    if (newStatus == SortOptions.canceled || newStatus == SortOptions.refund) {
      await _restoreProductQuantities(orderID);
    }
    await collectionReference.doc(orderID).update({
      "status": ListConstants.statusMapping[newStatus.name]!,
    });
    showSnackBar("Done", "Status changed successfully", Colors.green);
    getData();
    Get.back();
  }

  Future<void> _restoreProductQuantities(String orderID) async {
    final productsSnapshot = await collectionReference.doc(orderID).collection('products').get();
    for (var productDoc in productsSnapshot.docs) {
      final productName = productDoc['name'];
      final productQuantity = productDoc['quantity'];
      final productQuery = await productsReference.where('name', isEqualTo: productName).get();
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
    print("Seçilen Status: ${statuses[index]}");
    QuerySnapshot snapshot = await collectionReference.where('status', isEqualTo: statuses[index]).limit(limit).get();
    orderCardList.assignAll(snapshot.docs);
    loadingDataOrders.value = false;
    Get.back();
  }

  getData() async {
    loadingDataOrders.value = true;
    orderCardList.clear();
    QuerySnapshot snapshot = await collectionReference.orderBy("date", descending: true).limit(limit).get();
    orderCardList.assignAll(snapshot.docs);
    loadingDataOrders.value = false;
  }

  getDataSelectProductsView() async {
    productList.clear();

    loadingDataSelectProductView.value = true;
    // await productsReference.orderBy("date", descending: true).get().then((value) {
    //   for (var element in value.docs) {
    //     final product = SearchModel.fromDocument(element);
    //     productList.add({'product': product, 'count': 0});
    //   }
    //   for (var element in selectedProductsList) {
    //     final SearchModel product = element['product'];
    //     upgradeCount(product.documentID.toString(), int.parse(element['count'].toString()));
    //   }
    // });
    loadingDataSelectProductView.value = false;
  }

  Future<void> onRefreshController() async {
    getData();
    isFiltered.value = false;
  }

  Future<void> onLoadingController() async {
    int length = orderCardList.length;
    loadingDataOrders.value = true;

    try {
      if (isFiltered.value == true) {
        Query query = collectionReference.where("status", isEqualTo: isFilteredStatusName.value);

        if (orderCardList.isNotEmpty) {
          print(orderCardList.last);
          query = query.startAfterDocument(orderCardList.last);
        }

        await query.limit(limit).get().then((value) {
          print("Gelen Belge Sayısı: ${value.docs.length}");
          print("Gelen Belgeler: ${value.docs.map((doc) => doc.data()).toList()}");
          orderCardList.addAll(value.docs);

          if (length == orderCardList.length) {
            showSnackBar("done", "endOFProduct", Colors.green);
          }
        });
      } else {
        Query query = collectionReference.orderBy("date", descending: true);

        if (orderCardList.isNotEmpty) {
          query = query.startAfterDocument(orderCardList.last);
        }

        await query.limit(limit).get().then((value) {
          print("Gelen Belge Sayısı: ${value.docs.length}");
          print("Gelen Belgeler: ${value.docs.map((doc) => doc.data()).toList()}");
          orderCardList.addAll(value.docs);

          if (length == orderCardList.length) {
            showSnackBar("done", "endOFProduct", Colors.green);
          }
        });
      }
    } catch (e) {
      print("Sorgu Hatası: $e");
      showSnackBar("Error", e.toString(), Colors.red);
    } finally {
      loadingDataOrders.value = false;
    }
  }

  upgradeCount(String id, int count) {
    // for (var element in productList) {
    //   final SearchModel product = element['product'];
    //   if (product.documentID.toString() == id.toString()) {
    //     element['count'] = count.toString();
    //   }
    // }
    productList.refresh();
  }

  decreaseCount(String id, int count) {
    upgradeCount(id, count);
    if (selectedProductsList.isNotEmpty) {
      // for (var element in selectedProductsList) {
      //   final SearchModel product = element['product'];
      //   // if (product.documentID.toString() == id.toString()) {
      //   //   element['count'] = count;
      //   // }
      // }
      selectedProductsList.removeWhere((element) => element['count'].toString() == '0');
      selectedProductsList.refresh();
    }
  }

  addProductMain({required int count, required SearchModel product}) {
    if (selectedProductsList.isEmpty) {
      selectedProductsList.add({'product': product, 'count': count});
    } else {
      bool value = false;

      // for (var element in selectedProductsList) {
      //   // final SearchModel productMine = element['product'];
      //   // if (product.documentID.toString() == productMine.documentID) {
      //   //   element['count'] = count;
      //   //   value = true;
      //   // }
      // }
      if (value == false) {
        selectedProductsList.add({'product': product, 'count': count});
      }
    }
    // upgradeCount(product.documentID.toString(), count);

    selectedProductsList.refresh();
  }
}
