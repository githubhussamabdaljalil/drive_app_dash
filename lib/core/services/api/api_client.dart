import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/local_storage_service.dart';

/// Central HTTP client — Bearer token auth
/// Base URL: https://vehicles-tracking-production-z593lf.laravel.cloud/api
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const String baseUrl =
      'https://vehicles-tracking-production-z593lf.laravel.cloud/api';

  // ── helpers ──────────────────────────────────────────────────────────

  Map<String, String> _headers({bool auth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = LocalStorageService.instance.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, dynamic> _parse(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    final msg = body['message'] ?? body['error'] ?? 'خطأ ${res.statusCode}';
    throw ApiException(msg.toString(), res.statusCode);
  }

  // ── HTTP verbs ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> get(String path) async {
    final res = await http.get(_uri(path), headers: _headers());
    return _parse(res);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    final res = await http.post(_uri(path),
        headers: _headers(auth: auth), body: jsonEncode(body));
    return _parse(res);
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) async {
    final res = await http.patch(_uri(path),
        headers: _headers(), body: jsonEncode(body));
    return _parse(res);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final res = await http.delete(_uri(path), headers: _headers());
    return _parse(res);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}
