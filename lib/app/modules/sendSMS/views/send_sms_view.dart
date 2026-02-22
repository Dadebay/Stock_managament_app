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

  // 🧪 TEST MODE - Set to false for production
  bool _testMode = false; // Test modunu aktif/pasif yapmak için

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
          // Test Mode Toggle Button
          FloatingActionButton(
            heroTag: 'test_mode_fab',
            backgroundColor: _testMode ? Colors.orange : Colors.grey.shade300,
            onPressed: () {
              setState(() {
                _testMode = !_testMode;
              });
              showSnackBar(
                'Test Mode',
                _testMode ? 'TEST MODE ON (${SMS_HOURLY_LIMIT_TEST} SMS/batch, ${WAIT_DURATION_MINUTES_TEST}m wait)' : 'TEST MODE OFF (Production settings)',
                _testMode ? Colors.orange : Colors.grey,
              );
            },
            child: Icon(
              _testMode ? Icons.bug_report : Icons.bug_report_outlined,
              color: _testMode ? Colors.white : Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 10.h),
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

  // SMS karakter limiti (GSM-7 encoding için)
  static const int SMS_CHAR_LIMIT = 160;
  static const int SMS_MULTIPART_LIMIT = 153; // Multipart için her parça

  // Production settings
  static const int SMS_HOURLY_LIMIT_PROD = 60; // Saatlik SMS limiti (production)
  static const int WAIT_DURATION_MINUTES_PROD = 60; // Bekleme süresi (production)

  // Test settings (hızlı test için)
  static const int SMS_HOURLY_LIMIT_TEST = 5; // Test için küçük limit
  static const int WAIT_DURATION_MINUTES_TEST = 1; // Test için 1 dakika bekleme

  // Dinamik değerler
  int get SMS_HOURLY_LIMIT => _testMode ? SMS_HOURLY_LIMIT_TEST : SMS_HOURLY_LIMIT_PROD;
  int get WAIT_DURATION_MINUTES => _testMode ? WAIT_DURATION_MINUTES_TEST : WAIT_DURATION_MINUTES_PROD;

  List<String> _splitMessage(String message) {
    if (message.length <= SMS_CHAR_LIMIT) {
      return [message];
    }
    // Mesajı 153 karakterlik parçalara böl (multipart header için yer bırak)
    final List<String> parts = [];
    int start = 0;
    while (start < message.length) {
      int end = start + SMS_MULTIPART_LIMIT;
      if (end > message.length) end = message.length;
      parts.add(message.substring(start, end));
      start = end;
    }
    return parts;
  }

  Future<SmsSendStatus> _sendSms({required String message, required String number}) async {
    final formatted = _formatPhone(number);
    print('📱 [SMS] Formatting phone: $number -> $formatted');
    if (formatted.isEmpty) {
      print('❌ [SMS] Phone number is empty after formatting');
      return SmsSendStatus.failed;
    }

    // Mesajı parçalara böl
    final messageParts = _splitMessage(message);
    print('📤 [SMS] Sending to: $formatted, message length: ${message.length}, parts: ${messageParts.length}');

    // 🧪 TEST MODE - Gerçek SMS göndermeden simüle et
    if (_testMode) {
      print('🧪 [TEST MODE] Simulating SMS send...');
      for (int i = 0; i < messageParts.length; i++) {
        final part = messageParts[i];
        print('📨 [TEST] Simulating part ${i + 1}/${messageParts.length}: "${part.substring(0, part.length > 30 ? 30 : part.length)}..."');
        await Future.delayed(const Duration(milliseconds: 300)); // Gerçekçi gecikme
        print('📬 [TEST] Part ${i + 1} simulated: SUCCESS');
        if (i < messageParts.length - 1) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
      print('✅ [TEST MODE] Simulated send completed successfully');
      return SmsSendStatus.sent;
    }

    // 📱 PRODUCTION MODE - Gerçek SMS gönder
    bool allSent = true;
    for (int i = 0; i < messageParts.length; i++) {
      final part = messageParts[i];
      final partMessage = messageParts.length > 1 ? '(${i + 1}/${messageParts.length}) $part' : part;
      print('📨 [SMS] Sending part ${i + 1}/${messageParts.length}: "${part.substring(0, part.length > 30 ? 30 : part.length)}..."');

      final res = await BackgroundSms.sendMessage(phoneNumber: formatted, message: partMessage);
      print('📬 [SMS] Part ${i + 1} result: $res (${res == SmsStatus.sent ? "SUCCESS" : "FAILED"})');

      if (res != SmsStatus.sent) {
        allSent = false;
        break;
      }

      // Parçalar arası kısa bekleme
      if (i < messageParts.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    return allSent ? SmsSendStatus.sent : SmsSendStatus.failed;
  }

  Future<void> _sendToClient({required ClientModel client, required String message}) async {
    final key = _clientKey(client);
    print('👤 [Client] Sending to: ${client.name} (${client.phone})');
    setState(() {
      _sendStatus[key] = SmsSendStatus.sending;
    });
    final status = await _sendSms(message: message, number: client.phone);
    print('✅ [Client] Status for ${client.name}: $status');
    setState(() {
      _sendStatus[key] = status;
    });
  }

  Future<bool> _ensureSmsPermission() async {
    print('🔐 [PERM] Checking if SMS permission is already granted...');
    if (await Permission.sms.isGranted) {
      print('✅ [PERM] SMS permission already granted');
      return true;
    }
    print('🔐 [PERM] Requesting SMS permission...');
    final status = await Permission.sms.request();
    print('🔐 [PERM] Permission request result: $status (isGranted: ${status.isGranted})');
    return status.isGranted;
  }

  Future<dynamic> sendMessage() {
    print('\n📱 [DIALOG] Opening send message dialog');
    print('🔑 [SELECT] Currently selected keys: $_selectedKeys');
    TextEditingController titleEditingController = TextEditingController();
    FocusNode focusNode = FocusNode();
    final ValueNotifier<int> charCount = ValueNotifier(0);
    final allClients = clientsController.clients.toList();
    final selectedClients = _selectedKeys.isEmpty ? allClients : allClients.where((client) => _selectedKeys.contains(_clientKey(client))).toList();
    final targetCount = selectedClients.where((client) => client.phone.trim().isNotEmpty).length;
    print('📊 [DIALOG] Target count: $targetCount');

    titleEditingController.addListener(() {
      charCount.value = titleEditingController.text.length;
    });

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
                      // Test Mode Warning
                      if (_testMode)
                        Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade600, width: 2),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.bug_report, color: Colors.orange.shade800, size: 24.sp),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '🧪 TEST MODE ACTIVE',
                                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'No real SMS will be sent. Batch: $SMS_HOURLY_LIMIT SMS, Wait: ${WAIT_DURATION_MINUTES}m',
                                      style: TextStyle(fontSize: 11.sp, color: Colors.orange.shade800),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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
                      // Batch uyarısı (60+ kişi için)
                      if (targetCount > SMS_HOURLY_LIMIT)
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade300),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20.sp),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Batch Sending Required',
                                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'SMS limit: $SMS_HOURLY_LIMIT per hour. Your $targetCount messages will be sent in ${(targetCount / SMS_HOURLY_LIMIT).ceil()} batches with $WAIT_DURATION_MINUTES min breaks.',
                                      style: TextStyle(fontSize: 11.sp, color: Colors.orange.shade700),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (targetCount > SMS_HOURLY_LIMIT) SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Message',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp, color: Colors.black87),
                          ),
                          ValueListenableBuilder<int>(
                            valueListenable: charCount,
                            builder: (context, count, child) {
                              final smsCount = count == 0 ? 1 : (count / SMS_MULTIPART_LIMIT).ceil();
                              final color = count > SMS_CHAR_LIMIT ? Colors.orange : Colors.grey.shade600;
                              return Text(
                                '$count chars${count > SMS_CHAR_LIMIT ? " ($smsCount SMS)" : ""}',
                                style: TextStyle(fontSize: 12.sp, color: color, fontWeight: FontWeight.w600),
                              );
                            },
                          ),
                        ],
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
                      SizedBox(height: 8.h),
                      ValueListenableBuilder<int>(
                        valueListenable: charCount,
                        builder: (context, count, child) {
                          if (count <= SMS_CHAR_LIMIT) return const SizedBox.shrink();
                          final smsCount = (count / SMS_MULTIPART_LIMIT).ceil();
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 16.sp),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'Long message will be sent as $smsCount SMS parts',
                                    style: TextStyle(fontSize: 11.sp, color: Colors.orange.shade700),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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
                                print('\n🔵 [BUTTON] Send button pressed');
                                print('📝 [MSG] Message length: ${message.length}');

                                // Mesaj parçalama bilgisi
                                final messageParts = _splitMessage(message);
                                if (messageParts.length > 1) {
                                  print('✂️ [MSG] Message will be split into ${messageParts.length} parts');
                                  for (int i = 0; i < messageParts.length; i++) {
                                    print('  Part ${i + 1}: ${messageParts[i].length} chars');
                                  }
                                }

                                if (message.isEmpty) {
                                  print('❌ [ERROR] Message is empty');
                                  showSnackBar('Error', 'Message is empty', Colors.red);
                                  return;
                                }
                                print('🔐 [PERM] Checking SMS permission...');
                                final hasPermission = await _ensureSmsPermission();
                                print('🔐 [PERM] Permission granted: $hasPermission');
                                if (!hasPermission) {
                                  showSnackBar('Error', 'SMS permission denied', Colors.red);
                                  return;
                                }

                                final allClients = clientsController.clients.toList();
                                print('👥 [TOTAL] All clients count: ${allClients.length}');
                                print('🎯 [SELECT] Selected keys: $_selectedKeys');
                                final selectedClients = _selectedKeys.isEmpty ? allClients : allClients.where((client) => _selectedKeys.contains(_clientKey(client))).toList();
                                print('👥 [SELECT] Selected clients count: ${selectedClients.length}');
                                final clientsWithPhone = selectedClients.where((client) => client.phone.trim().isNotEmpty).toList();
                                print('📞 [PHONE] Clients with phone: ${clientsWithPhone.length}');
                                for (int i = 0; i < clientsWithPhone.length; i++) {
                                  print('  [$i] ${clientsWithPhone[i].name} - ${clientsWithPhone[i].phone}');
                                }
                                if (clientsWithPhone.isEmpty) {
                                  print('❌ [ERROR] No phone numbers found');
                                  showSnackBar('Error', 'No phone numbers', Colors.red);
                                  return;
                                }

                                Get.back();

                                // Test Mode bilgisi
                                if (_testMode) {
                                  print('\n🧪 ========== TEST MODE ACTIVE ==========');
                                  print('🧪 [TEST] No real SMS will be sent');
                                  print('🧪 [TEST] Batch limit: $SMS_HOURLY_LIMIT SMS per batch');
                                  print('🧪 [TEST] Wait time: $WAIT_DURATION_MINUTES minutes');
                                  print('🧪 ========================================\n');
                                }

                                // Batch hesaplama
                                final totalBatches = (clientsWithPhone.length / SMS_HOURLY_LIMIT).ceil();
                                final needsBatching = clientsWithPhone.length > SMS_HOURLY_LIMIT;

                                if (needsBatching) {
                                  print('⚠️ [BATCH] Total clients: ${clientsWithPhone.length}');
                                  print('⚠️ [BATCH] SMS limit per hour: $SMS_HOURLY_LIMIT');
                                  print('⚠️ [BATCH] Total batches needed: $totalBatches');
                                  print('⚠️ [BATCH] Will wait $WAIT_DURATION_MINUTES minutes between batches');
                                }

                                print('\n🚀 [START] Starting SMS sending process');
                                print('📊 [INFO] Total selected clients: ${clientsWithPhone.length}');
                                print('📝 [INFO] Message: $message');

                                // Progress dialog göster
                                _showSendingProgressDialog(
                                  totalCount: clientsWithPhone.length,
                                  needsBatching: needsBatching,
                                  totalBatches: totalBatches,
                                  onStart: () async {
                                    int sentCount = 0;
                                    int failedCount = 0;
                                    int currentBatch = 1;

                                    for (int i = 0; i < clientsWithPhone.length; i++) {
                                      // Batch kontrolü - Her 60 SMS'de bir kontrol
                                      if (i > 0 && i % SMS_HOURLY_LIMIT == 0) {
                                        currentBatch++;
                                        print('\n⏸️ [BATCH] Batch $currentBatch/$totalBatches starting');
                                        print('⏰ [WAIT] Waiting $WAIT_DURATION_MINUTES minutes to avoid spam detection...');

                                        // Batch bilgisini güncelle
                                        _updateBatchWaiting(currentBatch, totalBatches, WAIT_DURATION_MINUTES);

                                        // 1 saat bekle (geri sayım ile)
                                        await _waitWithCountdown(Duration(minutes: WAIT_DURATION_MINUTES));

                                        print('✅ [WAIT] Wait completed, resuming...');
                                      }

                                      final client = clientsWithPhone[i];
                                      print('\n--- [${i + 1}/${clientsWithPhone.length}] Batch: $currentBatch/$totalBatches ---');

                                      // Progress güncelle
                                      _updateProgress(i + 1, clientsWithPhone.length, sentCount, failedCount, client.name, currentBatch, totalBatches);

                                      await _sendToClient(client: client, message: message);
                                      final key = _clientKey(client);
                                      final status = _sendStatus[key] ?? SmsSendStatus.failed;

                                      if (status == SmsSendStatus.sent) {
                                        sentCount++;
                                        print('✅ [Count] Sent: $sentCount');
                                      } else if (status == SmsSendStatus.failed) {
                                        failedCount++;
                                        print('❌ [Count] Failed: $failedCount');
                                      }

                                      // Her SMS arasında 1 saniye bekle (spam önleme için)
                                      if (i < clientsWithPhone.length - 1) {
                                        // Batch sınırına gelmediyse normal bekleme
                                        if ((i + 1) % SMS_HOURLY_LIMIT != 0) {
                                          print('⏳ [WAIT] Waiting 1 second before next SMS...');
                                          await Future.delayed(const Duration(seconds: 1));
                                        }
                                      }
                                    }

                                    print('\n🏁 [DONE] SMS sending completed');
                                    print('📈 [RESULT] Sent: $sentCount, Failed: $failedCount\n');

                                    // Dialog kapat
                                    Get.back();

                                    // Sonuç göster
                                    showSnackBar('Done', 'Sent: $sentCount, Failed: $failedCount', failedCount == 0 ? Colors.green : Colors.orange);
                                  },
                                );
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

  // Progress dialog değişkenleri
  final ValueNotifier<int> _progressCurrent = ValueNotifier(0);
  final ValueNotifier<int> _progressTotal = ValueNotifier(0);
  final ValueNotifier<int> _progressSent = ValueNotifier(0);
  final ValueNotifier<int> _progressFailed = ValueNotifier(0);
  final ValueNotifier<String> _progressCurrentClient = ValueNotifier('');
  final ValueNotifier<int> _progressCurrentBatch = ValueNotifier(1);
  final ValueNotifier<int> _progressTotalBatches = ValueNotifier(1);
  final ValueNotifier<bool> _progressIsWaiting = ValueNotifier(false);
  final ValueNotifier<String> _progressWaitMessage = ValueNotifier('');

  void _updateProgress(int current, int total, int sent, int failed, String clientName, int currentBatch, int totalBatches) {
    _progressCurrent.value = current;
    _progressTotal.value = total;
    _progressSent.value = sent;
    _progressFailed.value = failed;
    _progressCurrentClient.value = clientName;
    _progressCurrentBatch.value = currentBatch;
    _progressTotalBatches.value = totalBatches;
    _progressIsWaiting.value = false;
  }

  void _updateBatchWaiting(int currentBatch, int totalBatches, int waitMinutes) {
    _progressCurrentBatch.value = currentBatch;
    _progressTotalBatches.value = totalBatches;
    _progressIsWaiting.value = true;
    _progressWaitMessage.value = 'Waiting $waitMinutes minutes...';
  }

  Future<void> _waitWithCountdown(Duration duration) async {
    final totalSeconds = duration.inSeconds;
    for (int i = totalSeconds; i > 0; i--) {
      final minutes = i ~/ 60;
      final seconds = i % 60;
      _progressWaitMessage.value = 'Waiting: ${minutes}m ${seconds}s remaining';
      await Future.delayed(const Duration(seconds: 1));
    }
    _progressIsWaiting.value = false;
  }

  void _showSendingProgressDialog({required int totalCount, required bool needsBatching, required int totalBatches, required Future<void> Function() onStart}) {
    _progressCurrent.value = 0;
    _progressTotal.value = totalCount;
    _progressSent.value = 0;
    _progressFailed.value = 0;
    _progressCurrentClient.value = '';
    _progressCurrentBatch.value = 1;
    _progressTotalBatches.value = totalBatches;
    _progressIsWaiting.value = false;
    _progressWaitMessage.value = '';

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Dialog kapatılamaz
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: kPrimaryColor2.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(IconlyBold.send, color: kPrimaryColor2, size: 24.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sending SMS...',
                            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          if (_testMode)
                            Container(
                              margin: EdgeInsets.only(top: 4.h),
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '🧪 TEST MODE',
                                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Progress bar
                ValueListenableBuilder<int>(
                  valueListenable: _progressCurrent,
                  builder: (context, current, child) {
                    return ValueListenableBuilder<int>(
                      valueListenable: _progressTotal,
                      builder: (context, total, child) {
                        final progress = total > 0 ? current / total : 0.0;
                        return Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 12.h,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor2),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              '$current / $total',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: kPrimaryColor2),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                SizedBox(height: 20.h),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable: _progressSent,
                      builder: (context, sent, child) {
                        return _buildStatItem(
                          icon: Icons.check_circle,
                          color: Colors.green,
                          label: 'Sent',
                          value: sent.toString(),
                        );
                      },
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: _progressFailed,
                      builder: (context, failed, child) {
                        return _buildStatItem(
                          icon: Icons.error,
                          color: Colors.red,
                          label: 'Failed',
                          value: failed.toString(),
                        );
                      },
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: _progressCurrent,
                      builder: (context, current, child) {
                        return ValueListenableBuilder<int>(
                          valueListenable: _progressTotal,
                          builder: (context, total, child) {
                            final remaining = total - current;
                            return _buildStatItem(
                              icon: Icons.hourglass_empty,
                              color: Colors.orange,
                              label: 'Remaining',
                              value: remaining.toString(),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Batch bilgisi (eğer batch kullanılıyorsa)
                if (needsBatching)
                  ValueListenableBuilder<int>(
                    valueListenable: _progressCurrentBatch,
                    builder: (context, currentBatch, child) {
                      return ValueListenableBuilder<int>(
                        valueListenable: _progressTotalBatches,
                        builder: (context, totalBatches, child) {
                          return Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.layers, color: Colors.blue.shade700, size: 20.sp),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Batch Progress',
                                        style: TextStyle(fontSize: 11.sp, color: Colors.blue.shade600, fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'Batch $currentBatch of $totalBatches',
                                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        '$SMS_HOURLY_LIMIT SMS per batch • $WAIT_DURATION_MINUTES min wait',
                                        style: TextStyle(fontSize: 10.sp, color: Colors.blue.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                if (needsBatching) SizedBox(height: 12.h),

                // Bekleme mesajı (batch arası bekleme)
                ValueListenableBuilder<bool>(
                  valueListenable: _progressIsWaiting,
                  builder: (context, isWaiting, child) {
                    if (!isWaiting) return const SizedBox.shrink();
                    return ValueListenableBuilder<String>(
                      valueListenable: _progressWaitMessage,
                      builder: (context, message, child) {
                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.orange.shade300, width: 2),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.timer, color: Colors.orange.shade700, size: 32.sp),
                              SizedBox(height: 8.h),
                              Text(
                                'Batch Break',
                                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                message,
                                style: TextStyle(fontSize: 13.sp, color: Colors.orange.shade700),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'Preventing spam detection...',
                                style: TextStyle(fontSize: 11.sp, color: Colors.orange.shade600),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),

                ValueListenableBuilder<bool>(
                  valueListenable: _progressIsWaiting,
                  builder: (context, isWaiting, child) {
                    return isWaiting ? SizedBox(height: 12.h) : const SizedBox.shrink();
                  },
                ),

                // Current client
                ValueListenableBuilder<String>(
                  valueListenable: _progressCurrentClient,
                  builder: (context, clientName, child) {
                    if (clientName.isEmpty) return const SizedBox.shrink();
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sending to:',
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            clientName,
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Start sending
    onStart();
  }

  Widget _buildStatItem({required IconData icon, required Color color, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28.sp),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: color),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
        ),
      ],
    );
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
