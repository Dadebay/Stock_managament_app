// ignore_for_file: file_names, always_use_package_imports, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/modules/auth/views/auth_service.dart';
import 'package:stock_managament_app/app/modules/auth/views/login_view.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/modules/home/views/bottom_nav_bar.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/order_controller.dart';
import 'package:stock_managament_app/app/modules/sendSMS/controllers/clients_controller.dart';
import 'package:stock_managament_app/app/modules/settings/controllers/settings_controller.dart';
import 'package:stock_managament_app/app/product/sizes/widget_sizes.dart';
import 'package:stock_managament_app/app/product/utils/dialog_utils.dart';

class ConnectionCheckView extends StatefulWidget {
  const ConnectionCheckView({super.key});

  @override
  _ConnectionCheckViewState createState() => _ConnectionCheckViewState();
}

class _ConnectionCheckViewState extends State<ConnectionCheckView> {
  final SearchViewController _searchViewController = Get.put(SearchViewController());
  final HomeController homeController = Get.put<HomeController>(HomeController());
  final OrderController orderController = Get.put<OrderController>(OrderController());
  final SettingsController settingsController = Get.put(SettingsController());
  final ClientsController clientsController = Get.put(ClientsController());

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  void checkConnection() async {
    bool loginValue = await AuthStorage().getToken() == null ? false : true;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
        await Future.delayed(const Duration(seconds: 3), () {
          return Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => loginValue ? const BottomNavBar() : const SignUpView()), (route) => false);
        });
      }
    } on SocketException catch (_) {
      DialogUtils.showNoConnectionDialog(onRetry: () {}, context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: FlutterLogo(
                size: WidgetSizes.high2x.value,
              ),
            ),
          ),
          const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
