import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adguard_home_manager/config/logger.dart';
import 'package:adguard_home_manager/models/server.dart';

enum ExceptionType { socket, timeout, handshake, http, unknown }

class HttpResponse {
  final bool successful;
  final String? body;
  final int? statusCode;
  final ExceptionType? exception;

  const HttpResponse({
    required this.successful,
    required this.body,
    required this.statusCode,
    this.exception,
  });
}

String getConnectionString({
  required Server server,
  required String urlPath,
}) {
  return "${server.connectionMethod}://${server.domain}${server.port != null ? ':${server.port}' : ""}${server.path ?? ""}/control$urlPath";
}

class HttpRequestClient {
  static Future<HttpResponse> get({
    required String urlPath,
    required Server server,
    int timeout = 10,
  }) async{
    final String connectionString = getConnectionString(server: server, urlPath: urlPath);
    try {
      HttpClient httpClient = HttpClient();
      HttpClientRequest request = await httpClient.getUrl(Uri.parse(connectionString));
      if (server.authToken != null) {
        request.headers.set('Authorization', 'Basic ${server.authToken}');
      }
      HttpClientResponse response = await request.close().timeout(
        Duration(seconds: timeout)
      );
      String reply = await response.transform(utf8.decoder).join();
      // logger.d("HTTP GET => $connectionString \nRESPONSE => $reply");
      httpClient.close();
      return HttpResponse(
        successful: response.statusCode >= 400 ? false : true, 
        body: reply, 
        statusCode: response.statusCode
      );   
    } on SocketException {
      return const HttpResponse(
        successful: false, 
        body: null, 
        statusCode: null,
        exception: ExceptionType.socket
      );   
    } on TimeoutException {
      return const HttpResponse(
        successful: false, 
        body: null, 
        statusCode: null,
        exception: ExceptionType.timeout
      );  
    } on HandshakeException {
      return const HttpResponse(
        successful: false, 
        body: null, 
        statusCode: null,
        exception: ExceptionType.handshake
      );  
    } on HttpException {
      return const HttpResponse(
        successful: false, 
        body: null, 
        statusCode: null,
        exception: ExceptionType.http
      );  
    } catch (e) {
      return const HttpResponse(
        successful: false, 
        body: null, 
        statusCode: null,
        exception: ExceptionType.unknown
      );  
    }
  }

  static Future<HttpResponse> post({
    required String urlPath,
    required Server server,
    dynamic body,
    int timeout = 10,
  }) async{
    final String connectionString = getConnectionString(server: server, urlPath: urlPath);
    try {
      HttpClient httpClient = HttpClient();
      HttpClientRequest request = await httpClient.postUrl(Uri.parse(connectionString));
      if (server.authToken != null) {
        request.headers.set('Authorization', 'Basic ${server.authToken}');
      }
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(json.encode(body)));
      HttpClientResponse response = await request.close().timeout(
        Duration(seconds: timeout)
      );
      String reply = await response.transform(utf8.decoder).join();
      httpClient.close();
      return HttpResponse(
        successful: response.statusCode >= 400 ? false : true, 
        body: reply, 
        statusCode: response.statusCode
      );  
    } on SocketException {
      return const HttpResponse(
        successful: false, 
        body: null, 
        statusCode: null,
        exception: ExceptionType.socket
      );   
    } on TimeoutException {
      return const HttpResponse(
        successful: false, 
        body: null, 
        statusCode: null,
        exception: ExceptionType.timeout
      );  
    } on HttpException {
      return const HttpResponse(
        successful: false, 
        body: null, 
        statusCode: null,
        exception: ExceptionType.http
      );  
    } on HandshakeException {
      return const HttpResponse(
        successful: false, 
        body: null, 
        statusCode: null,
        exception: ExceptionType.handshake
      );  
    } catch (e) {
      return const HttpResponse(
        successful: false, 
        body: null, 
        statusCode: null,
        exception: ExceptionType.unknown
      );  
    }
  }

  static Future<HttpResponse> put({
    required String urlPath,
    required Server server,
    dynamic body,
    int timeout = 10,
  }) async{
    final String connectionString = getConnectionString(server: server, urlPath: urlPath);
    try {
      HttpClient httpClient = HttpClient();
      HttpClientRequest request = await httpClient.putUrl(Uri.parse(connectionString));
      if (server.authToken != null) {
        request.headers.set('Authorization', 'Basic ${server.authToken}');
      }
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(json.encode(body)));
      HttpClientResponse response = await request.close().timeout(
        Duration(seconds: timeout)
      );
      String reply = await response.transform(utf8.decoder).join();
      httpClient.close();
      return HttpResponse(
        successful: response.statusCode >= 400 ? false : true, 
        body: reply, 
        statusCode: response.statusCode
      );  
    } on SocketException {
      return const HttpResponse(
        successful: false, 
        body: null, 
        statusCode: null,
        exception: ExceptionType.socket
      );   
    } on TimeoutException {
      return const HttpResponse(
        successful: false, 
        body: null, 
        statusCode: null,
        exception: ExceptionType.timeout
      );  
    } on HttpException {
      return const HttpResponse(
        successful: false, 
        body: null, 
        statusCode: null,
        exception: ExceptionType.http
      );  
    } on HandshakeException {
      return const HttpResponse(
        successful: false, 
        body: null, 
        statusCode: null,
        exception: ExceptionType.handshake
      );  
    } catch (e) {
      return const HttpResponse(
        successful: false, 
        body: null, 
        statusCode: null,
        exception: ExceptionType.unknown
      );  
    }
  }
}