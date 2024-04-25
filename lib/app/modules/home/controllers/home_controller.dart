import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class HomeController extends GetxController {
  RxBool agreeButton = false.obs;
  CollectionReference collectionReference = FirebaseFirestore.instance.collection('products');
  RxString filteredName = "".obs;
  RxString filteredNameToSearch = "".obs;
  RxBool isFiltered = false.obs;
  RxBool loadingData = false.obs;
  RxBool loginView = false.obs;
  List<QueryDocumentSnapshot<Object?>> productsListHomeView = [];
  RxInt stockInHand = 0.obs;
  GetStorage storage = GetStorage();
  RxInt totalProductCount = 0.obs;

  @override
  void onInit() async {
    super.onInit();
    getData();
  }

  getData() {
    loadingData.value = true;

    collectionReference.get().then((value) {
      productsListHomeView = value.docs;
      stockInHand.value = 0;
      totalProductCount.value = value.docs.length;
      for (var element in value.docs) {
        stockInHand.value += int.parse(element['quantity'].toString());
      }
    });
    loadingData.value = false;
  }

  Future<void> onRefreshController() async {
    productsListHomeView.clear();
    loadingData.value = true;
    await FirebaseFirestore.instance.collection('products').orderBy("date", descending: true).limit(limit).get().then((value) {
      productsListHomeView = value.docs;
    });
    isFiltered.value = false;
    loadingData.value = false;
  }

  Future<void> onLoadingController() async {
    int length = productsListHomeView.length;
    loadingData.value = true;

    if (isFiltered.value == true) {
      collectionReference.where(filteredName.value.toLowerCase(), isEqualTo: filteredNameToSearch.value.toLowerCase()).startAfterDocument(productsListHomeView.last).limit(limit).get().then((value) {
        productsListHomeView.addAll(value.docs);
        if (length == productsListHomeView.length) {
          showSnackBar("done", "endOFProduct", Colors.green);
        }
      });
    } else {
      collectionReference.orderBy("date", descending: true).startAfterDocument(productsListHomeView.last).limit(limit).get().then((value) {
        productsListHomeView.addAll(value.docs);
        if (length == productsListHomeView.length) {
          showSnackBar("done", "endOFProduct", Colors.green);
        }
      });
    }
    loadingData.value = false;
  }

  filterProducts(String filterName, String filterSearchName) {
    filteredName.value = filterName;
    filteredNameToSearch.value = filterSearchName;
    productsListHomeView.clear();
    loadingData.value = true;

    FirebaseFirestore.instance.collection('products').where(filterName.toLowerCase(), isEqualTo: filterSearchName).get().then((value) {
      if (value.docs.isEmpty) {
        productsListHomeView.clear();
      } else {
        productsListHomeView.addAll(value.docs);
      }
      Get.back();
      Get.back();
      loadingData.value = false;
      isFiltered.value = true;
    });
  }

  updateLoginData() {
    loginView.value = true;
    storage.write('login', loginView.value);
  }

  setDataFalse() {
    loginView.value = false;
    storage.write('login', loginView.value);
  }
}
