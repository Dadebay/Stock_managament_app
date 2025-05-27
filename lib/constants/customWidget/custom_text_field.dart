// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';

class CustomTextField extends StatelessWidget {
  final String labelName;
  final int? maxline;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode requestfocusNode;
  final bool unFocus;
  final bool? readOnly;
  final bool? isNumber;
  final Function()? onTap;

  const CustomTextField({
    required this.labelName,
    required this.controller,
    required this.focusNode,
    required this.requestfocusNode,
    required this.unFocus,
    this.maxline,
    this.isNumber,
    super.key,
    required this.readOnly,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20.h),
      child: TextFormField(
        style: context.general.textTheme.bodyLarge!.copyWith(color: Colors.black, fontWeight: FontWeight.w500),
        cursorColor: Colors.black,
        onTap: onTap,
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) return 'textfield_error'.tr;
          return null;
        },
        onEditingComplete: () {
          unFocus ? FocusScope.of(context).unfocus() : requestfocusNode.requestFocus();
        },
        maxLines: maxline ?? 1,
        focusNode: focusNode,
        keyboardType: isNumber == true ? TextInputType.number : TextInputType.text,
        enabled: readOnly,
        inputFormatters: [
          LengthLimitingTextInputFormatter(labelName == 'clientNumber' ? 8 : 300),
        ],
        decoration: InputDecoration(
          errorMaxLines: 2,
          suffix: const SizedBox.shrink(),
          errorStyle: const TextStyle(fontFamily: gilroyMedium),
          hintMaxLines: 5,
          helperMaxLines: 5,
          hintStyle: TextStyle(color: Colors.grey.shade300, fontFamily: gilroyMedium),
          label: Text(
            labelName.tr,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: context.general.textTheme.bodyLarge!.copyWith(color: Colors.grey.shade500, fontWeight: FontWeight.w400),
          ),
          contentPadding: const EdgeInsets.only(left: 25, top: 20, bottom: 20, right: 10),
          border: const OutlineInputBorder(
            borderRadius: borderRadius20,
            borderSide: BorderSide(color: Colors.grey, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius20,
            borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: borderRadius20,
            borderSide: BorderSide(color: kPrimaryColor, width: 2),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: borderRadius20,
            borderSide: BorderSide(
              color: kPrimaryColor,
              width: 2,
            ),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: borderRadius20,
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }
}
