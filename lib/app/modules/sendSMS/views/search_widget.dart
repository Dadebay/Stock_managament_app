import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({super.key, this.onChanged, this.onClear, required this.controller});
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.padding.low,
      child: Card(
        child: ListTile(
          leading: const Icon(
            IconlyLight.search,
            color: Colors.black,
          ),
          title: TextField(controller: controller, style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w600), decoration: InputDecoration(hintText: 'search'.tr, hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp), border: InputBorder.none), onChanged: onChanged),
          contentPadding: EdgeInsets.only(left: 15.w),
          trailing: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
                icon: Icon(
                  CupertinoIcons.xmark_circle,
                  color: Colors.grey.shade200,
                ),
                onPressed: onClear),
          ),
        ),
      ),
    );
  }
}
