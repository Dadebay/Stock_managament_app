import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stock_managament_app/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/custom_text_field.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

import '../controllers/send_sms_controller.dart';

class Client {
  String name;
  final String number;
  final String address;
  final String date;
  int orderCount;
  double sumPrice;

  Client({
    required this.address,
    required this.date,
    required this.orderCount,
    required this.name,
    required this.number,
    required this.sumPrice,
  });
}

class SendSMSView extends StatefulWidget {
  const SendSMSView({super.key});

  @override
  State<SendSMSView> createState() => _SendSMSViewState();
}

class _SendSMSViewState extends State<SendSMSView> {
  final SendSMSController smsController = Get.put(SendSMSController());
  @override
  void initState() {
    super.initState();
    smsController.getAllClients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: kPrimaryColor2,
          onPressed: () {
            sendMessage();
          },
          child: const Icon(
            IconlyLight.send,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.white,
        body: Obx(() {
          return smsController.loadData.value
              ? spinKit()
              : smsController.clients.isEmpty
                  ? emptyData()
                  : mineBody();
        }));
  }

  Widget mineBody() {
    return ListView.separated(
      itemBuilder: (context, index) {
        Client clinet = Client(
            date: smsController.clients[index]['date'],
            address: smsController.clients[index]['address'],
            orderCount: int.parse(smsController.clients[index]['order_count'].toString()),
            name: smsController.clients[index]['name'],
            number: smsController.clients[index]['number'],
            sumPrice: double.parse(smsController.clients[index]['sum_price'].toString()));
        return Row(children: [
          Expanded(
            flex: 1,
            child: Text(
              "${index + 1} - ",
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 16.sp),
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      clinet.name,
                      maxLines: 1,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      clinet.number,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.black, fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            ),
          )
        ]);
      },
      separatorBuilder: (context, index) {
        return const Divider(
          height: 5,
          thickness: 1,
        );
      },
      itemCount: smsController.clients.length,
    );
  }

  int sumSms = 0;

  Future<void> smsFunction({required String message, required String number}) async {
    SmsStatus res = await BackgroundSms.sendMessage(phoneNumber: number, message: message);
    if (res == SmsStatus.sent) {
      sumSms++;
      setState(() {});
    }
  }

  Future<dynamic> sendMessage() {
    TextEditingController nameEditingController = TextEditingController();
    TextEditingController numberSendSMS = TextEditingController();
    FocusNode focusNode = FocusNode();
    FocusNode focusNode1 = FocusNode();

    return Get.defaultDialog(
        title: 'Send message',
        titlePadding: const EdgeInsets.only(top: 20),
        titleStyle: TextStyle(color: Colors.black, fontSize: 20.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
        content: SizedBox(
          width: Get.size.width / 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(labelName: 'Number', maxline: 1, controller: numberSendSMS, focusNode: focusNode1, requestfocusNode: focusNode, unFocus: true, readOnly: true),
              CustomTextField(labelName: 'Title', maxline: 3, controller: nameEditingController, focusNode: focusNode, requestfocusNode: focusNode1, unFocus: true, readOnly: true),
              AgreeButton(
                  onTap: () async {
                    sumSms = 0;
                    if (await Permission.sms.isGranted) {
                      if (numberSendSMS.text.isEmpty) {
                        for (var element in smsController.clients) {
                          smsFunction(message: nameEditingController.text, number: "+993${element['number']}");
                        }
                        if (sumSms == smsController.clients.length) {
                          showSnackBar("Done", "SmsSend", Colors.green);
                        } else {
                          showSnackBar("Error", "Cannot Send SMS all clients", Colors.red);
                        }
                      } else {
                        smsFunction(message: nameEditingController.text, number: numberSendSMS.text);
                      }
                    } else {
                      final status = await Permission.sms.request();
                      if (status.isGranted) {
                        smsFunction(message: nameEditingController.text, number: numberSendSMS.text);
                      }
                    }
                  },
                  text: "Send".tr)
            ],
          ),
        ));
  }
}
