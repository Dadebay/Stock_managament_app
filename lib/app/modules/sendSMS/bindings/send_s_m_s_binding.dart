import 'package:get/get.dart';

import '../controllers/send_sms_controller.dart';

class SendSMSBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SendSMSController>(
      () => SendSMSController(),
    );
  }
}
