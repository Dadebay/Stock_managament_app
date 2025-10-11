import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:stock_managament_app/app/modules/home/controllers/search_model.dart';
import 'package:stock_managament_app/app/modules/home/controllers/search_service.dart';

class HomeController extends GetxController {
  RxBool agreeButton = false.obs;
}

class SearchViewController extends GetxController {
  RxList<SearchModel> historyList = <SearchModel>[].obs;
  RxList<SearchModel> productsList = <SearchModel>[].obs;
  RxList<SearchModel> searchResult = <SearchModel>[].obs;
  RxList<Map<String, dynamic>> selectedProductsToOrder = <Map<String, dynamic>>[].obs;
  RxBool showInGrid = false.obs;
  RxInt sumCount = 0.obs;
  void addOrUpdateProduct({required SearchModel product, required int count}) {
    final index = selectedProductsToOrder.indexWhere(
      (element) => element['product'].id.toString() == product.id.toString(),
    );
    if (index != -1) {
      selectedProductsToOrder[index]['count'] = count;
    } else {
      selectedProductsToOrder.add({'product': product, 'count': count});
    }
    selectedProductsToOrder.refresh();
  }

  void decreaseCount(String id, int count) {
    for (int i = 0; i < selectedProductsToOrder.length; i++) {
      final product = selectedProductsToOrder[i]['product'];
      if (product.id.toString() == id) {
        if (count <= 0) {
          selectedProductsToOrder.removeAt(i);
        } else {
          selectedProductsToOrder[i]['count'] = count;
        }
        break;
      }
    }
    selectedProductsToOrder.refresh();
  }

  int getProductCount(String id) {
    for (var element in selectedProductsToOrder) {
      final SearchModel product = element['product'];
      if (product.id.toString() == id) {
        return element['count'] ?? 0;
      }
    }
    return 0;
  }

  String _activeFilterType = '';
  String _activeFilterValue = '';
  final String _currentSearchText = '';

  void applyFilter(String filterType, String filterValue) {
    _activeFilterType = filterType;
    _activeFilterValue = filterValue;
    if (_currentSearchText.isEmpty) {
      searchResult.assignAll(productsList);
    }
    _filterAndSearchProducts();
  }

  Rx<String?> selectedImageFileName = Rx<String?>(null);
  Rx<Uint8List?> selectedImageBytes = Rx<Uint8List?>(null);
  void clearSelectedImage() {
    selectedImageBytes.value = null;
    selectedImageFileName.value = null;
  }

  dynamic onRefreshController() async {
    productsList.clear();
    final List<SearchModel> list = await SearchService().getProducts();
    historyList.assignAll(list);
    productsList.assignAll(list);
    calculateTotals();
    update();
  }

  void clearFilter() {
    _activeFilterType = '';
    _activeFilterValue = '';
    productsList.assignAll(historyList);
    Get.back();
  }

  void onSearchTextChanged(String word) {
    searchResult.clear();
    if (word.isEmpty) {
      searchResult.assignAll(productsList);
      update();
      return;
    }
    List<String> words = word.trim().toLowerCase().split(' ');
    searchResult.value = productsList.where((product) {
      final name = product.name.toLowerCase();
      final price = product.price.toLowerCase();

      return words.every((w) => name.contains(w) || price.contains(w));
    }).toList();
    update();
  }

  void updateProductLocally(int id, SearchModel model) {
    print("Den geldi--------------------------------------------- $id");

    for (var item in productsList) {
      if (item.id.toString() == id.toString()) {
        print("Den geldi--------------------------------------------- ");
        productsList[productsList.indexOf(item)] = model;
      }
    }
    calculateTotals();
    productsList.refresh();
    update();
  }

  void calculateTotals() {
    int totalCount = 0;
    sumCount.value = 0;
    for (var product in productsList) {
      final int count = product.count ?? 0;
      totalCount += count;
    }
    sumCount.value = totalCount;
  }

  void deleteProduct(int id) {
    productsList.removeWhere((product) => product.id == id);
    searchResult.removeWhere((product) => product.id == id);
    calculateTotals();
    update();
  }

  void _filterAndSearchProducts() {
    List<SearchModel> GeciciListe = productsList.toList();
    productsList.clear();
    if (_activeFilterType.isNotEmpty && _activeFilterValue.isNotEmpty) {
      GeciciListe = GeciciListe.where((product) {
        switch (_activeFilterType) {
          case 'category':
            return product.category?.name.toLowerCase() == _activeFilterValue.toLowerCase();
          case 'brends':
            return product.brend?.name.toLowerCase() == _activeFilterValue.toLowerCase();
          case 'location':
            return product.location?.name.toLowerCase() == _activeFilterValue.toLowerCase();
          case 'material':
            return product.material?.name.toLowerCase() == _activeFilterValue.toLowerCase();
          default:
            return true;
        }
      }).toList();
    }
    if (_currentSearchText.isNotEmpty) {
      List<String> words = _currentSearchText.trim().toLowerCase().split(' ');
      GeciciListe = GeciciListe.where((product) {
        final name = product.name.toLowerCase();
        final price = product.price.toLowerCase();
        return words.every((w) => name.contains(w) || price.contains(w));
      }).toList();
    }
    productsList.assignAll(GeciciListe);
  }
}
