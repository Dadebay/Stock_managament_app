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

  String _activeFilterType = '';
  String _activeFilterValue = '';
  final String _currentSearchText = '';

  void applyFilter(String filterType, String filterValue) {
    print(filterType);
    print(filterValue);
    _activeFilterType = filterType;
    _activeFilterValue = filterValue;
    print(_activeFilterType);
    print(_activeFilterValue);

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

  void onSearchTextChanged(String word) {
    print(word);
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

  void updateProductLocally(SearchModel updatedProduct) {
    print("updateProductLocally çağrıldı. Gelen ürün ID: ${updatedProduct.id}, Yeni img: ${updatedProduct.img}");

    final indexInProducts = productsList.indexWhere((item) => item.id == updatedProduct.id);
    if (indexInProducts != -1) {
      print("productsList içinde bulundu, güncelleniyor. Eski img: ${productsList[indexInProducts].img}");
      productsList[indexInProducts] = updatedProduct;
    } else {
      print("productsList içinde ürün bulunamadı: ${updatedProduct.id}");
    }

    final indexInSearch = searchResult.indexWhere((item) => item.id == updatedProduct.id);
    if (indexInSearch != -1) {
      print("searchResult içinde bulundu, güncelleniyor. Eski img: ${searchResult[indexInSearch].img}");
      searchResult[indexInSearch] = updatedProduct;
    } else {
      print("searchResult içinde ürün bulunamadı: ${updatedProduct.id}");
    }

    calculateTotals();

    productsList.refresh();
    searchResult.refresh();
    update();

    print("Güncelleme sonrası productsList[$indexInProducts].img: ${productsList.firstWhereOrNull((p) => p.id == updatedProduct.id)?.img}");
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
    print(GeciciListe.length);
    print(_activeFilterType);
    print(_activeFilterValue);
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
    print(productsList.length);
    print(GeciciListe.length);
    productsList.assignAll(GeciciListe);
  }
}
