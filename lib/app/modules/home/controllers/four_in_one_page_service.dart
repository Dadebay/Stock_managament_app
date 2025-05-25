import 'package:stock_managament_app/api_service.dart';
import 'package:stock_managament_app/app/modules/home/controllers/four_in_one_model.dart';

class FourInOnePageService {
  Future<List<FourInOneModel>> getData({required String url}) async {
    final data = await ApiService().getRequest(url, requiresToken: true);
    if (data is Map && data['results'] != null) {
      return (data['results'] as List).map((item) => FourInOneModel.fromJson(item)).toList().toList();
    } else if (data is List) {
      return (data).map((item) => FourInOneModel.fromJson(item)).toList().toList();
    } else {
      return [];
    }
  }
}
