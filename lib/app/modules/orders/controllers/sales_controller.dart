import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

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
    print(orderCardList);
    collectionReference.orderBy("date", descending: true).limit(limit).get().then((value) {
      orderCardList.value = value.docs;
    });
    print(orderCardList);

    loadingDataOrders.value = false;
  }

  getDataSelectProductsView() async {
    loadingDataSelectProductView.value = true;
    await FirebaseFirestore.instance.collection('products').get().then((value) {
      productList.clear();
      for (var element in value.docs) {
        final product = ProductModel(
          name: element['name'],
          brandName: element['brand'].toString(),
          category: element['category'].toString(),
          cost: element['cost'],
          gramm: element['gramm'],
          image: element['image'].toString(),
          location: element['location'].toString(),
          material: element['material'].toString(),
          quantity: element['quantity'],
          sellPrice: element['sell_price'].toString(),
          note: element['note'].toString(),
          package: element['package'].toString(),
          documentID: element.id,
        );
        addProduct(product: product, count: 0);
      }
      for (var element in selectedProductsList) {
        final ProductModel product = element['product'];
        upgradeCount(int.parse(product.documentID.toString()), int.parse(element['count'].toString()));
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

  addProduct({required ProductModel product, required int count}) {
    productList.add({'product': product, 'count': count});
  }

  upgradeCount(int id, int count) {
    for (var element in productList) {
      final ProductModel product = element['product'];
      if (product.documentID.toString() == id.toString()) {
        element['count'] = count.toString();
      }
    }

    productList.refresh();
  }

  decreaseCount(int id, int count) {
    for (var element in productList) {
      final ProductModel product = element['product'];
      if (product.documentID.toString() == id.toString()) {
        element['count'] = count;
      }
    }
    productList.refresh();
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

  sumbitSale({required List<TextEditingController> textControllers, required String status}) {
    double sumCost = 0.0;
    double sumPrice = 0.0;
    for (var element in selectedProductsList) {
      final ProductModel product = element['product'];
      sumCost += double.parse(product.cost.toString()).toDouble() * int.parse(element['count'].toString());
      sumPrice += double.parse(product.sellPrice.toString()).toDouble() * int.parse(element['count'].toString());
      int.parse(product.quantity.toString()) - int.parse(element['count'].toString());
      FirebaseFirestore.instance.collection('products').doc(product.documentID).update({'quantity': int.parse(product.quantity.toString()) - int.parse(element['count'].toString())});
    }
    double discountPrice = textControllers[7].text == "" ? 0.0 : double.parse(textControllers[7].text.toString());
    if (discountPrice >= sumPrice) {
      showSnackBar("Error", "A discount price cannot be greater than the sum price.", Colors.red);
    } else {
      FirebaseFirestore.instance.collection('sales').add({
        'client_address': textControllers[4].text,
        'client_name': textControllers[3].text,
        'client_number': textControllers[2].text,
        'coupon': textControllers[5].text,
        'date': textControllers[0].text,
        'discount': textControllers[7].text,
        'note': textControllers[6].text,
        'package': textControllers[1].text,
        'status': status,
        'product_count': selectedProductsList.length.toString(),
        'sum_price': sumPrice.toString(),
        'sum_cost': sumCost.toString(),
      }).then((value) async {
        for (var element in selectedProductsList) {
          final ProductModel product = element['product'];
          await FirebaseFirestore.instance.collection('sales').doc(value.id).collection('products').add({
            'brand': product.brandName,
            'category': product.category,
            'cost': product.cost,
            'gramm': product.gramm,
            'image': product.image,
            'location': product.location,
            'material': product.material,
            'name': product.name,
            'note': product.note,
            'package': product.package,
            'quantity': element['count'],
            'sell_price': product.sellPrice,
          });
        }
      });
      Get.back();

      showSnackBar("Done", "Your purchase submitted ", Colors.green);
    }
  }
/////////////////=//////////////////

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
      if (!value) {
        selectedProductsList.add({'product': product, 'count': count});
      }
    }
    selectedProductsList.refresh();
  }
}
