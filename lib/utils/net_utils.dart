import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'dart:convert';

import 'package:path_provider/path_provider.dart';

class NetUtils {
  factory NetUtils() => _getInstance();

  static NetUtils get instance => _getInstance();
  static NetUtils _instance;

  NetUtils._internal();

  static NetUtils _getInstance() {
    if (_instance == null) {
      _instance = new NetUtils._internal();
    }
    return _instance;
  }

  static const String GET = "get";
  static const String POST = "post";

  /// download 请求
  Future<Response> download(BuildContext context, String url, Function callBack,
      {Map<String, String> params,
        Map<String, dynamic> headers,
        String path,
        Function errorCallBack}) async{
    print("要下载的url是: " + url);
    String errorMsg = "";
    int statusCode;
    try {
      Response response;
      var dio;
        dio = new Dio(new BaseOptions(
          connectTimeout: 5000,
          receiveTimeout: 10000,
          headers: headers,
          contentType: "application/x-www-form-urlencoded",
        ));

      if (params != null && params.isNotEmpty) {
        StringBuffer sb = new StringBuffer("?");
        params.forEach((key, value) {
          sb.write("$key" + "=" + "$value" + "&");
        });
        String paramStr = sb.toString();
        paramStr = paramStr.substring(0, paramStr.length - 1);
        url += paramStr;
      }
      response = await dio.download(url, path);
      statusCode = response.statusCode;
      if (statusCode < 0) {
        errorMsg = "网络请求错误,状态码:" + statusCode.toString();
        _handError(errorCallBack, errorMsg);
      }
      if (callBack != null) {
//        String res2Json = json.encode(response.data);
//        Map<String, dynamic> map = json.decode(res2Json);
//        callBack(map["data"]);
        callBack(response.toString());
      }
      return response;
    } catch (exception) {
      _handError(errorCallBack, exception.toString());
    }
  }

  /// get请求
  Future<Response> get(BuildContext context, String url, Function callBack,
      {Map<String, String> params,
      Map<String, dynamic> headers,
      Function errorCallBack}) async {
    return await _request(context, url, callBack,
        method: GET, params: params, headers: headers,errorCallBack: errorCallBack);
  }

  //post请求
  Future<Response> post(BuildContext context, String url, Function callBack,
      {Map<String, String> params,
      Map<String, dynamic> headers,
      Function errorCallBack}) async {
    return await _request(context, url, callBack,
        method: POST, params: params, errorCallBack: errorCallBack);
  }

  Future<Response> _request(BuildContext context, String url, Function callBack,
      {String method,
      Map<String, String> params,
      Map<String, dynamic> headers,
      Function errorCallBack}) async {
    print("传进来的url: " + url);
    String errorMsg = "";
    int statusCode;
    try {
      Response response;
      var dio;
      if (headers != null) {
        dio = new Dio(new BaseOptions(
          connectTimeout: 5000,
          receiveTimeout: 10000,
          headers: headers,
          contentType: "application/x-www-form-urlencoded",
        ));
      } else {
        dio = new Dio(new BaseOptions(
          connectTimeout: 5000,
          receiveTimeout: 10000,
          contentType: "application/x-www-form-urlencoded",
        ));
      }

      if (method == GET) {
        if (params != null && params.isNotEmpty) {
          StringBuffer sb = new StringBuffer("?");
          params.forEach((key, value) {
            sb.write("$key" + "=" + "$value" + "&");
          });
          String paramStr = sb.toString();
          paramStr = paramStr.substring(0, paramStr.length - 1);
          url += paramStr;
        }
        response = await dio.get(url);
      } else if (method == POST) {
        if (params != null && params.isNotEmpty) {
          response = await dio.post(url, data: params);
        } else {
          response = await dio.post(url);
        }
      }

      statusCode = response.statusCode;
      if (statusCode < 0) {
        errorMsg = "网络请求错误,状态码:" + statusCode.toString();
        _handError(errorCallBack, errorMsg);
      }
      if (callBack != null) {
//        String res2Json = json.encode(response.data);
//        Map<String, dynamic> map = json.decode(res2Json);
//        callBack(map["data"]);
        callBack(response.toString());
      }
      return response;
    } catch (exception) {
      _handError(errorCallBack, exception.toString());
    }
  }

  void _handError(Function errorCallBack, String errorMsg) {
    if (errorCallBack != null) {
      errorCallBack(errorMsg);
    }
  }
}
