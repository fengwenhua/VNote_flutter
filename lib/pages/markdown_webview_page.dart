import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:vnote/application.dart';
import 'package:vnote/provider/config_id_provider.dart';
import 'package:vnote/provider/data_list_provider.dart';
import 'package:vnote/provider/image_folder_id_provider.dart';
import 'package:vnote/provider/token_provider.dart';
import 'package:vnote/utils/document_list_util.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/utils/log_util.dart';
import 'package:vnote/utils/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MarkdownWebViewPage extends StatefulWidget {
  const MarkdownWebViewPage(
      {Key key,
      @required this.title,
      @required this.htmlPath,
      this.id,
      this.configId,
      this.imageFolderId})
      : super(key: key);

  final String id;
  final String configId;
  final String imageFolderId;
  final String title;
  final String htmlPath;

  @override
  _MarkdownWebViewPageState createState() => _MarkdownWebViewPageState();
}

class _MarkdownWebViewPageState extends State<MarkdownWebViewPage> {
  String name;
  ProgressDialog pr1;
  Completer<WebViewController> _controller = Completer<WebViewController>();
  WebViewController webViewController;

  @override
  void initState() {
    super.initState();
    print("markdown_webview_page::initState()");
    print("传过来的内容如下:");
    print("id: ");
    print(widget.id);
    print("titile: ");
    print(widget.title);
    print("configId: ");
    print(widget.configId);
    print("imageFolderId: ");
    print(widget.imageFolderId);
    print("content 长度: ");
    print(widget.htmlPath.length);
    name = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    pr1 = new ProgressDialog(context, type: ProgressDialogType.Normal);
    print("markdown_webview 重新 build 了");
    return FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (context, snapshot) {
          return Scaffold(
              appBar: AppBar(
                title:
                    Text(widget.title, style: TextStyle(fontSize: fontSize40)),
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                  ),
                  onPressed: () async {
                    //Navigator.pop(context);
                    if (snapshot.hasData) {
                      bool canGoBack = await snapshot.data.canGoBack();
                      print("有的返回码? " + canGoBack.toString());
                      if (canGoBack) {
                        // 网页可以返回时，优先返回上一页
                        snapshot.data.goBack();
                      } else {
                        Navigator.of(context).pop();
                      }
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.cached),
                    color: Colors.white,
                    onPressed: () async {
                      print("点击刷新了");
                      pr1 = new ProgressDialog(context, type: ProgressDialogType.Normal);
                      await pr1.show().then((_) {
                        _updateMDFile(widget.id, widget.title, widget.configId,
                            widget.imageFolderId);
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    color: Colors.white,
                    onPressed: () {
                      print("点击编辑");
                      // 1 代表新建
                      String route = "";

                      route =
                          '/edit?content=${Uri.encodeComponent(Application.sp.getString(widget.id))}&id=${Uri.encodeComponent(widget.id)}&name=${Uri.encodeComponent(widget.title)}';
                      Application.router
                          .navigateTo(context, route,
                              transition: TransitionType.fadeIn)
                          .then((result) async {
                        print("获取从编辑页面返回的数据");
                        //print(result);
                        await Utils.getMarkdownHtml(name, result.toString())
                            .then((htmlPath) {
                          this.webViewController.loadUrl(htmlPath.toString());
                        });
                      });
                    },
                  ),
                ],
              ),
              body: WebView(
                initialUrl: widget.htmlPath,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  this.webViewController = webViewController;
                  //_controller.complete(webViewController);
                  //this.webViewController.loadUrl('data:text/html;charset=utf-8;base64,${base64Encode(const Utf8Encoder().convert(content))}');

                  //this.webViewController.loadUrl(Uri.dataFromString(content, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString());
                },
                onPageFinished: (data) {
                  print("页面加载完成后, 页面的源代码!");
                  this
                      .webViewController
                      .evaluateJavascript('returnSource()')
                      .then((result) {
                    //LogUtil.e(result);
                  });
                },
              ));
        });
  }

  /// 点击更新按钮, 更新 md 文件
  _updateMDFile(
      String id, String name, String configId, String imageFolderId) async {
    TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);
    DataListProvider dataListModel =
        Provider.of<DataListProvider>(context, listen: false);
    final _imageFolderIdModel =
        Provider.of<ImageFolderIdProvider>(context, listen: false);
    ConfigIdProvider configIdModel =
        Provider.of<ConfigIdProvider>(context, listen: false);
    // 点进来, 可能是文件夹那里点, 也可能是笔记那里点
    print("markdown_webview_page 直接赋值 configId 和 imageFolderId");
    configIdModel.updateConfigId(configId);
    _imageFolderIdModel.updateImageFolderId(imageFolderId);

    print("开始找图片");
//    for (Document d in dataListModel.dataList) {
//      if (d.name == "_v_images") {
//        // 在这里更新 imageFolderid , 也就是 _v_images 文件夹的 id
//        // 这里再次更新是为了预防某个叼毛, 将_v_images 干掉...
//
//        _imageFolderIdModel.updateImageFolderId(d.id);
//        break;
//      }
//    }

    print("准备从网络获取 md 内容");
    await DocumentListUtil.instance
        .getMDFileContentFromNetwork(
            context, tokenModel.token.accessToken, id, pr1)
        .then((value) {
      if (value == null) {
        print("gg, 拿不到更新的数据1");
        if (pr1.isShowing()) {
          pr1.hide();
        }

        Fluttertoast.showToast(
            msg: "网络超时, 拿不到更新的数据",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        print("拿到更新的数据");
        pr1.hide().whenComplete(() async {
          // 这里需要修改
          await Utils.getMarkdownHtml(name, value.toString()).then((htmlPath) {
            this.webViewController.loadUrl(htmlPath.toString());
          });
        });
      }
    });
  }
}
