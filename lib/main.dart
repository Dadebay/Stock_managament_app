import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stock_managament_app/app/modules/auth/views/connection_check_view.dart';
import 'package:stock_managament_app/app/utils.dart';

import 'constants/customWidget/constants.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = GetStorage();

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
              theme: ThemeData(
                brightness: Brightness.light,
                fontFamily: gilroyRegular,
                colorSchemeSeed: kPrimaryColor,
                useMaterial3: true,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarBrightness: Brightness.light, statusBarIconBrightness: Brightness.dark),
                  titleTextStyle: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 20),
                  elevation: 0,
                ),
                bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.transparent.withOpacity(0)),
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              fallbackLocale: const Locale('tm'),
              locale: storage.read('langCode') != null ? Locale(storage.read('langCode')) : const Locale('tm'),
              translations: MyTranslations(),
              defaultTransition: Transition.fade,
              home: const ConnectionCheckView()
              // home: const ConnectionCheckView(),
              );
        });
  }
}
