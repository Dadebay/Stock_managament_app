import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController {
  RxInt stockInHand = 0.obs;
  RxBool loginView = false.obs;
  RxInt totalProductCount = 0.obs;
  GetStorage storage = GetStorage();
  updateLoginData() {
    loginView.value = true;
    storage.write('login', loginView.value);
  }

  setDataFalse() {
    loginView.value = false;
    storage.write('login', loginView.value);
  }

  @override
  void onInit() {
    super.onInit();
    collectionReference.get().then((value) {
      productsListHomeView = value.docs;
      stockInHand.value = 0;
      totalProductCount.value = value.docs.length;
      for (var element in value.docs) {
        stockInHand.value += int.parse(element['quantity'].toString());
      }
    });
  }

  CollectionReference collectionReference = FirebaseFirestore.instance.collection('products');
  List<QueryDocumentSnapshot<Object?>> productsListHomeView = [];
}
