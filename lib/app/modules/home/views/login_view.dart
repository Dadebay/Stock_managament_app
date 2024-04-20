import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/modules/home/views/bottom_nav_bar.dart';
import 'package:stock_managament_app/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_app/constants/constants.dart';
import 'package:stock_managament_app/constants/custom_text_field.dart';
import 'package:stock_managament_app/constants/widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 30.h),
        alignment: Alignment.center,
        child: Center(
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              children: [
                Text(
                  'CREATE ACCOUNT',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.amber, fontFamily: gilroyBold, fontSize: 22.sp),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
                  child: Text(
                    'If you want to create an account, please contact the person from which you obtained this application',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 18.sp),
                  ),
                ),
                CustomTextField(
                  labelName: 'Username',
                  controller: textEditingController,
                  focusNode: focusNode,
                  requestfocusNode: focusNode1,
                  isNumber: false,
                  borderRadius: true,
                  unFocus: false,
                  readOnly: true,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: CustomTextField(
                    labelName: 'Password',
                    controller: textEditingController1,
                    focusNode: focusNode1,
                    requestfocusNode: focusNode,
                    isNumber: false,
                    borderRadius: true,
                    unFocus: false,
                    readOnly: true,
                  ),
                ),
                AgreeButton(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      bool valueLogin = false;
                      FirebaseFirestore.instance.collection('users').get().then((value) {
                        for (var element in value.docs) {
                          if (textEditingController.text.toLowerCase() == element['username'].toString().toLowerCase() &&
                              textEditingController1.text.toLowerCase() == element['password'].toString().toLowerCase()) {
                            if (element['active'] == false) {
                              FirebaseFirestore.instance.collection('users').doc(element.id).update({'active': true});
                              Get.find<HomeController>().updateLoginData();
                              Get.to(() => const BottomNavBar());
                              valueLogin = true;
                            } else {
                              showSnackBar('Error', 'Someone is using this login creadentials', Colors.red);
                            }
                          }
                        }
                        if (valueLogin == false) {
                          textEditingController.clear();
                          textEditingController1.clear();

                          showSnackBar('Error', 'Login details error please rewrite them', Colors.red);
                        }
                      });
                    } else {
                      showSnackBar('Error', 'Please fill the blanks', Colors.red);
                    }
                  },
                  text: "login",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
