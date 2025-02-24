import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 30.h),
        alignment: Alignment.center,
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            children: [
              Text(
                'login'.tr.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.amber, fontFamily: gilroyBold, fontSize: 22.sp),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
                child: Text(
                  'appObtained'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 18.sp),
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
                padding: EdgeInsets.symmetric(vertical: 20.h),
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
