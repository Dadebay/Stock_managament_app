import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
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
    collectionReference.orderBy("date", descending: true).limit(limit).get().then((value) {
      orderCardList.value = value.docs;
    });
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
          cost: element['cost'].toString(),
          gramm: element['gramm'].toString(),
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

  addProduct({required ProductModel product, required int count}) {
    productList.add({'product': product, 'count': count});
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

  sumbitSale({required List<TextEditingController> textControllers, required String status, required BuildContext context}) async {
    final HomeController homeController = Get.find<HomeController>();
    double sumCost = 0.0;
    double sumPrice = 0.0;
    //TODO: ADD await function if ap not working very vell
    for (var element in selectedProductsList) {
      final ProductModel product = element['product'];
      sumCost += double.parse(product.cost.toString()).toDouble() * int.parse(element['count'].toString());
      sumPrice += double.parse(product.sellPrice.toString()).toDouble() * int.parse(element['count'].toString());
      int.parse(product.quantity.toString()) - int.parse(element['count'].toString());
      FirebaseFirestore.instance.collection('products').doc(product.documentID).update({'quantity': int.parse(product.quantity.toString()) - int.parse(element['count'].toString())});
    }
    double discountPrice = textControllers[7].text == "" ? 0.0 : double.parse(textControllers[7].text.toString());

    if (discountPrice >= sumPrice || sumPrice - discountPrice < 0) {
      showSnackBar("Error", "A discount price cannot be greater than the sum price.", Colors.red);
      homeController.agreeButton.value = false;
    } else {
      sumPrice -= discountPrice;
      //write sale to sales column-----------------------------------------------------------------
      await FirebaseFirestore.instance.collection('sales').add({
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
        //write products to sales id -----------------------------------------------------------------
        writeProductToSaleID(value.id);
      });
      // write client to clients column ------------------------------------------------------------
      findClientOrAddNewOne(textControllers: textControllers, sumPrice: sumPrice.toString());
      selectedProductsList.sort((a, b) {
        return a['date'].compareTo(b['date']);
      });
      Navigator.of(context).pop();
      homeController.agreeButton.value = false;
      showSnackBar("Done", "Your purchase submitted ", Colors.green);
    }
  }

  writeProductToSaleID(String id) async {
    for (var element in selectedProductsList) {
      final ProductModel product = element['product'];
      await FirebaseFirestore.instance.collection('sales').doc(id).collection('products').add({
        'brand': product.brandName,
        'category': product.category,
        'cost': product.cost,
        'gramm': product.gramm,
        'image': product.image,
        'date': product.date,
        'location': product.location,
        'material': product.material,
        'name': product.name,
        'note': product.note,
        'package': product.package,
        'quantity': element['count'],
        'sell_price': product.sellPrice,
      });
    }
  }

  findClientOrAddNewOne({required List<TextEditingController> textControllers, required String sumPrice}) {
    FirebaseFirestore.instance.collection('clients').get().then((value) async {
      bool valueAddClient = false;
      for (var element in value.docs) {
        if (element['number'] == textControllers[2].text) {
          valueAddClient = true;
          double sumClientPrice = double.parse(element['sum_price'].toString()) + double.parse(sumPrice.toString());
          element.reference.update({'sum_price': sumClientPrice, 'order_count': element['order_count'] + 1, 'name': textControllers[3].text});
        }
      }
      if (valueAddClient == false) {
        FirebaseFirestore.instance.collection('clients').add({
          'address': textControllers[4].text,
          'name': textControllers[3].text,
          'number': textControllers[2].text,
          'sum_price': sumPrice.toString(),
          'order_count': 1,
          'date': textControllers[0].text,
        });
      }
    });
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
      if (!value) {
        selectedProductsList.add({'product': product, 'count': count});
      }
    }
    selectedProductsList.refresh();
  }
}
