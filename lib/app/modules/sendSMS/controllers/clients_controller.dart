import 'package:get/get.dart';
import 'package:stock_managament_app/app/modules/sendSMS/controllers/client_model.dart';

class ClientsController extends GetxController {
  RxList<ClientModel> clients = <ClientModel>[].obs;
  RxList<ClientModel> searchResult = <ClientModel>[].obs;
  RxInt currentPage = 1.obs;

  onSearchTextChanged(String word) {
    searchResult.clear();
    if (word.isEmpty) {
      update();
      return;
    }
    List<String> words = word.trim().toLowerCase().split(' ');
    searchResult.value = clients.where((client) {
      final name = client.name.toLowerCase();
      final phone = client.phone.toLowerCase();
      final address = client.address.toLowerCase();
      return words.every((word) => name.contains(word.toLowerCase()) || phone.contains(word.toLowerCase()) || address.contains(word.toLowerCase()));
    }).toList();
  }
}
