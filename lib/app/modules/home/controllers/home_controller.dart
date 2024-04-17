import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxInt stockInHand = 0.obs;
  RxInt totalProductCount = 0.obs;
  CollectionReference collectionReference = FirebaseFirestore.instance.collection('products');
  List<QueryDocumentSnapshot<Object?>> productsListHomeView = [];

  void updateStock(int quantity) {
    stockInHand.value += quantity;
  }
}
