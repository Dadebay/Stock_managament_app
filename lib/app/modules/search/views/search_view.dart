import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';

import '../controllers/search_controller.dart';

class SearchView extends StatelessWidget {
  TextEditingController controller = TextEditingController();
  final List _searchResult = [];
  final HomeController _homeController = Get.put(HomeController());

  SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SearchView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'SearchView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
