import 'package:get/get.dart';
import 'package:stock_managament_app/api_constants.dart';
import 'package:stock_managament_app/api_service.dart';
import 'package:stock_managament_app/app/modules/sendSMS/controllers/client_model.dart';
import 'package:stock_managament_app/app/modules/sendSMS/controllers/clients_controller.dart';

class ClientsService {
  final ClientsController clientsController = Get.find();

  Future<List<ClientModel>> getClients() async {
    final uri = Uri.parse(ApiConstants.clients);
    final data = await ApiService().getRequest(uri.toString(), requiresToken: true);
    if (data is Map && data['results'] != null) {
      return (data['results'] as List).map((item) => ClientModel.fromJson(item)).toList().reversed.toList();
    } else if (data is List) {
      return (data).map((item) => ClientModel.fromJson(item)).toList().reversed.toList();
    } else {
      return [];
    }
  }
}
