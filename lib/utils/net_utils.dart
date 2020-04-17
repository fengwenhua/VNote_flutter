import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  Future<Response> delete(BuildContext context, String url, Function callBack,
      {Map<String, dynamic> headers, Function errorCallBack}) async {
    String errorMsg = "";
    int statusCode;
    bool chucuo = false;
    while (true) {
      try {
        Response response;
        var dio;
        dio = new Dio(new BaseOptions(
          method: "delete",
          connectTimeout: 20000,
          headers: headers,
          contentType: "text/plain",
        ));

        response = await dio.delete(url);
        statusCode = response.statusCode;

        if (statusCode < 0) {
          errorMsg = "网络请求错误,状态码:" + statusCode.toString();
          _handError(errorCallBack, errorMsg);
        }
        if (callBack != null) {
          callBack(response.toString(), statusCode.toString());
        }
        return response;
      } catch (exception) {
        chucuo = true;
        _handError(errorCallBack, exception.toString());
      }

      if (!chucuo) {
        break;
      }
      print("delete 的时候出现异常, 再来一发!");
    }
  }

  Future<Response> patch(BuildContext context, String url, Function callBack,
      {Map<String, dynamic> headers,
      dynamic content,
      Function errorCallBack}) async {
    String errorMsg = "";
    int statusCode;
    bool chucuo = false;
    while (true) {
      try {
        Response response;
        var dio;
        dio = new Dio(new BaseOptions(
          method: "patch",
          connectTimeout: 20000,
          headers: headers,
          contentType: "application/json",
        ));
        response = await dio.patch(url, data: content);
        statusCode = response.statusCode;

        if (statusCode < 0) {
          errorMsg = "网络请求错误,状态码:" + statusCode.toString();
          _handError(errorCallBack, errorMsg);
        }
        if (callBack != null) {
          callBack(response.toString());
        }
        return response;

      } catch (exception) {
        chucuo = true;
        _handError(errorCallBack, exception.toString());
      }
      if (!chucuo) {
        break;
      }
      print("patch 的时候出现异常, 再来一发!");
    }
  }

  /// put 请求, 用于文章内容更新, 图片上传
  Future<Response> put(BuildContext context, String url, Function callBack,
      {Map<String, dynamic> headers,
      dynamic content,
      Function errorCallBack}) async {
    String errorMsg = "";
    int statusCode;
    bool chucuo = false;
    while (true) {
      try {
        Response response;
        var dio;
        dio = new Dio(new BaseOptions(
          method: "put",
          connectTimeout: 20000,
          headers: headers,
          contentType: "text/plain",
        ));

        response = await dio.put(url, data: content);
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
        chucuo = true;
        _handError(errorCallBack, exception.toString());
      }
      if (!chucuo) {
        break;
      }
      print("put 的时候出现异常, 再来一发!");
    }
  }

  /// download 请求, 用于图片下载
  Future<Response> download(BuildContext context, String url, Function callBack,
      {Map<String, String> params,
      Map<String, dynamic> headers,
      String path,
      Function errorCallBack}) async {
    print("要下载的url是: " + url);
    String errorMsg = "";
    int statusCode;
    try {
      Response response;
      var dio;
      dio = new Dio(new BaseOptions(
        connectTimeout: 20000,
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
        method: GET,
        params: params,
        headers: headers,
        errorCallBack: errorCallBack);
  }

  //post请求
  Future<Response> post(BuildContext context, String url, Function callBack,
      {Map<String, String> params,
      Map<String, dynamic> headers,
      Function errorCallBack,
      String contentType = "application/x-www-form-urlencoded",
      String data}) async {
    return await _request(context, url, callBack,
        headers: headers,
        method: POST,
        params: params,
        errorCallBack: errorCallBack,
        contentType: contentType,
        data: data);
  }

  Future<Response> _request(BuildContext context, String url, Function callBack,
      {String method,
      Map<String, String> params,
      Map<String, dynamic> headers,
      Function errorCallBack,
      String contentType,
      String data}) async {
    print("传进来的url: " + url);
    String errorMsg = "";
    int statusCode;
    bool chucuo = false;
    while (true) {
      try {
        Response response;
        var dio;
        if (headers != null) {
          //print("有 headers");
          //print(headers.toString());
          dio = new Dio(new BaseOptions(
            connectTimeout: 20000,
            receiveTimeout: 20000,
            headers: headers,
            contentType: contentType,
          ));
        } else {
          dio = new Dio(new BaseOptions(
            connectTimeout: 20000,
            receiveTimeout: 20000,
            contentType: contentType,
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
          } else if (data != null && data.isNotEmpty) {
            //print("创建文件夹的 post");
            response = await dio.post(url, data: data);
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
        chucuo = true;
        _handError(errorCallBack, exception.toString());
        if(exception.toString().contains("[404]")){
          chucuo = false;
          Fluttertoast.showToast(
              msg: "该资源已经从服务器中删除了~~~",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white);
        }
      }
      if (!chucuo) {
        break;
      }
      print("requests 出现异常, 再来一发!!!");
      Fluttertoast.showToast(
          msg: translate("networkErrorTips"),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor:  Colors.red,
          textColor:  Colors.white);

    }
  }

  void _handError(Function errorCallBack, String errorMsg) {
    if (errorCallBack != null) {
      errorCallBack(errorMsg);
    }
  }
}
