// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:stock_managament_app/constants/customWidget/constants.dart';
// import 'package:stock_managament_app/constants/customWidget/widgets.dart';

// class HomeController extends GetxController {
//   final RxBool agreeButton = false.obs;
//   final CollectionReference collectionReference = FirebaseFirestore.instance.collection('products');
//   final RxString filteredName = "".obs;
//   final RxString filteredNameToSearch = "".obs;
//   final RxBool isFiltered = false.obs;
//   final RxBool loadingData = false.obs;
//   final RxBool loginView = false.obs;
//   final RxList<QueryDocumentSnapshot<Object?>> productsListHomeView = <QueryDocumentSnapshot<Object?>>[].obs;
//   final RxInt stockInHand = 0.obs;
//   final GetStorage storage = GetStorage();
//   final RxInt totalProductCount = 0.obs;
//   DocumentSnapshot? _lastDocument; // Son getirilen dökümanı takip et

//   @override
//   void onInit() async {
//     super.onInit();
//     await getData();
//   }

//   /// İlk 20 ürünü yükle
//   Future<void> getData() async {
//     loadingData.value = true;
//     try {
//       QuerySnapshot snapshot = await collectionReference.orderBy("date", descending: true).limit(limit).get();

//       if (snapshot.docs.isNotEmpty) {
//         _lastDocument = snapshot.docs.last; // Son dökümanı sakla
//       }

//       productsListHomeView.assignAll(snapshot.docs);
//       stockInHand.value = snapshot.docs.fold(0, (sum, doc) => sum + int.parse(doc['quantity'].toString()));
//       totalProductCount.value = snapshot.docs.length;
//     } catch (e) {
//       showSnackBar("error", "failedToLoadData", Colors.red);
//     } finally {
//       loadingData.value = false;
//     }
//   }

//   Future<void> onRefreshController() async {
//     productsListHomeView.clear();
//     loadingData.value = true;
//     try {
//       final QuerySnapshot snapshot = await collectionReference.orderBy("date", descending: true).limit(limit).get();
//       productsListHomeView.assignAll(snapshot.docs);
//       isFiltered.value = false;
//     } catch (e) {
//       showSnackBar("error", "failedToRefreshData", Colors.red);
//     } finally {
//       loadingData.value = false;
//     }
//   }

//   Future<void> onLoadingController() async {
//     final int length = productsListHomeView.length;
//     loadingData.value = true;
//     try {
//       QuerySnapshot snapshot;
//       if (isFiltered.value) {
//         snapshot = await collectionReference.where(filteredName.value.toLowerCase(), isEqualTo: filteredNameToSearch.value.toLowerCase()).startAfterDocument(productsListHomeView.last).limit(limit).get();
//       } else {
//         snapshot = await collectionReference.orderBy("date", descending: true).startAfterDocument(productsListHomeView.last).limit(limit).get();
//       }
//       productsListHomeView.addAll(snapshot.docs);
//       if (length == productsListHomeView.length) {
//         showSnackBar("done", "endOFProduct", Colors.green);
//       }
//     } catch (e) {
//       showSnackBar("error", "failedToLoadMoreData", Colors.red);
//     } finally {
//       loadingData.value = false;
//     }
//   }

//   Future<void> filterProducts(String filterName, String filterSearchName) async {
//     filteredName.value = filterName;
//     filteredNameToSearch.value = filterSearchName;
//     productsListHomeView.clear();
//     loadingData.value = true;
//     try {
//       final QuerySnapshot snapshot = await collectionReference.where(filterName.toLowerCase(), isEqualTo: filterSearchName).get();
//       productsListHomeView.assignAll(snapshot.docs);
//       isFiltered.value = true;
//     } catch (e) {
//       showSnackBar("error", "failedToFilterData", Colors.red);
//     } finally {
//       loadingData.value = false;
//       Get.back();
//       Get.back();
//     }
//   }

