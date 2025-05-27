import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/modules/sendSMS/controllers/client_model.dart';
import 'package:stock_managament_app/app/modules/sendSMS/controllers/clients_controller.dart';

class ClientCard extends StatelessWidget {
  ClientCard({
    required this.client,
    required this.count,
    required this.topTextColumnSize,
    super.key,
  });

  final ClientModel client;
  final int count;
  final List<Map<String, dynamic>> topTextColumnSize;

  final ClientsController clientsController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            padding: EdgeInsets.only(right: 10.w, top: 10.h),
            alignment: Alignment.center,
            child: Text(
              count.toString(),
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
                Text(
                  client.phone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w300, fontSize: 16.sp),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              client.sumPrice.toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w300, fontSize: 16.sp),
            ),
          ),
        ],
      ),
    );
  }
}
