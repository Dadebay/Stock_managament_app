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
import 'package:stock_managament_app/app/modules/sendSMS/models/sms_send_status.dart';
import 'package:stock_managament_app/app/modules/sendSMS/views/client_card.dart';
import 'package:stock_managament_app/app/modules/sendSMS/views/search_widget.dart';
import 'package:stock_managament_app/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/custom_text_field.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class SendSMSView extends StatefulWidget {
  const SendSMSView({super.key});

  @override
  State<SendSMSView> createState() => _SendSMSViewState();
}

class _SendSMSViewState extends State<SendSMSView> {
  final ClientsController clientsController = Get.find();
  TextEditingController searchEditingController = TextEditingController();
  final Map<String, SmsSendStatus> _sendStatus = {};
  final Set<String> _selectedKeys = {};
  late final Future<List<ClientModel>> _clientsFuture;

  @override
  void initState() {
    super.initState();
    _clientsFuture = ClientsService().getClients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'sms_send_fab',
            backgroundColor: kPrimaryColor2,
            onPressed: () {
              sendMessage();
            },
            child: Icon(
              IconlyLight.message,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10.h),
          FloatingActionButton(
            heroTag: 'sms_status_fab',
            backgroundColor: Colors.white,
            onPressed: () {
              _openStatusList();
            },
            child: Icon(
              IconlyLight.document,
              color: kPrimaryColor2,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<ClientModel>>(
        future: _clientsFuture,
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

            return SafeArea(
              child: Column(
                children: [
                  SearchWidget(
                    controller: searchEditingController,
                    onChanged: (value) => clientsController.onSearchTextChanged(value),
                    onClear: () {
                      searchEditingController.clear();
                      clientsController.searchResult.clear();
                    },
                  ),
                  Padding(
                    padding: context.padding.horizontalNormal,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedKeys.isEmpty ? 'No selected' : 'Selected: ${_selectedKeys.length}',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp, color: Colors.grey.shade700),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _selectAll();
                          },
                          child: Text('Select all', style: TextStyle(color: kPrimaryColor2, fontSize: 12.sp)),
                        ),
                        TextButton(
                          onPressed: () {
                            _clearSelection();
                          },
                          child: Text('Clear', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: (searchEditingController.text.isNotEmpty && clientsController.searchResult.isEmpty)
                        ? emptyData()
                        : ListView.separated(
                            padding: context.padding.horizontalNormal + context.padding.onlyBottomHigh,
                            itemCount: displayList.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final client = displayList[index];
                              final key = _clientKey(client);
                              final isSelected = _selectedKeys.contains(key);
                              return GestureDetector(
                                onLongPress: () {
                                  _toggleSelection(client);
                                },
                                onTap: () {
                                  if (_selectedKeys.isNotEmpty) {
                                    _toggleSelection(client);
                                  }
                                },
                                child: ClientCard(
                                  client: client,
                                  index: (displayList.length - index).toString(),
                                  sendStatus: _sendStatus[key],
                                  isSelected: isSelected,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  void _toggleSelection(ClientModel client) {
    final key = _clientKey(client);
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
      } else {
        _selectedKeys.add(key);
      }
    });
  }

  void _selectAll() {
    final clients = clientsController.clients.toList();
    final clientsWithPhone = clients.where((client) => client.phone.trim().isNotEmpty).toList();
    setState(() {
      _selectedKeys.clear();
      _selectedKeys.addAll(clientsWithPhone.map(_clientKey));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedKeys.clear();
    });
  }

  String _clientKey(ClientModel client) {
    final id = client.id;
    if (id != null) {
      return 'id:$id';
    }
    return 'phone:${client.phone.trim()}';
  }

  String _formatPhone(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    if (trimmed.startsWith('+')) {
      return trimmed;
    }
    if (trimmed.startsWith('993')) {
      return '+$trimmed';
    }
    return '+993$trimmed';
  }

  Future<SmsSendStatus> _sendSms({required String message, required String number}) async {
    final formatted = _formatPhone(number);
    if (formatted.isEmpty) {
      return SmsSendStatus.failed;
    }
    final res = await BackgroundSms.sendMessage(phoneNumber: formatted, message: message);
    return res == SmsStatus.sent ? SmsSendStatus.sent : SmsSendStatus.failed;
  }

  Future<void> _sendToClient({required ClientModel client, required String message}) async {
    final key = _clientKey(client);
    setState(() {
      _sendStatus[key] = SmsSendStatus.sending;
    });
    final status = await _sendSms(message: message, number: client.phone);
    setState(() {
      _sendStatus[key] = status;
    });
  }

  Future<bool> _ensureSmsPermission() async {
    if (await Permission.sms.isGranted) {
      return true;
    }
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  Future<dynamic> sendMessage() {
    TextEditingController titleEditingController = TextEditingController();
    FocusNode focusNode = FocusNode();
    final allClients = clientsController.clients.toList();
    final selectedClients = _selectedKeys.isEmpty ? allClients : allClients.where((client) => _selectedKeys.contains(_clientKey(client))).toList();
    final targetCount = selectedClients.where((client) => client.phone.trim().isNotEmpty).length;

    return Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(maxHeight: Get.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: kPrimaryColor2,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Icon(IconlyLight.message, color: Colors.white, size: 24.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Send message',
                        style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(Icons.close, color: Colors.white, size: 22.sp),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: kPrimaryColor2.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.people, color: kPrimaryColor2, size: 20.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'Recipients: $targetCount users',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp, color: kPrimaryColor2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Message',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp, color: Colors.black87),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: titleEditingController,
                        focusNode: focusNode,
                        maxLines: 6,
                        style: TextStyle(color: Colors.black, fontSize: 14.sp),
                        decoration: InputDecoration(
                          hintText: 'Type your message here...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: EdgeInsets.all(16.w),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: kPrimaryColor2, width: 2),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Get.back(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.black87,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: Text('Cancel', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () async {
                                final message = titleEditingController.text.trim();
                                if (message.isEmpty) {
                                  showSnackBar('Error', 'Message is empty', Colors.red);
                                  return;
                                }
                                final hasPermission = await _ensureSmsPermission();
                                if (!hasPermission) {
                                  showSnackBar('Error', 'SMS permission denied', Colors.red);
                                  return;
                                }

                                final allClients = clientsController.clients.toList();
                                final selectedClients = _selectedKeys.isEmpty ? allClients : allClients.where((client) => _selectedKeys.contains(_clientKey(client))).toList();
                                final clientsWithPhone = selectedClients.where((client) => client.phone.trim().isNotEmpty).toList();
                                if (clientsWithPhone.isEmpty) {
                                  showSnackBar('Error', 'No phone numbers', Colors.red);
                                  return;
                                }

                                Get.back();
                                int sentCount = 0;
                                int failedCount = 0;
                                for (final client in clientsWithPhone) {
                                  await _sendToClient(client: client, message: message);
                                  final key = _clientKey(client);
                                  final status = _sendStatus[key] ?? SmsSendStatus.failed;
                                  if (status == SmsSendStatus.sent) {
                                    sentCount++;
                                  } else if (status == SmsSendStatus.failed) {
                                    failedCount++;
                                  }
                                }
                                showSnackBar('Done', 'Sent: $sentCount, Failed: $failedCount', failedCount == 0 ? Colors.green : Colors.orange);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor2,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send, size: 18.sp),
                                  SizedBox(width: 8.w),
                                  Text('Send SMS', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openStatusList() {
    final clients = clientsController.clients.toList();
    if (clients.isEmpty) {
      showSnackBar('Info', 'No clients', Colors.orange);
      return;
    }
    int sentCount = 0;
    int failedCount = 0;
    int pendingCount = 0;
    for (final client in clients) {
      final status = _sendStatus[_clientKey(client)] ?? SmsSendStatus.idle;
      if (status == SmsSendStatus.sent) {
        sentCount++;
      } else if (status == SmsSendStatus.failed) {
        failedCount++;
      } else {
        pendingCount++;
      }
    }
    SmsSendStatus? filter;
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          final filteredClients = filter == null
              ? clients
              : clients.where((client) {
                  final status = _sendStatus[_clientKey(client)] ?? SmsSendStatus.idle;
                  return _matchesFilter(filter!, status);
                }).toList();

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44.w,
                    height: 5.h,
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Text(
                    'SMS Status',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      _statusTab(
                        label: 'All ${clients.length}',
                        isActive: filter == null,
                        color: kPrimaryColor2,
                        onTap: () => setSheetState(() => filter = null),
                      ),
                      SizedBox(width: 8.w),
                      _statusTab(
                        label: 'Sent $sentCount',
                        isActive: filter == SmsSendStatus.sent,
                        color: Colors.green,
                        onTap: () => setSheetState(() => filter = SmsSendStatus.sent),
                      ),
                      SizedBox(width: 8.w),
                      _statusTab(
                        label: 'Failed $failedCount',
                        isActive: filter == SmsSendStatus.failed,
                        color: Colors.red,
                        onTap: () => setSheetState(() => filter = SmsSendStatus.failed),
                      ),
                      SizedBox(width: 8.w),
                      _statusTab(
                        label: 'Pending $pendingCount',
                        isActive: filter == SmsSendStatus.idle,
                        color: Colors.grey,
                        onTap: () => setSheetState(() => filter = SmsSendStatus.idle),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: filteredClients.length,
                      separatorBuilder: (context, index) => SizedBox(height: 8.h),
                      itemBuilder: (context, index) {
                        final client = filteredClients[index];
                        final status = _sendStatus[_clientKey(client)] ?? SmsSendStatus.idle;
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      client.name.isEmpty ? 'Ady yok' : client.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      client.phone.isEmpty ? 'Nomeri yok' : client.phone,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: _statusColor(status).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _statusLabel(status),
                                  style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.w600, fontSize: 11.sp),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  bool _matchesFilter(SmsSendStatus filter, SmsSendStatus status) {
    if (filter == SmsSendStatus.idle) {
      return status == SmsSendStatus.idle || status == SmsSendStatus.sending;
    }
    return status == filter;
  }

  Widget _statusTab({required String label, required Color color, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isActive ? color : Colors.transparent, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(color: isActive ? color : Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 11.sp),
        ),
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