//   void updateLoginData(bool loginValue, bool adminValue) {
//     loginView.value = true;
//     storage.write('login', loginValue);
//     storage.write('isAdmin', adminValue);
//   }

//   void setDataFalse() {
//     loginView.value = false;
//     storage.write('login', loginView.value);
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class HomeController extends GetxController {
  final RxBool loadingData = false.obs;
  final RxList<QueryDocumentSnapshot<Object?>> productsListHomeView = <QueryDocumentSnapshot<Object?>>[].obs;
  final CollectionReference collectionReference = FirebaseFirestore.instance.collection('products');
  final RxInt totalProductCount = 0.obs;
  final RxInt stockInHand = 0.obs;
  final RxBool isFiltered = false.obs;
  final RxString filteredName = "".obs;
  final RxString filteredNameToSearch = "".obs;
  final int _limit = 20; // Sayfa başına 20 ürün
  DocumentSnapshot? _lastDocument; // Son getirilen dokümanı sakla
  final RxBool loginView = false.obs;
  final GetStorage storage = GetStorage();
  final RxBool agreeButton = false.obs;
  @override
  void onInit() {
    super.onInit();
    getData(); // Başlangıçta veri çek
  }

  /// İlk 20 ürünü yükle (Filtreye göre)
  Future<void> getData() async {
    loadingData.value = true;
    productsListHomeView.clear(); // Önceki verileri temizle
    _lastDocument = null; // Sayfalamayı sıfırla

    try {
      Query query = collectionReference.orderBy("date", descending: true).limit(_limit);

      if (isFiltered.value) {
        query = query.where(filteredName.value, isEqualTo: filteredNameToSearch.value);
      }

      QuerySnapshot snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last; // Son dokümanı sakla
      }

      productsListHomeView.assignAll(snapshot.docs);
      stockInHand.value = snapshot.docs.fold(0, (sum, doc) => sum + int.parse(doc['quantity'].toString()));
      totalProductCount.value = snapshot.docs.length;
    } catch (e) {
      showSnackBar("error", "failedToLoadData", Colors.red);
    } finally {
      loadingData.value = false;
    }
  }

  /// Daha fazla veri yükle (Filtre + Sayfalama)
  Future<void> onLoadingController() async {
    if (_lastDocument == null) return; // Eğer daha fazla ürün yoksa çık

    loadingData.value = true;
    try {
      Query query = collectionReference.orderBy("date", descending: true).startAfterDocument(_lastDocument!).limit(_limit);

      if (isFiltered.value) {
        query = query.where(filteredName.value, isEqualTo: filteredNameToSearch.value);
      }

      QuerySnapshot snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last; // Yeni son dokümanı güncelle
      }

      productsListHomeView.addAll(snapshot.docs);
      if (snapshot.docs.isEmpty) {
        showSnackBar("done", "endOFProduct", Colors.green);
      }
    } catch (e) {
      showSnackBar("error", "failedToLoadMoreData", Colors.red);
    } finally {
      loadingData.value = false;
    }
  }

  void updateLoginData(bool loginValue, bool adminValue) {
    loginView.value = true;
    storage.write('login', loginValue);
    storage.write('isAdmin', adminValue);
  }

  /// Filtreleme yap ve baştan yükle
  Future<void> filterProducts(String filterName, String filterSearchName) async {
    filteredName.value = filterName;
    filteredNameToSearch.value = filterSearchName;
    isFiltered.value = true;
    await getData();
  }

  /// Filtreyi kaldır ve baştan yükle
  Future<void> clearFilter() async {
    isFiltered.value = false;
    filteredName.value = "";
    filteredNameToSearch.value = "";
    await getData();
  }

  /// Sayfayı yenile (Filtre göz önünde bulundurulmalı)
  Future<void> onRefreshController() async {
    productsListHomeView.clear();
    _lastDocument = null;
    await getData();
  }
}
