// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/constants/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  final String labelName;
  final int? maxline;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode requestfocusNode;
  final bool isNumber;
  final bool unFocus;
  final bool? borderRadius;
  final bool? isLabel;
  final bool? readOnly;

  const CustomTextField({
    required this.labelName,
    required this.controller,
    required this.focusNode,
    required this.requestfocusNode,
    required this.isNumber,
    required this.unFocus,
    this.isLabel = false,
    this.maxline,
    this.borderRadius,
    super.key,
    required this.readOnly,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20.h),
      child: TextFormField(
        style: const TextStyle(color: Colors.black, fontFamily: gilroyMedium),
        cursorColor: Colors.black,
        controller: controller,
        validator: (value) {
          if (value!.isEmpty) {
            return 'errorEmpty'.tr;
          }
          return null;
        },
        onEditingComplete: () {
          unFocus ? FocusScope.of(context).unfocus() : requestfocusNode.requestFocus();
        },
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxline ?? 1,
        focusNode: focusNode,
        enabled: readOnly,
        decoration: InputDecoration(
          errorMaxLines: 2,
          errorStyle: const TextStyle(fontFamily: gilroyMedium),
          hintMaxLines: 5,
          helperMaxLines: 5,
          hintText: isLabel! ? labelName.tr : '',
          hintStyle: TextStyle(color: Colors.grey.shade300, fontFamily: gilroyMedium),
          label: isLabel!
              ? null
              : Text(
                  labelName.tr,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade400, fontFamily: gilroyMedium),
                ),
          contentPadding: const EdgeInsets.only(left: 25, top: 20, bottom: 20, right: 10),
          border: OutlineInputBorder(
            borderRadius: borderRadius == null
                ? borderRadius5
                : borderRadius == false
                    ? borderRadius5
                    : borderRadius20,
            borderSide: const BorderSide(color: Colors.grey, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius == null
                ? borderRadius5
                : borderRadius == false
                    ? borderRadius5
                    : borderRadius20,
            borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius == null
                ? borderRadius5
                : borderRadius == false
                    ? borderRadius5
                    : borderRadius20,
            borderSide: const BorderSide(
              color: kPrimaryColor,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: borderRadius == null
                ? borderRadius5
                : borderRadius == false
                    ? borderRadius5
                    : borderRadius20,
            borderSide: const BorderSide(
              color: kPrimaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: borderRadius == null
                ? borderRadius5
                : borderRadius == false
                    ? borderRadius5
                    : borderRadius20,
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }
}
