import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/order_controller.dart';
import 'package:stock_managament_app/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/custom_app_bar.dart';

import '../../../../../constants/customWidget/widgets.dart';

class OrderProgressView extends StatefulWidget {
  final List<TextEditingController> textControllers;
  final String status;

  const OrderProgressView({
    super.key,
    required this.textControllers,
    required this.status,
  });

  @override
  _OrderProgressViewState createState() => _OrderProgressViewState();
}

class _OrderProgressViewState extends State<OrderProgressView> {
  final OrderController _orderController = Get.find();
  final HomeController homeController = Get.find<HomeController>();
  final List<bool> _stepStatus = [false, false, false];
  final List<bool> _stepErrors = [false, false, false];
  StreamSubscription? _internetSubscription;
  Timer? _timeoutTimer;
  bool _processFailed = false;

  @override
  void initState() {
    super.initState();
    _startInternetListener();
    _startSubmissionProcess();
  }

  @override
  void dispose() {
    _internetSubscription?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _startInternetListener() {
    _internetSubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        _handleFailure();
      }
    });
  }

  Future<void> _startSubmissionProcess() async {
    if (!await _checkInternetConnection()) {
      return _handleFailure();
    }
    _startTimeout();
    bool saleSuccess = await _submitSale();
    if (!saleSuccess) return _handleFailure();
    setState(() => _stepStatus[0] = true);
    log('saleSuccess: $saleSuccess');

    while (_orderController.saleID.value.isEmpty) {
      if (!await _checkInternetConnection()) {
        return _handleFailure();
      }
      await Future.delayed(const Duration(seconds: 1));
    }

    bool productsSuccess = await _submitProducts();
    if (!productsSuccess) return _handleFailure();
    setState(() => _stepStatus[1] = true);
    log('productsSuccess: $productsSuccess');

    bool clientSuccess = await _submitClient();
    if (!clientSuccess) return _handleFailure();
    setState(() => _stepStatus[2] = true);
    log('clientSuccess: $clientSuccess');

    _timeoutTimer?.cancel();
    showSnackBar("doneTitle".tr, "doneSubtitle".tr, Colors.green);
  }

  void _startTimeout() {
    if (_processFailed) return;
    _timeoutTimer = Timer(const Duration(minutes: 1), () {
      _handleFailure();
    });
  }

  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      showSnackBar("No Internet", "Please check your connection", Colors.red);
      return false;
    }
    return true;
  }

  void _handleFailure() {
    if (!_processFailed) {
      _processFailed = true;
      _timeoutTimer?.cancel();
      _internetSubscription?.cancel();
      setState(() {
        for (int i = 0; i < _stepStatus.length; i++) {
          _stepStatus[i] = false;
          _stepErrors[i] = true;
        }
      });
      showSnackBar("errorTitle".tr, "noConnection1".tr, Colors.red);
    }
  }

  Future<bool> _submitSale() async {
    try {
      await _orderController.submitSale2(textControllers: widget.textControllers, status: widget.status);
      return true;
    } catch (e) {
      setState(() => _stepErrors[0] = true);
      return false;
    }
  }

  Future<bool> _submitProducts() async {
    try {
      await _orderController.submitProductsStep();
      return true;
    } catch (e) {
      setState(() => _stepErrors[1] = true);
      return false;
    }
  }

  Future<bool> _submitClient() async {
    try {
      await _orderController.submitClientStep(textControllers: widget.textControllers);
      return true;
    } catch (e) {
      setState(() => _stepErrors[2] = true);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        name: "orderProgress".tr,
        centerTitle: true,
        backArrow: true,
        actionIcon: true,
      ),
      body: ListView(
        children: [
          _buildStepItem(0, "salesRecord".tr),
          _buildStepItem(1, "productRecord".tr),
          _buildStepItem(2, "clientUpdate".tr),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AgreeButton(
                onTap: () {
                  Get.back();
                  Get.back();
                },
                text: "agree".tr),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(int index, String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          _stepStatus[index]
              ? const Icon(Icons.check_circle, color: Colors.green)
              : _stepErrors[index]
                  ? IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.red),
                      onPressed: () => _retryStep(index),
                    )
                  : const CircularProgressIndicator(),
        ],
      ),
    );
  }

  void _retryStep(int index) {
    setState(() => _stepErrors[index] = false);
    switch (index) {
      case 0:
        _submitSale();
        break;
      case 1:
        _submitProducts();
        break;
      case 2:
        _submitClient();
        break;
    }
  }
}
