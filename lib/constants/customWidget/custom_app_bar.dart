// ignore_for_file: prefer_const_constructors, file_names, use_key_in_widget_constructors, avoid_implementing_value_types

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSize {
  final bool backArrow;
  final bool? centerTitle;
  final bool? miniTitle;
  final Widget? icon;
  final bool actionIcon;
  final String name;

  const CustomAppBar({required this.backArrow, required this.actionIcon, required this.name, this.icon, this.centerTitle, super.key, this.miniTitle});

  @override
  Widget get child => Text('ad');

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Padding(
            padding: context.padding.horizontalNormal,
            child: Divider(
              color: kPrimaryColor2.withOpacity(.5),
            ),
          )),
      scrolledUnderElevation: 0.0,
      centerTitle: centerTitle,
      leadingWidth: centerTitle == true ? 40.0 : 0.0,
      leading: backArrow
          ? IconButton(
              color: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(
                IconlyLight.arrowLeftCircle,
                color: Colors.black,
                size: 22,
              ),
              onPressed: () {
                print("Asdasd");
                Get.back();
              },
            )
          : SizedBox.shrink(),
      actions: [if (actionIcon) Padding(padding: const EdgeInsets.only(right: 5), child: icon) else SizedBox.shrink()],
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: Text(
        name.tr,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: miniTitle == true ? context.general.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold) : context.general.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
