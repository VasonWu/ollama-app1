import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ollama_dart/ollama_dart.dart' as llama;

import '../main.dart';

class OllamaHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (_, __, ___) => true;
  }
}

class AuthHttpClient extends http.BaseClient {
  final http.Client _inner;

  AuthHttpClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // 在每个请求中添加 hostHeaders
    if (prefs != null) {
      final headersJson = prefs!.getString("hostHeaders") ?? "{}";
      final headers = jsonDecode(headersJson) as Map;
      final castedHeaders = headers.cast<String, String>();
      request.headers.addAll(castedHeaders);
    }
    return _inner.send(request);
  }
}

final httpClient = http.Client();
final authHttpClient = AuthHttpClient(httpClient);
llama.OllamaClient get ollamaClient => llama.OllamaClient(
    baseUrl: "$host/api",
    client: authHttpClient);
