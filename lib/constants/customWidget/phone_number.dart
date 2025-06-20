// ignore_for_file: file_names, must_be_immutable, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';

class PhoneNumber extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode mineFocus;
  final FocusNode requestFocus;
  final bool style;
  final bool? disabled;
  final bool unFocus;
  const PhoneNumber({required this.mineFocus, required this.controller, this.onChanged, required this.requestFocus, required this.style, this.disabled, required this.unFocus});
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 15.h),
      child: TextFormField(
        enabled: disabled ?? true,
        style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
        cursorColor: Colors.black,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.number,
        focusNode: mineFocus,
        controller: controller,
        validator: (value) {
          if (value!.isEmpty) {
            return 'errorEmpty'.tr;
          } else if (value.length != 8) {
            return 'errorPhoneCount'.tr;
          }
          return null;
        },
        inputFormatters: [
          LengthLimitingTextInputFormatter(8),
        ],
        onEditingComplete: () {
          unFocus ? FocusScope.of(context).unfocus() : requestFocus.requestFocus();
        },
        onChanged: onChanged,
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          errorMaxLines: 2,
          errorStyle: const TextStyle(fontFamily: gilroyMedium),
          prefixIcon: Padding(
            padding: context.padding.onlyLeftNormal.copyWith(top: 0),
            child: Text(
              '+ 993',
              style: context.general.textTheme.titleLarge!.copyWith(color: Colors.grey.shade400, fontSize: 20),
            ),
          ),
          contentPadding: context.padding.normal,
          prefixIconConstraints: const BoxConstraints(minWidth: 80),
          isDense: true,
          hintText: '65 656565 ',
          filled: style,
          fillColor: kPrimaryColor,
          alignLabelWithHint: true,
          hintStyle: context.general.textTheme.titleLarge!.copyWith(color: Colors.grey.shade400, fontSize: 20),
          border: OutlineInputBorder(
            borderRadius: style ? borderRadius10 : borderRadius20,
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: style ? borderRadius10 : borderRadius20,
            borderSide: BorderSide(
              color: Colors.grey.shade200,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: style ? borderRadius10 : borderRadius20,
            borderSide: const BorderSide(
              color: kPrimaryColor,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: style ? borderRadius10 : borderRadius20,
            borderSide: const BorderSide(
              color: kPrimaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: style ? borderRadius10 : borderRadius20,
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }
}
