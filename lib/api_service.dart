// ignore_for_file: file_names, require_trailing_commas, avoid_void_async, avoid_bool_literals_in_conditional_expressions, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'app/modules/auth/views/auth_service.dart';
import 'constants/customWidget/widgets.dart';

class ApiService {
  final AuthStorage _auth = AuthStorage();

  // Timeout süresi (saniye)
  static const int REQUEST_TIMEOUT_SECONDS = 30;

  Future<dynamic> getRequest(
    String endpoint, {
    required bool requiresToken,
    Future<dynamic> Function(dynamic)? handleSuccess,
  }) async {
    print('\n📡 [API] ===== GET Request =====');
    print('📡 [API] Endpoint: $endpoint');
    print('📡 [API] Requires Token: $requiresToken');
    print('📡 [API] Timeout: ${REQUEST_TIMEOUT_SECONDS}s');

    try {
      final token = await _auth.getToken();
      print('📡 [API] Token: ${token != null ? "✅ EXISTS (${token.substring(0, 20)}...)" : "❌ NULL"}');

      final headers = <String, String>{
        if (requiresToken && token != null) 'Authorization': 'Bearer $token',
      };
      print('📡 [API] Headers: $headers');

      print('📡 [API] Sending request...');
      final response = await http
          .get(
        Uri.parse(endpoint),
        headers: headers,
      )
          .timeout(
        Duration(seconds: REQUEST_TIMEOUT_SECONDS),
        onTimeout: () {
          print('⏰ [API] Request Timeout after ${REQUEST_TIMEOUT_SECONDS}s');
          throw TimeoutException('Request timeout after ${REQUEST_TIMEOUT_SECONDS} seconds');
        },
      );

      print('📡 [API] Response Status: ${response.statusCode}');
      print('📡 [API] Response Body Length: ${response.body.length} bytes');

      if (response.statusCode == 200) {
        print('✅ [API] Success: Status 200');
        final decodedBody = utf8.decode(response.bodyBytes); // UTF-8 çözümleme burada
        final responseJson = decodedBody.isNotEmpty ? json.decode(decodedBody) : {};

        if (handleSuccess != null) {
          await handleSuccess(responseJson);
        }
        return responseJson;
      } else {
        print('❌ [API] Error: Status ${response.statusCode}');
        print('❌ [API] Error Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
        final responseJson = response.body.isNotEmpty ? json.decode(response.body) : {};
        _handleApiError(response.statusCode, responseJson['message']?.toString() ?? 'anErrorOccurred'.tr);
        return null;
      }
    } on TimeoutException catch (e) {
      print('❌ [API] TimeoutException: $e');
      print('❌ [API] Server did not respond within ${REQUEST_TIMEOUT_SECONDS} seconds');
      showSnackBar('Timeout', 'Server response timeout. Please try again.', Colors.orange);
      return null;
    } on SocketException catch (e) {
      print('❌ [API] SocketException: $e');
      print('❌ [API] Network Error: No Internet or Server Unreachable');
      showSnackBar('networkError'.tr, 'noInternet'.tr, Colors.red);
      return null;
    } catch (e) {
      print('❌ [API] Unknown Error: $e');
      print('❌ [API] Error Type: ${e.runtimeType}');
      showSnackBar('unknownError'.tr, 'anErrorOccurred'.tr, Colors.red);
      return null;
    }
  }

  Future<dynamic> handleApiRequest({
    required String endpoint,
    Map<String, dynamic>? body,
    required bool requiresToken,
    required String method,
    Function(dynamic)? handleSuccess,
  }) async {
    try {
      final token = await _auth.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        if (requiresToken && token != null) 'Authorization': 'Bearer $token',
      };
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(Uri.parse(endpoint), headers: headers);
          break;
        case 'POST':
          response = await http.post(
            Uri.parse(endpoint),
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
          break;
        case 'DELETE':
          response = await http.delete(
            Uri.parse(endpoint),
            headers: headers,
          );
          break;
        case 'PUT':
          response = await http.put(
            Uri.parse(endpoint),
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
          break;
        default:
          throw UnsupportedError('Unsupported HTTP method: $method');
      }

      print('\n===== API REQUEST =====');
      print('Method: $method');
      print('Endpoint: $endpoint');
      print('Request Body: $body');
      print('\n===== API RESPONSE =====');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body.length > 500 ? response.body.substring(0, 500) + "..." : response.body}');
      print('======================\n');

      if ([200, 201, 204].contains(response.statusCode)) {
        if (response.statusCode == 204) {
          await handleSuccess!({"statusCode": response.statusCode});
          return {"statusCode": response.statusCode};
        }
        final responseJson = response.body.isNotEmpty ? json.decode(response.body) : null;
        if (handleSuccess != null && responseJson != null) {
          await handleSuccess(responseJson);
        }
        return responseJson ?? response.statusCode;
      } else {
        // Check if response is JSON before parsing
        print('===== ERROR RESPONSE =====');
        print('Status Code: ${response.statusCode}');
        try {
          final responseJson = response.body.isNotEmpty ? json.decode(response.body) : {};
          print('Error Message: ${responseJson['message']}');
          print('========================\n');
          _handleApiError(
            response.statusCode,
            responseJson['message']?.toString() ?? 'anErrorOccurred'.tr,
          );
        } catch (e) {
          // If parsing fails (e.g., HTML response), show the status code error
          print('⚠️ Response is not JSON (possibly HTML error page)');
          print('Parse Error: $e');
          print('Response preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
          print('========================\n');
          _handleApiError(
            response.statusCode,
            'Server returned an error. Status: ${response.statusCode}',
          );
        }
        return null;
      }
    } on SocketException {
      showSnackBar('networkError'.tr, 'noInternet'.tr, Colors.red);
      return null;
    }
  }

  void _handleApiError(int statusCode, String message) {
    String errorMessage = 'anErrorOccurred'.tr;
    switch (statusCode) {
      case 400:
        errorMessage = 'invalidNumber'.tr;
        break;
      case 401:
        errorMessage = '${'unauthorized'.tr}: $message';
        break;
      case 403:
        errorMessage = message;
        break;
      case 404:
        errorMessage = '${'notFound'.tr}: $message';
        break;
      case 405:
        errorMessage = 'userDoesNotExist'.tr;
        break;
      case 500:
        errorMessage = '${'serverError'.tr}: $message';
        break;
      default:
        errorMessage = '${'errorStatus'.tr} $statusCode: $message';
    }
    if (statusCode == 409) {
      showSnackBar('apiError'.tr, errorMessage, Colors.orange);
    } else {
      showSnackBar('apiError'.tr, errorMessage, Colors.red);
    }
  }
}
