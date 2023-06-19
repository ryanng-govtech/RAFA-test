import 'dart:convert';

import 'package:http/http.dart';

class MyHttpClient extends BaseClient {
  final Map<String, String>? _defaultHeaders;
  final Client _httpClient = Client();

  MyHttpClient(this._defaultHeaders);

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return _httpClient.send(request);
  }

  @override
  Future<Response> get(url, {Map<String, String>? headers}) {
    return _httpClient.get(url, headers: _mergedHeaders(headers));
  }

  @override
  Future<Response> post(url,
      {Map<String, String>? headers, dynamic body, Encoding? encoding}) {
    return _httpClient.post(url,
        headers: _mergedHeaders(headers), body: body, encoding: encoding);
  }

  @override
  Future<Response> patch(url,
      {Map<String, String>? headers, dynamic body, Encoding? encoding}) {
    return _httpClient.patch(url,
        headers: _mergedHeaders(headers), body: body, encoding: encoding);
  }

  @override
  Future<Response> put(url,
      {Map<String, String>? headers, dynamic body, Encoding? encoding}) {
    return _httpClient.put(url,
        headers: _mergedHeaders(headers), body: body, encoding: encoding);
  }

  @override
  Future<Response> head(url, {Map<String, String>? headers}) {
    return _httpClient.head(url, headers: _mergedHeaders(headers));
  }

  @override
  Future<Response> delete(url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return _httpClient.delete(url, headers: _mergedHeaders(headers));
  }

  Map<String, String> _mergedHeaders(Map<String, String>? headers) =>
      {...?_defaultHeaders, ...?headers};
}
