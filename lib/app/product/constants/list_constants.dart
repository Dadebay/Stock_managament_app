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
  static List adminPages = [
    const HomeView(),
    const OrdersView(),
    const SendSMSView(),
    const SettingsView(),
  ];
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
  static List<Map<String, dynamic>> statusMapping2 = [
    {'name': 'Preparing', 'sortName': "1", 'size': ColumnSize.small.toString(), 'color': kPrimaryColor2},
    {'name': 'Ready to ship', 'sortName': "5", 'size': ColumnSize.small.toString(), 'color': Colors.purple},
    {'name': 'Shipped', 'sortName': "2", 'size': ColumnSize.small.toString(), 'color': Colors.green},
    {'name': 'Canceled', 'sortName': "3", 'size': ColumnSize.small.toString(), 'color': Colors.red},
    {'name': 'Refund', 'sortName': "4", 'size': ColumnSize.small.toString(), 'color': Colors.grey},
  ];
  static List<Map<String, String>> clientNames = [
    {'name': 'Client Name', 'sortName': "name", 'size': ColumnSize.medium.toString()},
    {'name': 'Address', 'sortName': "address", 'size': ColumnSize.medium.toString()},
    {'name': 'Client number', 'sortName': "number", 'size': ColumnSize.small.toString()},
    {'name': 'Order count', 'sortName': "order_count", 'size': ColumnSize.small.toString()},
    {'name': 'Sum price', 'sortName': "sum_price", 'size': ColumnSize.small.toString()},
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
  static List<Map<String, dynamic>> statusMapping = [
    {'name': 'Preparing', 'sortName': "0", 'size': ColumnSize.small.toString(), 'color': kPrimaryColor2},
    {'name': 'Preparing', 'sortName': "1", 'size': ColumnSize.small.toString(), 'color': kPrimaryColor2},
    {'name': 'Shipped', 'sortName': "2", 'size': ColumnSize.small.toString(), 'color': Colors.green},
    {'name': 'Canceled', 'sortName': "3", 'size': ColumnSize.small.toString(), 'color': Colors.red},
    {'name': 'Refund', 'sortName': "4", 'size': ColumnSize.small.toString(), 'color': Colors.grey},
    {'name': 'Ready to ship', 'sortName': "5", 'size': ColumnSize.small.toString(), 'color': Colors.purple},
  ];
}
