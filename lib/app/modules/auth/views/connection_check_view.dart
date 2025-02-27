// ignore_for_file: file_names, always_use_package_imports

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stock_managament_app/app/modules/auth/views/login_view.dart';
import 'package:stock_managament_app/app/modules/home/views/bottom_nav_bar.dart';
import 'package:stock_managament_app/app/product/sizes/widget_sizes.dart';
import 'package:stock_managament_app/app/product/utils/dialog_utils.dart';

class ConnectionCheckView extends StatefulWidget {
  const ConnectionCheckView({super.key});

  @override
  _ConnectionCheckViewState createState() => _ConnectionCheckViewState();
}

class _ConnectionCheckViewState extends State<ConnectionCheckView> {
  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  GetStorage storage = GetStorage();

  void checkConnection() async {
    bool loginValue = storage.read('login') ?? false;
    print(loginValue);
    print(loginValue);
    print(loginValue);
    print(loginValue);
    print(loginValue);
    log("message________________________________________________________________");
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
