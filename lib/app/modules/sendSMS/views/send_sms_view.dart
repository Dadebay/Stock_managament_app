import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stock_managament_app/app/modules/sendSMS/controllers/client_model.dart';
import 'package:stock_managament_app/app/modules/sendSMS/controllers/clients_controller.dart';
import 'package:stock_managament_app/app/modules/sendSMS/controllers/clients_service.dart';
import 'package:stock_managament_app/app/modules/sendSMS/views/client_card.dart';
import 'package:stock_managament_app/app/modules/sendSMS/views/search_widget.dart';
import 'package:stock_managament_app/app/product/constants/list_constants.dart';
import 'package:stock_managament_app/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/custom_text_field.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

import '../controllers/send_sms_controller.dart';

class SendSMSView extends StatefulWidget {
  const SendSMSView({super.key});

  @override
  State<SendSMSView> createState() => _SendSMSViewState();
}

class _SendSMSViewState extends State<SendSMSView> {
  final SendSMSController smsController = Get.put(SendSMSController());
  final ClientsController clientsController = Get.find();
  TextEditingController searchEditingController = TextEditingController();

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
      body: FutureBuilder<List<ClientModel>>(
        future: ClientsService().getClients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return spinKit();
          } else if (snapshot.hasError) {
            return errorData();
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return emptyData();
          }
          final clients = snapshot.data!;
          clientsController.clients.assignAll(clients);
          return Obx(() {
            final isSearching = searchEditingController.text.isNotEmpty;
            final hasResult = clientsController.searchResult.isNotEmpty;
            final displayList = (isSearching && hasResult) ? clientsController.searchResult.toList() : clientsController.clients.toList();

            return Column(
              children: [
                SearchWidget(
                  controller: searchEditingController,
                  onChanged: (value) => clientsController.onSearchTextChanged(value),
                  onClear: () {
                    searchEditingController.clear();
                    clientsController.searchResult.clear();
                  },
                ),
                Expanded(
                  child: (searchEditingController.text.isNotEmpty && clientsController.searchResult.isEmpty)
                      ? emptyData()
                      : ListView.builder(
                          padding: context.padding.onlyBottomHigh,
                          itemCount: displayList.length,
                          itemBuilder: (context, index) {
                            return ClientCard(
                              client: displayList[index],
                              count: (displayList.length - index),
                              topTextColumnSize: ListConstants.clientNames,
                            );
                          },
                        ),
                ),
              ],
            );
          });
        },
      ),
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
