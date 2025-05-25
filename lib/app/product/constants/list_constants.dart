import 'package:flutter/material.dart';
import 'package:stock_managament_app/api_constants.dart';
import 'package:stock_managament_app/app/modules/orders/views/orders_view.dart';
import 'package:stock_managament_app/app/modules/sendSMS/views/send_sms_view.dart';
import 'package:stock_managament_app/app/modules/settings/views/settings_view.dart';

import '../../../constants/customWidget/constants.dart';
import '../../modules/home/views/home_view.dart';

enum SortOptions { preparing, readyToShip, shipped, canceled, refund }

enum ColumnSize { small, medium, large }

class ListConstants {
  static List adminPages = [const HomeView(), const OrdersView(), const SettingsView(), const SendSMSView()];
  static List pages = [const HomeView(), const OrdersView(), const SettingsView()];
  static List adminName = ['products', 'sales', 'settings', 'Send SMS'];
  static List names = ['products', 'sales', 'settings'];
  static List filters = [
    {'name': 'Brands', 'searchName': 'brends'},
    {'name': 'Categories', 'searchName': 'category'},
    {'name': 'Locations', 'searchName': 'location'},
    {'name': 'Materials', 'searchName': 'material'}
  ];
  static final List<String> apiFieldNames = [
    'name',
    'price',
    'count',
    'category',
    'brends',
    'materials',
    'location',
    'gram',
    'description',
  ];

  static List<Map<String, dynamic>> fieldNames = [
    {'field': 'date', 'value': false},
    {'field': 'package', 'value': true},
    {'field': 'client_number', 'value': true},
    {'field': 'client_name', 'value': true},
    {'field': 'client_address', 'value': true},
    {'field': 'discount', 'value': true},
    {'field': 'priceProduct', 'value': false},
    {'field': 'coupon', 'value': true},
    {'field': 'note', 'value': true},
    {'field': 'product_count', 'value': false},
  ];
  static List<Map<String, String>> searchViewFilters = [
    {'name': 'Brands', 'searchName': 'brends'},
    {'name': 'Categories', 'searchName': 'category'},
    {'name': 'Locations', 'searchName': 'location'},
    {'name': 'Materials', 'searchName': 'material'}
  ];
  static List<Map<String, String>> four_in_one_names = [
    {'name': 'brands', 'pageView': "Brands", "countName": 'brends', "id": "1", 'size': ColumnSize.small.toString(), "url": ApiConstants.brends},
    {'name': 'categories', 'pageView': "Categories", "countName": 'category', "id": "2", 'size': ColumnSize.small.toString(), "url": ApiConstants.categories},
    {'name': 'locations', 'pageView': "Locations", "countName": 'location', "id": "3", 'size': ColumnSize.small.toString(), "url": ApiConstants.locations},
    {'name': 'materials', 'pageView': "Materials", "countName": 'materials', "id": "4", 'size': ColumnSize.small.toString(), "url": ApiConstants.materials},
  ];
  static Map<String, Color> colorMapping = {"shipped": Colors.green, "canceled": Colors.red, "refund": Colors.red, "preparing": kPrimaryColor2, "ready to ship": Colors.purple};
  static Map<String, String> statusMapping = {"preparing": 'Preparing', "readyToShip": 'Ready to ship', "shipped": "Shipped", "canceled": "Canceled", "refund": 'Refund'};
  static Map<String, SortOptions> statusSortOption = {"preparing": SortOptions.preparing, "readyToShip": SortOptions.readyToShip, "shipped": SortOptions.shipped, "canceled": SortOptions.canceled, "refund": SortOptions.refund};
}
