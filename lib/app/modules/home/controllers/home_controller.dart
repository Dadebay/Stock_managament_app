import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stock_managament_app/api_constants.dart';
import 'package:stock_managament_app/app/modules/auth/views/auth_service.dart';
import 'package:stock_managament_app/app/modules/home/controllers/search_model.dart';
import 'package:stock_managament_app/app/modules/home/controllers/search_service.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class HomeController extends GetxController {
  RxBool agreeButton = false.obs;
}

class SearchViewController extends GetxController {
  RxList<SearchModel> historyList = <SearchModel>[].obs;
  RxList<SearchModel> productsList = <SearchModel>[].obs;
  RxList<SearchModel> searchResult = <SearchModel>[].obs;
  RxList<Map<String, dynamic>> selectedProductsToOrder = <Map<String, dynamic>>[].obs;
  RxBool showInGrid = false.obs;
  RxBool isGridView = false.obs;
  RxInt sumCount = 0.obs;

  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }

  void sortProductsByDate() {
    productsList.sort((a, b) {
      // Check if both have dates
      final bool aHasDate = a.createdAT.isNotEmpty;
      final bool bHasDate = b.createdAT.isNotEmpty;

      // Products with dates come first
      if (aHasDate && !bHasDate) return -1;
      if (!aHasDate && bHasDate) return 1;

      // Both have dates - sort by most recent first
      if (aHasDate && bHasDate) {
        try {
          final dateA = DateTime.parse(a.createdAT);
          final dateB = DateTime.parse(b.createdAT);
          return dateB.compareTo(dateA); // Most recent first
        } catch (e) {
          return 0;
        }
      }

      // Neither has dates - keep original order
      return 0;
    });
    productsList.refresh();
  }

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

  Future<void> addNewProduct({
    required Map<String, String> productData,
    required Uint8List? selectedImageBytes,
    required String? selectedImageFileName,
  }) async {
    try {
      final HomeController homeController = Get.find();
      homeController.agreeButton.value = true;

      final SearchModel newProduct = await SearchService().createProductWithImage(
        fields: productData,
        imageBytes: selectedImageBytes, // Controller'daki byte'ları kullan
        imageFileName: selectedImageFileName, // Controller'daki dosya adını kullan
      );
      homeController.agreeButton.value = false;

      if (newProduct != null) {
        productsList.add(newProduct);
        clearSelectedImage(); // Seçilen resmi ve dosya adını temizle
        Get.back();
        showSnackBar("Başarılı", "Ürün başarıyla eklendi", Colors.green);
      } else {
        showSnackBar("Hata", "Ürün eklenemedi. Sunucudan veri dönmedi.", Colors.red);
      }
    } catch (e) {
      showSnackBar("Hata", "Ürün eklenemedi: $e", Colors.red);
    }
  }

  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? fileInfo = await picker.pickImage(
        source: source,
        imageQuality: 70, // Android için optimize edilmiş kalite
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (fileInfo != null) {
        final bytes = await fileInfo.readAsBytes();
        selectedImageBytes.value = bytes;
        selectedImageFileName.value = fileInfo.name;
        showSnackBar("Success", "Image selected: ${fileInfo.name}", Colors.green);
      }
    } catch (e) {
      showSnackBar("Error", "Could not pick image: $e", Colors.red);
    }
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

  void updateProductLocally(SearchModel updatedProduct) {
    final indexInProducts = productsList.indexWhere((item) => item.id == updatedProduct.id);
    if (indexInProducts != -1) {
      productsList[indexInProducts] = updatedProduct;
    }

    final indexInSearch = searchResult.indexWhere((item) => item.id == updatedProduct.id);
    if (indexInSearch != -1) {
      searchResult[indexInSearch] = updatedProduct;
    }

    calculateTotals();

    productsList.refresh();
    searchResult.refresh();
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
