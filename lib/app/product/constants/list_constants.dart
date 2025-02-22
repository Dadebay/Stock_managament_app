import 'package:flutter/material.dart';
import 'package:stock_managament_app/app/modules/orders/views/orders_view.dart';
import 'package:stock_managament_app/app/modules/sendSMS/views/send_sms_view.dart';
import 'package:stock_managament_app/app/modules/settings/views/settings_view.dart';

import '../../../constants/customWidget/constants.dart';
import '../../modules/home/views/home_view.dart';

class ListConstants {
  static List adminPages = [const HomeView(), const OrdersView(), const SettingsView(), const SendSMSView()];
  static List pages = [const HomeView(), const OrdersView(), const SettingsView()];
  static List adminName = ['products', 'sales', 'settings', 'Send SMS'];
  static List names = ['products', 'sales', 'settings'];
  static List filters = [
    {'name': 'Brands', 'searchName': 'brand'},
    {'name': 'Categories', 'searchName': 'category'},
    {'name': 'Locations', 'searchName': 'location'},
    {'name': 'Materials', 'searchName': 'material'}
  ];
  static Map<String, Color> colorMapping = {"shipped": Colors.green, "canceled": Colors.red, "refund": Colors.red, "preparing": kPrimaryColor2, "ready to ship": Colors.purple};
}
