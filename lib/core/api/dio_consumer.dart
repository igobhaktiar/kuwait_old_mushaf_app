import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:quran_app/injection_container.dart' as di;

import '../error/exceptions.dart';
import '../utils/app_strings.dart';
import 'app_interceptors.dart';
import 'end_points.dart';
import 'status_code.dart';

class DioConsumer {
  final Dio client;

  DioConsumer({required this.client}) {
    (client.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    String currentBaseUrl =
        EndPoints.getBaseUrlAccordingToBuildTarget(di.getItInstance());
    client.options
      ..baseUrl = currentBaseUrl
      ..headers = {
        'Authorization':
            'Basic ${base64.encode(utf8.encode('${AppStrings.userName}:${AppStrings.password}'))}',
        'Content-Type': 'application/json'
      }
      ..responseType = ResponseType.plain
      ..validateStatus = (status) {
        return status! < StatusCode.internalServerError;
      };

    client.httpClientAdapter = DefaultHttpClientAdapter()
      ..onHttpClientCreate = (client) => client..maxConnectionsPerHost = 3;

    client.interceptors.add(di.getItInstance<AppIntercepters>());
    if (kDebugMode) {
      client.interceptors.add(di.getItInstance<LogInterceptor>());
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    (client.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient dioClient) {
      dioClient.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
      return dioClient;
    };
    return await client.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path,
      {Map<String, dynamic>? body,
      bool formDataIsEnabled = false,
      Map<String, dynamic>? queryParameters}) async {
    return await client.post(path,
        queryParameters: queryParameters,
        data: formDataIsEnabled ? FormData.fromMap(body!) : body);
  }

  Future<Response> download({
    required String remoteUrl,
    required String storagePath,
    void Function(int, int)? onRecieveProgress,
  }) async {
    try {
      Dio dio = Dio();
      // return await client.download(remoteUrl, storagePath,
      //     onReceiveProgress: onRecieveProgress, deleteOnError: true);
      return await dio.download(remoteUrl, storagePath,
          onReceiveProgress: onRecieveProgress, deleteOnError: true);
    } catch (e) {
      debugPrint(e.toString());
      if (File(storagePath).existsSync()) {
        File(storagePath).deleteSync();
        log("salem deleted file ${storagePath}");
        return Response(requestOptions: RequestOptions());
      }
    }
    return Response(requestOptions: RequestOptions());
  }

  Future put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response =
          await client.put(path, queryParameters: queryParameters, data: body);
      return _handleResponseAsJson(response);
    } on DioError catch (error) {
      _handleDioError(error);
    }
  }

  Future head(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response =
          await client.head(path, queryParameters: queryParameters, data: body);
      return response;
    } on DioError catch (error) {
      _handleDioError(error);
    }
  }

  dynamic _handleResponseAsJson(Response<dynamic> response) {
    final responseJson = jsonDecode(response.data.toString());
    return responseJson;
  }

  dynamic _handleDioError(DioError error) {
    switch (error.type) {
      case DioErrorType.connectionError:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        throw const FetchDataException();
      case DioErrorType.badResponse:
        switch (error.response?.statusCode) {
          case StatusCode.badRequest:
            throw const BadRequestException();
          case StatusCode.unauthorized:
          case StatusCode.forbidden:
            throw const UnauthorizedException();
          case StatusCode.notFound:
            throw const NotFoundException();
          case StatusCode.confilct:
            throw const ConflictException();

          case StatusCode.internalServerError:
            throw const InternalServerErrorException();
        }
        break;
      case DioErrorType.cancel:
        break;
      case DioErrorType.unknown:
        throw const NoInternetConnectionException();
      case DioExceptionType.connectionTimeout:
        // TODO: Handle this case.
        throw UnimplementedError();
      case DioExceptionType.badCertificate:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
