// FILE: lib/core/network/api_client.dart
// STATUS: [x] LIVE (B7 — 2026-07-04)
// PURPOSE: Single HTTP entry point — every network request goes through this
//          client. Timeout, headers, error mapping and logging live here once.
//          VOX is offline-first: callers must degrade gracefully (see
//          cache_service.dart getStale pattern).
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../services/app_logger.dart';

sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => 'ApiException: $message';
}

class ApiNetworkException extends ApiException {
  const ApiNetworkException() : super('no connectivity');
}

class ApiTimeoutException extends ApiException {
  const ApiTimeoutException() : super('request timed out');
}

class ApiHttpException extends ApiException {
  const ApiHttpException(this.statusCode) : super('HTTP error');
  final int statusCode;

  @override
  String toString() => 'ApiException: HTTP $statusCode';
}

class ApiClient {
  ApiClient({http.Client? inner, AppLogger? logger})
      : _inner  = inner ?? http.Client(),
        _logger = logger ?? const AppLogger('ApiClient');

  static const _timeout = Duration(seconds: 15);
  // Kein eigener User-Agent-Header — Browser blockieren ihn (unsafe header).

  final http.Client _inner;
  final AppLogger   _logger;

  /// Plain text / XML body (RSS feeds).
  Future<String> getText(Uri url) async {
    final res = await _get(url);
    return res.body;
  }

  /// Decoded JSON object.
  Future<Map<String, dynamic>> getJson(Uri url) async {
    final res = await _get(url);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<http.Response> _get(Uri url) async {
    _logger.d('GET $url');
    try {
      final res = await _inner.get(url).timeout(_timeout);
      _logger.d('${res.statusCode} $url (${res.body.length} bytes)');
      if (res.statusCode != 200) throw ApiHttpException(res.statusCode);
      return res;
    } on TimeoutException {
      _logger.w('timeout $url');
      throw const ApiTimeoutException();
    } on http.ClientException catch (e) {
      // Offline, DNS oder CORS — im Browser meldet package:http alle Netzfehler so.
      _logger.w('client error $url — $e');
      throw const ApiNetworkException();
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
