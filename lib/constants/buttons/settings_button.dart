// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';

class SettingButton extends StatelessWidget {
  final String name;
  final Function() onTap;
  final Widget icon;
  const SettingButton({
    required this.name,
    required this.onTap,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      minVerticalPadding: 23,
      title: Text(
        name.tr,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: context.general.textTheme.bodyLarge!.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      trailing: icon,
    );
  }
}
