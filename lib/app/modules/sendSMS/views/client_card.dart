import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stock_managament_app/app/modules/sendSMS/controllers/client_model.dart';
import 'package:stock_managament_app/app/modules/sendSMS/models/sms_send_status.dart';

class ClientCard extends StatelessWidget {
  const ClientCard({
    required this.client,
    required this.index,
    this.sendStatus,
    this.isSelected = false,
    super.key,
  });

  final ClientModel client;
  final String index;
  final SmsSendStatus? sendStatus;
  final bool isSelected;

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
        border: isSelected ? Border.all(color: Colors.green, width: 1.2) : null,
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
            backgroundColor: isSelected ? Colors.green.shade50 : Colors.grey.shade100,
            child: Text(
              index,
              style: TextStyle(color: isSelected ? Colors.green : Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 16.sp),
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
          if (sendStatus != null)
            Container(
              margin: EdgeInsets.only(right: 6.w),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _statusColor(sendStatus!).withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    _statusIcon(sendStatus!),
                    color: _statusColor(sendStatus!),
                    size: 14.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _statusLabel(sendStatus!),
                    style: TextStyle(color: _statusColor(sendStatus!), fontWeight: FontWeight.w600, fontSize: 11.sp),
                  ),
                ],
              ),
            ),
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

  Color _statusColor(SmsSendStatus status) {
    switch (status) {
      case SmsSendStatus.sending:
        return Colors.orange;
      case SmsSendStatus.sent:
        return Colors.green;
      case SmsSendStatus.failed:
        return Colors.red;
      case SmsSendStatus.idle:
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(SmsSendStatus status) {
    switch (status) {
      case SmsSendStatus.sending:
        return Icons.hourglass_top;
      case SmsSendStatus.sent:
        return Icons.check_circle;
      case SmsSendStatus.failed:
        return Icons.error;
      case SmsSendStatus.idle:
      default:
        return Icons.more_horiz;
    }
  }

  String _statusLabel(SmsSendStatus status) {
    switch (status) {
      case SmsSendStatus.sending:
        return 'Gidiyor';
      case SmsSendStatus.sent:
        return 'Gitdi';
      case SmsSendStatus.failed:
        return 'Gitmedi';
      case SmsSendStatus.idle:
      default:
        return 'Hazir';
    }
  }
}
