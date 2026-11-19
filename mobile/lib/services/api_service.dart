import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });
}

class ApiService {
  static const Duration _timeout = Duration(seconds: 15);

  /// Header default request
  static Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth) {
      final token = await StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  /// Request HTTP GET
  static Future<ApiResponse> get(String url, {bool withAuth = true}) async {
    try {
      final headers = await _getHeaders(withAuth: withAuth);
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(_timeout);

      return _processResponse(response);
    } on http.ClientException {
      return ApiResponse(
        success: false,
        message: 'Tidak dapat terhubung ke server backend. Periksa koneksi jaringan atau server.',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan jaringan: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Request HTTP POST
  static Future<ApiResponse> post(
    String url, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(withAuth: withAuth);
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return _processResponse(response);
    } on http.ClientException {
      return ApiResponse(
        success: false,
        message: 'Tidak dapat terhubung ke server backend.',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan jaringan: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Request HTTP PUT
  static Future<ApiResponse> put(
    String url, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(withAuth: withAuth);
      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return _processResponse(response);
    } on http.ClientException {
      return ApiResponse(
        success: false,
        message: 'Tidak dapat terhubung ke server backend.',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan jaringan: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Request HTTP PATCH
  static Future<ApiResponse> patch(
    String url, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(withAuth: withAuth);
      final response = await http
          .patch(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return _processResponse(response);
    } on http.ClientException {
      return ApiResponse(
        success: false,
        message: 'Tidak dapat terhubung ke server backend.',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan jaringan: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Request HTTP DELETE
  static Future<ApiResponse> delete(String url, {bool withAuth = true}) async {
    try {
      final headers = await _getHeaders(withAuth: withAuth);
      final response = await http
          .delete(Uri.parse(url), headers: headers)
          .timeout(_timeout);

      return _processResponse(response);
    } on http.ClientException {
      return ApiResponse(
        success: false,
        message: 'Tidak dapat terhubung ke server backend.',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan jaringan: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Menguraikan response JSON dari server backend
  static ApiResponse _processResponse(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        final success = decoded['success'] == true;
        final message = decoded['message'] ?? 'Respons diterima';
        final data = decoded['data'];

        return ApiResponse(
          success: success,
          message: message,
          data: data,
          statusCode: response.statusCode,
        );
      }
    } catch (_) {
      // Jika respons bukan format JSON standar
    }

    return ApiResponse(
      success: response.statusCode >= 200 && response.statusCode < 300,
      message: 'Status HTTP ${response.statusCode}',
      data: response.body,
      statusCode: response.statusCode,
    );
  }
}
