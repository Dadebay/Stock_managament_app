import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
              // crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisSize: MainAxisSize.max,
              // mainAxisAlignment: MainAxisAlignment.center,
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
                    style: TextStyle(color: Colors.amber, fontFamily: gilroyBold, fontSize: 18.sp),
                  ),
                ),
                CustomTextField(
                  labelName: 'Username',
                  controller: textEditingController,
                  focusNode: focusNode,
                  requestfocusNode: focusNode1,
                  isNumber: false,
                  unFocus: false,
                  readOnly: false,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: CustomTextField(
                    labelName: 'Password',
                    controller: textEditingController1,
                    focusNode: focusNode1,
                    requestfocusNode: focusNode,
                    isNumber: false,
                    unFocus: false,
                    readOnly: false,
                  ),
                ),
                AgreeButton(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                    } else {
                      showSnackBar('Error', 'Please fill the blanks', Colors.red);
                    }
                    // await Auth().getFcmToken().then(
                    //   (value) {
                    //     ServersService().login(username: textEditingController.text, password: textEditingController1.text, fcm_token: value.toString()).then((value) {
                    //       if (value == 200) {
                    //         showSnackBar("Success", "You are succesfully logged in", Colors.green);
                    //         Get.to(() => const BottomNavBar());
                    //       } else {
                    //         textEditingController.clear();
                    //         textEditingController1.clear();
                    //         showSnackBar("Error", "Please rewrite your informations", Colors.red);
                    //       }
                    //     });
                    //   },
                    // );
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
