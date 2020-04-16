import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vnote/dao/onedrive_token_dao.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/provider/data_list_model.dart';
import 'package:vnote/provider/dir_and_file_cache_model.dart';
import 'package:vnote/provider/token_model.dart';
import 'package:vnote/utils/document_list_util.dart';
import 'package:vnote/utils/navigator_util.dart';

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
    //HttpCore.init();
    // 防止页面重新打开
    webviewReference.close();

    // 页面url变化监听
    _onUrlChanged = webviewReference.onUrlChanged.listen((String url) {
      print("url变了: " + url);
      if(url.contains("username")){
        Fluttertoast.showToast(
            msg: translate("requestsTips"),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }

      if (url.contains("code=")) {
        // 这里要解析code出来
        String code = url?.split("code=")[1];
        print(code);
        if (code != null) {
          getTokenAndGoHomePage(code);
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
      Fluttertoast.showToast(msg: "没联网! 请重启 app 试试!");
      print(error);
    });
  }

  /// 该方法在 splash_screen_page.dart 定义过一次
  Future<List<Document>> getNotebook(String accessToken) async{
    return await DocumentListUtil.instance.getNotebookList(context, accessToken, (list){
      DirAndFileCacheModel dirCacheModel = Provider.of<DirAndFileCacheModel>(context, listen: false);
      if(list.length==0){
        print("笔记本莫得数据!");
        dirCacheModel.addDirAndFileList("approot", null);
      }else{
        print("获取了笔记本List, 如下:");
        list.forEach((i) {
          print(i.name);
        });
        DataListModel dataListModel = Provider.of<DataListModel>(context, listen: false);
        dataListModel.goAheadDataList(list);

        dirCacheModel.addDirAndFileList("approot", list);
      }

    });
  }

  void getTokenAndGoHomePage(String code) async {
    await OnedriveTokenDao.getToken(context, code).then((value) async {
      // 拿到 token 之后, 应该获取根列表, 然后跳转到主页
      TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);
      await getNotebook(tokenModel.token.accessToken).then((data){
        print("跳转到主页");
        NavigatorUtil.goHomePage(context);
      });
      //NavigatorUtil.goHomePage(context);
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
    return Scaffold(
        body: WebviewScaffold(
      url: widget.url,
      withZoom: false,
      withLocalStorage: false,
      clearCache: true,
      clearCookies: true,
      hidden: true,
      initialChild: Container(
        color: Colors.white,
        child: Center(
          child: Text("等待 Onedrive 响应中..."),
        ),
      ),
    ));
  }
}
