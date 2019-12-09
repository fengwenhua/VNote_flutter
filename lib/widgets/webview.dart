import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/utils/net_utils.dart';

class WebView extends StatefulWidget {
  final String url;
  final String statusBarColor;
  final String title;
  final bool hideAppBar;
  final bool backForbid;

  WebView(
      {this.url,
      this.statusBarColor,
      this.title,
      this.hideAppBar,
      this.backForbid = false});

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  // 导入插件
  final webviewReference = FlutterWebviewPlugin();
  StreamSubscription<String> _onUrlChanged;
  StreamSubscription<WebViewStateChanged> _onStateChanged;
  StreamSubscription<WebViewHttpError> _onHttpError;
  bool exiting = false; // 返回标志位

  @override
  void initState() {
    super.initState();
    // 防止页面重新打开
    webviewReference.close();

    // 页面url变化监听
    _onUrlChanged = webviewReference.onUrlChanged.listen((String url) {
      print("url变了: " + url);
      if (url.contains("code=")) {
        // 这里要解析code出来
        String code = url?.split("code=")[1];
        print(code);
        if (code != null) {
          Map<String, String> params = {
            "client_id": CLIENT_ID,
            "redirect_uri": REDIRECT_URL,
            "code": code,
            "grant_type":"authorization_code"
          };

          HttpCore.instance.post(
              "https://login.microsoftonline.com/common/oauth2/v2.0/token",
              (data) {
                print("返回来的数据如下: " + data);
              },
              params: params,
              errorCallBack: (errorMsg) {
                print("error: " + errorMsg);
                return null;
              });
        } else {
          print("code 没有解析出来? " + url);
          return null;
        }
      }
    });

    _onStateChanged =
        webviewReference.onStateChanged.listen((WebViewStateChanged state) {});

    // url打开错误或网络发生问题监听
    _onHttpError =
        webviewReference.onHttpError.listen((WebViewHttpError error) {
      print("出现错误?");
      print(error);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    _onHttpError.cancel();
    webviewReference.dispose();
    print("WebView销毁完成");
  }

  @override
  Widget build(BuildContext context) {
    String statusBarColorStr = widget.statusBarColor ?? 'ffffff';
    // 返回按钮颜色
    Color backButtonColor;
    if (statusBarColorStr == 'ffffff') {
      backButtonColor = Colors.black;
    } else {
      backButtonColor = Colors.white;
    }
    return Scaffold(
        body: WebviewScaffold(
      url: widget.url,
      appBar: AppBar(
        title: Text("Widget Webview"),
      ),
      withZoom: true,
      withLocalStorage: true,
      hidden: true,
      initialChild: Container(
        color: Colors.white,
        child: Center(
          child: Text("Wating..."),
        ),
      ),
    ));
  }
}
