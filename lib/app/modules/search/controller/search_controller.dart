import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SearchViewController extends GetxController {
  RxList searchResult = [].obs;
  RxList productsList = [].obs;
  RxBool loadingData = false.obs;

  getClientStream(String whereToSearch) async {
    loadingData.value = true;
    if (productsList.isEmpty) {
      if (whereToSearch == 'orders') {
        await FirebaseFirestore.instance.collection('sales').orderBy('date', descending: true).get().then((value) {
          productsList.value = value.docs;
        });
      } else {
        await FirebaseFirestore.instance.collection('products').orderBy('date', descending: true).get().then((value) {
          productsList.value = value.docs;
        });
      }
    }
    loadingData.value = false;

    searchResult.clear();
  }

  onSearchTextChanged(String word, String whereToSearch) async {
    loadingData.value = true;
    searchResult.clear();
    List fullData = [];
    List<String> words = word.toLowerCase().trim().split(' ');
    fullData = productsList.where((p) {
      bool result = true;
      for (final word in words) {
        if (whereToSearch == 'orders' ? !p['client_number'].toLowerCase().contains(word) : !p['name'].toLowerCase().contains(word)) {
          result = false;
        }
      }
      return result;
    }).toList();
    searchResult.value = fullData.toSet().toList();
    print(searchResult);
    loadingData.value = false;
  }
}
