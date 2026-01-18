import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stock_managament_app/app/modules/sendSMS/controllers/client_model.dart';

class ClientCard extends StatelessWidget {
  const ClientCard({
    required this.client,
    required this.index,
    super.key,
  });

  final ClientModel client;
  final String index;

  @override
  Widget build(BuildContext context) {
    final name = client.name.trim();
    final phone = client.phone.trim();
    final displayName = name.isEmpty ? 'Ady yok' : name;
    final displayPhone = phone.isEmpty ? 'Nomeri yok' : phone;
    final initials = name.isNotEmpty ? name.characters.first.toUpperCase() : '?';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade100,
            child: Text(
              index,
              style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: name.isEmpty ? Colors.grey : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  displayPhone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: phone.isEmpty ? Colors.grey : Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              client.sumPrice?.toString() ?? '0',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }
}
