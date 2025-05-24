// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/modules/home/views/bottom_nav_bar.dart';
import 'package:stock_managament_app/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/custom_text_field.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  FocusNode focusNode = FocusNode();
  FocusNode focusNode1 = FocusNode();
  TextEditingController textEditingController = TextEditingController();
  TextEditingController textEditingController1 = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final HomeController _homeController = Get.put<HomeController>(HomeController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            padding: context.padding.horizontalNormal,
            children: [
              Text(
                'login'.tr.toUpperCase(),
                textAlign: TextAlign.center,
                style: context.general.textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold, color: kPrimaryColor2),
              ),
              Padding(
                padding: context.padding.verticalMedium,
                child: Text(
                  'appObtained'.tr,
                  textAlign: TextAlign.center,
                  style: context.general.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              CustomTextField(
                labelName: 'userName',
                controller: textEditingController,
                focusNode: focusNode,
                requestfocusNode: focusNode1,
                isNumber: false,
                unFocus: false,
                readOnly: true,
              ),
              Padding(
                padding: context.padding.verticalNormal,
                child: CustomTextField(
                  labelName: 'userpassword',
                  controller: textEditingController1,
                  focusNode: focusNode1,
                  requestfocusNode: focusNode,
                  isNumber: false,
                  unFocus: false,
                  readOnly: true,
                ),
              ),
              Center(
                child: AgreeButton(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      bool valueLogin = false;
                      FirebaseFirestore.instance.collection('users').get().then((value) {
                        for (var element in value.docs) {
                          if (textEditingController.text.toLowerCase() == element['username'].toString().toLowerCase() && textEditingController1.text.toLowerCase() == element['password'].toString().toLowerCase()) {
                            if (element['active'] == false) {
                              FirebaseFirestore.instance.collection('users').doc(element.id).update({'active': true});
                              FirebaseFirestore.instance.collection('users').doc(element.id).get().then((value) {
                                _homeController.updateLoginData(true, value['isAdmin']);
                              });
                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const BottomNavBar()));
                              valueLogin = true;
                              _homeController.agreeButton.value = !_homeController.agreeButton.value;
                            } else {
                              showSnackBar('errorTitle', 'loginError1', Colors.red);
                              _homeController.agreeButton.value = !_homeController.agreeButton.value;
                            }
                          }
                        }
                        if (valueLogin == false) {
                          textEditingController.clear();
                          textEditingController1.clear();
                          showSnackBar('errorTitle', 'signInDialog', Colors.red);
                          _homeController.agreeButton.value = !_homeController.agreeButton.value;
                        }
                      });
                    } else {
                      showSnackBar('errorTitle', 'loginErrorFillBlanks', Colors.red);
                    }
                  },
                  text: "login",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
