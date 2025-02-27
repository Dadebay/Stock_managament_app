import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stock_managament_app/app/modules/auth/views/connection_check_view.dart';
import 'package:stock_managament_app/app/product/initialize/app_start_init.dart';
import 'package:stock_managament_app/app/product/theme/theme_contants.dart';
import 'package:stock_managament_app/app/utils.dart';

import 'app/modules/home/controllers/home_controller.dart';
import 'constants/customWidget/constants.dart';

Future<void> main() async {
  await AppStartInit.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = GetStorage();
  final HomeController _homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: appName,
            theme: AppThemes.lightTheme,
            fallbackLocale: const Locale('tm'),
            locale: storage.read('langCode') != null ? Locale(storage.read('langCode')) : const Locale('tm'),
            translations: MyTranslations(),
            defaultTransition: Transition.fade,
            home: const ConnectionCheckView(),
          );
        });
  }
}
