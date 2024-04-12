import 'package:get/get.dart';

class SalesController extends GetxController {
  RxList selectedProductsList = [].obs;
  RxList productList = [].obs;
  addProduct(
      {required String name,
      required String brand,
      required String category,
      required String location,
      required String material,
      required String note,
      required String package,
      required int quantity,
      required int cost,
      required int gramm,
      required String image,
      required String price,
      required int count,
      required String id}) {
    productList.add({
      'id': id,
      'brand': brand,
      'category': category,
      'cost': cost,
      'gramm': gramm,
      'image': image,
      'location': location,
      'material': material,
      'name': name,
      'note': note,
      'package': package,
      'quantity': quantity,
      'sell_price': price,
      'count': count,
    });
  }

  upgradeCount(int id, int count) {
    for (var element in productList) {
      if (element['id'].toString() == id.toString()) {
        element['count'] = count.toString();
      }
    }
    productList.refresh();
  }

  addProductMain(
      {required String name,
      required String brand,
      required String category,
      required String location,
      required String material,
      required String note,
      required String package,
      required int quantity,
      required int cost,
      required int gramm,
      required String image,
      required String price,
      required int count,
      required String id}) {
    if (selectedProductsList.isEmpty) {
      selectedProductsList.add({
        'id': id,
        'brand': brand,
        'category': category,
        'cost': cost,
        'gramm': gramm,
        'image': image,
        'location': location,
        'material': material,
        'name': name,
        'note': note,
        'package': package,
        'quantity': quantity,
        'sell_price': price,
        'count': count,
      });
    } else {
      bool value = false;

      for (var element in selectedProductsList) {
        if (element['id'] == id) {
          element['count'] = count;
          value = true;
        }
      }
      if (!value) {
        selectedProductsList.add({
          'id': id,
          'brand': brand,
          'category': category,
          'cost': cost,
          'gramm': gramm,
          'image': image,
          'location': location,
          'material': material,
          'name': name,
          'note': note,
          'package': package,
          'quantity': quantity,
          'sell_price': price,
          'count': count,
        });
      }
    }
    selectedProductsList.refresh();
    print("[[[[[[[[object]]]]]]]]");
    print(selectedProductsList);
  }
}
