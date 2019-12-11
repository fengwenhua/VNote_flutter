import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

import 'dart:convert';

import 'package:path_provider/path_provider.dart';

class HttpCore {
  static final String baseurl =
      "https://login.microsoftonline.com/common/oauth2/v2.0/token";

  factory HttpCore() => _getInstance();

  static HttpCore get instance => _getInstance();
  static HttpCore _instance;

  HttpCore._internal();

  static HttpCore _getInstance() {
    if (_instance == null) {
      _instance = new HttpCore._internal();
    }
    return _instance;
  }

  static const String GET = "get";
  static const String POST = "post";

  //get请求
  void get(String url, Function callBack,
      {Map<String, String> params,
      Map<String, dynamic> headers,
      Function errorCallBack}) async {
    _request(url, callBack,
        method: GET, params: params, errorCallBack: errorCallBack);
  }

  //post请求
  void post(String url, Function callBack,
      {Map<String, String> params,
      Map<String, dynamic> headers,
      Function errorCallBack}) async {
    _request(url, callBack,
        method: POST, params: params, errorCallBack: errorCallBack);
  }

  void _request(String url, Function callBack,
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
          print("返回数据如下:");
          print(response);
        } else {
          response = await dio.post(url);
        }
      }

      statusCode = response.statusCode;
      if (statusCode < 0) {
        errorMsg = "网络请求错误,状态码:" + statusCode.toString();
        _handError(errorCallBack, errorMsg);
        return;
      }
      if (callBack != null) {
//        String res2Json = json.encode(response.data);
//        Map<String, dynamic> map = json.decode(res2Json);
//        callBack(map["data"]);
        callBack(response.toString());
      }
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
