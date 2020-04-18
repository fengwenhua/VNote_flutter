import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/utils/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MarkdownWebViewPage extends StatefulWidget {
  const MarkdownWebViewPage({
    Key key,
    @required this.title,
    @required this.content,
  }) : super(key: key);

  final String title;
  final String content;

  @override
  _MarkdownWebViewPageState createState() => _MarkdownWebViewPageState();
}

class _MarkdownWebViewPageState extends State<MarkdownWebViewPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    print("markdown_webview 重新 build 了");
    return FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (context, snapshot) {
          return WillPopScope(
            onWillPop: () async {
              if (snapshot.hasData) {
                bool canGoBack = await snapshot.data.canGoBack();
                if (canGoBack) {
                  // 网页可以返回时，优先返回上一页
                  snapshot.data.goBack();
                  return Future.value(false);
                }
              }
              return Future.value(true);
            },
            child: Scaffold(
                appBar: AppBar(
                    title: Text(widget.title,
                        style: TextStyle(fontSize: fontSize40)),
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )),
                body: WebView(
                  initialUrl:
                      'data:text/html;charset=utf-8;base64,${base64Encode(const Utf8Encoder().convert(widget.content))}',
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller.complete(webViewController);
                  },
                )),
          );
        });
  }
}
