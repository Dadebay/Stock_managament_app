import 'package:get/get.dart';
import 'package:stock_managament_app/api_constants.dart';
import 'package:stock_managament_app/api_service.dart';
import 'package:stock_managament_app/app/modules/sendSMS/controllers/client_model.dart';
import 'package:stock_managament_app/app/modules/sendSMS/controllers/clients_controller.dart';

class ClientsService {
  final ClientsController clientsController = Get.find();

  Future<List<ClientModel>> getClients() async {
    print('\n🔍 [BACKEND] ===== Fetching Clients =====');
    final uri = Uri.parse(ApiConstants.clients);
    print('🔍 [BACKEND] URL: ${uri.toString()}');
    print('🔍 [BACKEND] Requires Token: true');

    final data = await ApiService().getRequest(uri.toString(), requiresToken: true);

    print('🔍 [BACKEND] Response received');
    print('🔍 [BACKEND] Data type: ${data.runtimeType}');
    print('🔍 [BACKEND] Data content: ${data?.toString().substring(0, data.toString().length > 200 ? 200 : data.toString().length)}...');

    if (data is Map && data['results'] != null) {
      final count = (data['results'] as List).length;
      print('✅ [BACKEND] Success: Found $count clients (Map with results)');
      return (data['results'] as List).map((item) => ClientModel.fromJson(item)).toList().reversed.toList();
    } else if (data is List) {
      final count = data.length;
      print('✅ [BACKEND] Success: Found $count clients (Direct list)');
      return (data).map((item) => ClientModel.fromJson(item)).toList().reversed.toList();
    } else {
      print('❌ [BACKEND] Error: No data or unexpected format');
      print('❌ [BACKEND] Expected Map or List, got: ${data.runtimeType}');
      return [];
    }
  }
}
