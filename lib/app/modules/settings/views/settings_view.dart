import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:restart_app/restart_app.dart';
import 'package:stock_managament_app/constants/buttons/settings_button.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/custom_app_bar.dart';

import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(backArrow: true, centerTitle: true, actionIcon: false, name: "settings".tr),
        body: ListView(
          children: [
            SettingButton(
              name: Get.locale!.toLanguageTag() == 'tm'
                  ? 'Türkmen dili'
                  : Get.locale!.toLanguageTag() == 'ru'
                      ? 'Rus dili'
                      : 'Iňlis dili',
              onTap: () {
                changeLanguage();
              },
              icon: Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                child: ClipRRect(
                  borderRadius: borderRadius30,
                  child: Image.asset(
                    Get.locale!.toLanguageTag() == 'tm'
                        ? tmIcon
                        : Get.locale!.toLanguageTag() == 'ru'
                            ? ruIcon
                            : engIcon,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SettingButton(
              name: 'versia',
              onTap: () {},
              icon: const Text(
                '1.0.0',
                style: TextStyle(
                  color: kPrimaryColor2,
                  fontFamily: gilroyMedium,
                ),
              ),
            ),
          ],
        ));
  }
}

void changeLanguage() {
  final SettingsController settingsController = Get.put(SettingsController());
  Container dividerr() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: const Divider(
        color: backgroundColor,
        thickness: 2,
      ),
    );
  }

  ListTile button(String name, String icon, Function() onTap) {
    return ListTile(
      dense: true,
      minVerticalPadding: 0,
      onTap: onTap,
      leading: CircleAvatar(
        backgroundImage: AssetImage(
          icon,
        ),
        backgroundColor: Colors.black,
        radius: 20,
      ),
      title: Text(
        name,
        style: const TextStyle(color: Colors.black, fontFamily: gilroyMedium, fontSize: 18),
      ),
    );
  }

  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(color: Colors.white),
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.shrink(),
                Text(
                  'select_language'.tr,
                  style: const TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 20),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: const Icon(CupertinoIcons.xmark_circle, size: 22, color: Colors.black),
                )
              ],
            ),
          ),
          dividerr(),
          button('Türkmen', tmIcon, () async {
            settingsController.switchLang('tm');
            Get.back();
            // await Restart.restartApp();
          }),
          dividerr(),
          button('Русский', ruIcon, () async {
            settingsController.switchLang('ru');
            Get.back();
            // await Restart.restartApp();
          }),
          dividerr(),
          button('English', engIcon, () async {
            settingsController.switchLang('en');
            Get.back();
            // await Restart.restartApp();
          }),
        ],
      ),
    ),
  );
}
