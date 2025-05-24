import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class HomeController extends GetxController {
  RxBool agreeButton = false.obs;
  Query<Map<String, dynamic>> collectionReference = FirebaseFirestore.instance.collection('products').orderBy("date", descending: true);
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

  getData() async {
    loadingData.value = true;
    try {
      final QuerySnapshot snapshot = await collectionReference.get();
      productsListHomeView.assignAll(snapshot.docs);
      stockInHand.value = 0;
      totalProductCount.value = snapshot.docs.length;
      for (var element in snapshot.docs) {
        stockInHand.value += int.parse(element['quantity'].toString());
      }
    } catch (e) {
      showSnackBar("error", "failed to get data ", Colors.red);
    }
    loadingData.value = false;
  }

  Future<void> onRefreshController() async {
    productsListHomeView.clear();

    stockInHand.value = 0;
    totalProductCount.value = 0;
    getData();
    isFiltered.value = false;
  }

  Future<void> onLoadingController() async {
    loadingData.value = true;
    if (isFiltered.value == true) {
      try {
        final QuerySnapshot snapshot = await collectionReference.where(filteredName.value.toLowerCase(), isEqualTo: filteredNameToSearch.value.toLowerCase()).startAfterDocument(productsListHomeView.last).limit(limit).get();
        productsListHomeView.addAll(snapshot.docs);
        if (totalProductCount.value == productsListHomeView.length) {
          showSnackBar("done", "endOFProduct", Colors.green);
        }
      } catch (e) {
        showSnackBar("error", "loading error", Colors.red);
      }
    } else {
      try {
        final QuerySnapshot snapshot = await collectionReference.orderBy("date", descending: true).startAfterDocument(productsListHomeView.last).limit(limit).get();
        productsListHomeView.assignAll(snapshot.docs);
        if (totalProductCount.value == productsListHomeView.length) {
          showSnackBar("done", "endOFProduct", Colors.green);
        }
      } catch (e) {
        showSnackBar("error", "loading error", Colors.red);
      }
    }
    loadingData.value = false;
  }

  filterProducts(String filterName, String filterSearchName) async {
    filteredName.value = filterName;
    filteredNameToSearch.value = filterSearchName;
    productsListHomeView.clear();
    loadingData.value = true;

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('products').where(filterName.toLowerCase(), isEqualTo: filterSearchName).get();

      productsListHomeView.assignAll(snapshot.docs);
      isFiltered.value = true;
    } catch (e) {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      showSnackBar("error", "failedToFilterData", Colors.red);
    } finally {
      loadingData.value = false;

      Get.back();
      Get.back();
    }
  }

  updateLoginData(bool loginValue, bool adminValue) {
    loginView.value = true;
    storage.write('login', loginValue);
    storage.write('isAdmin', adminValue);
  }

  setDataFalse() {
    loginView.value = false;
    storage.write('login', loginView.value);
  }
}
