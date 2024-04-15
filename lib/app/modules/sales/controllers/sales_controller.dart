import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';

class SalesController extends GetxController {
  RxList selectedProductsList = [].obs;
  RxList productList = [].obs;
  addProduct({required ProductModel product, required int count}) {
    productList.add({'product': product, 'count': count});
  }

  upgradeCount(int id, int count) {
    for (var element in productList) {
      final ProductModel product = element['product'];
      if (product.documentID.toString() == id.toString()) {
        element['count'] = count.toString();
      }
    }

    productList.refresh();
  }

  addProductMain({required int count, required ProductModel product}) {
    if (selectedProductsList.isEmpty) {
      selectedProductsList.add({'product': product, 'count': count});
    } else {
      bool value = false;

      for (var element in selectedProductsList) {
        final ProductModel productMine = element['product'];
        if (product.documentID.toString() == productMine.documentID) {
          element['count'] = count;
          value = true;
        }
      }
      if (!value) {
        selectedProductsList.add({'product': product, 'count': count});
      }
    }
    print(selectedProductsList);
    selectedProductsList.refresh();
  }
}
