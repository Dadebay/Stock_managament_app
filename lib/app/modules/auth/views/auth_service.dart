// ignore_for_file: file_names, require_trailing_commas, avoid_void_async, avoid_bool_literals_in_conditional_expressions, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stock_managament_app/api_constants.dart';
import 'package:stock_managament_app/api_service.dart';
import 'package:stock_managament_app/app/modules/auth/views/enter_model.dart';
import 'package:stock_managament_app/app/modules/auth/views/login_view.dart';

class AuthStorage {
  final storage = GetStorage();

  Future<bool> logout() async {
    await storage.remove('AccessToken');
    await storage.remove('RefreshToken');
    return storage.read('AccessToken') == null ? true : false;
  }

  /////////////////////////////////////////User Token///////////////////////////////////
  Future<bool> setToken(String token) async {
    await storage.write('AccessToken', token);
    return storage.read('AccessToken') == null ? false : true;
  }

  Future<bool> setAdmin(bool token) async {
    await storage.write('isAdmin', token);
    return storage.read('isAdmin') == null ? false : true;
  }

  Future<String?> getToken() async {
    return storage.read('AccessToken');
  }

  Future<bool> removeToken() async {
    await storage.remove('AccessToken');
    return storage.read('AccessToken') == null ? true : false;
  }

/////////////////////////////////////////User Refresh Token///////////////////////////////////

  Future<bool> setRefreshToken(String token) async {
    await storage.write('RefreshToken', token);
    return storage.read('AccessToken') == null ? false : true;
  }

  Future<String?> getRefreshToken() async {
    return storage.read('RefreshToken');
  }

  Future<bool> removeRefreshToken() async {
    await storage.remove('RefreshToken');
    return storage.read('RefreshToken') == null ? true : false;
  }
}

class SignInService {
  final AuthStorage _auth = AuthStorage();
  Future<List<EnterModel>> getClients(String userName, String password) async {
    final uri = Uri.parse(ApiConstants.users);
    final data = await ApiService().getRequest(uri.toString(), requiresToken: true);
    if (data is Map && data['results'] != null) {
      return (data['results'] as List).map((item) => EnterModel.fromJson(item)).toList();
    } else if (data is List) {
      List<EnterModel> list = [];
      print(data);
      list = (data).map((item) => EnterModel.fromJson(item)).toList();
      for (var element in list) {
        print(element.username);
        if (element.username == userName && element.password == password) {
          print("geldi Mana");
          await _auth.setAdmin(true);
        }
      }
      return list;
    } else {
      return [];
    }
  }

  Future<dynamic> logOut(BuildContext context) async {
    final uri = Uri.parse(ApiConstants.logOut);
    print(uri);
    print(uri);
    print(uri);
    await ApiService().getRequest(uri.toString(), requiresToken: true);
    await AuthStorage().logout();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const SignUpView()));
  }

  Future login({required String username, required String password}) async {
    return ApiService().handleApiRequest(
      endpoint: ApiConstants.authUrl,
      method: 'POST',
      body: <String, dynamic>{
        'username': username,
        'password': password,
      },
      requiresToken: false,
      handleSuccess: (responseJson) async {
        if (responseJson['access'] != null) {
          await _auth.setToken(responseJson['access']);
          await _auth.setRefreshToken(responseJson['refresh']);
        }
        return responseJson;
      },
    );
  }
}
