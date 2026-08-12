import 'dart:convert';
import 'package:http/http.dart' as http;

import '../storage/local_storage_service.dart';

/// Central HTTP client — Bearer token auth
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const String baseUrl =
      'https://vehicles-tracking-production-z593lf.laravel.cloud/api';

  // ===========================================================================
  // HEADERS
  // ===========================================================================

  Map<String, String> _headers({bool auth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token = LocalStorageService.instance.getToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ===========================================================================
  // URI
  // ===========================================================================

  Uri _uri(String path) {
    return Uri.parse('$baseUrl$path');
  }

  // ===========================================================================
  // PARSE RESPONSE
  // ===========================================================================

  Map<String, dynamic> _parse(http.Response res) {
    // -------------------------------------------------------------------------
    // 204 No Content
    // -------------------------------------------------------------------------
    //
    // DELETE غالباً يرجع 204 بدون body.
    //
    if (res.statusCode == 204 || res.body.trim().isEmpty) {
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return {};
      }

      throw ApiException(
        'حدث خطأ في الطلب',
        res.statusCode,
      );
    }

    // -------------------------------------------------------------------------
    // محاولة قراءة JSON
    // -------------------------------------------------------------------------

    Map<String, dynamic> body;

    try {
      final decoded = jsonDecode(res.body);

      if (decoded is Map<String, dynamic>) {
        body = decoded;
      } else {
        body = {};
      }
    } catch (_) {
      // إذا السيرفر رجع نص عادي وليس JSON
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return {};
      }

      throw ApiException(
        'استجابة غير صالحة من الخادم',
        res.statusCode,
      );
    }

    // -------------------------------------------------------------------------
    // SUCCESS
    // -------------------------------------------------------------------------

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }

    // -------------------------------------------------------------------------
    // ERROR
    // -------------------------------------------------------------------------

    final msg =
        body['message'] ??
        body['error'] ??
        (body['errors'] is Map
            ? (body['errors'] as Map).values.first.toString()
            : null) ??
        'خطأ ${res.statusCode}';

    throw ApiException(
      msg.toString(),
      res.statusCode,
    );
  }

  // ===========================================================================
  // GET
  // ===========================================================================

  Future<Map<String, dynamic>> get(String path) async {
    final res = await http.get(
      _uri(path),
      headers: _headers(),
    );

    return _parse(res);
  }

  // ===========================================================================
  // POST
  // ===========================================================================

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final res = await http.post(
      _uri(path),
      headers: _headers(auth: auth),
      body: jsonEncode(body),
    );

    return _parse(res);
  }

  // ===========================================================================
  // PATCH
  // ===========================================================================

  Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    final res = await http.patch(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body),
    );

    return _parse(res);
  }

  // ===========================================================================
  // DELETE
  // ===========================================================================

  Future<Map<String, dynamic>> delete(String path) async {
    final res = await http.delete(
      _uri(path),
      headers: _headers(),
    );

    return _parse(res);
  }
}

// ==============================================================================
// API EXCEPTION
// ==============================================================================

class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(
    this.message,
    this.statusCode,
  );

  @override
  String toString() => message;
}