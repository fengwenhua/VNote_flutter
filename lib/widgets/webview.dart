import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vnote/dao/onedrive_token_dao.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/provider/config_id_provider.dart';
import 'package:vnote/provider/data_list_provider.dart';
import 'package:vnote/provider/dir_and_file_cache_provider.dart';
import 'package:vnote/provider/notebooks_list_provider.dart';
import 'package:vnote/provider/parent_id_provider.dart';
import 'package:vnote/provider/token_provider.dart';
import 'package:vnote/utils/document_list_util.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/utils/navigator_util.dart';

import '../application.dart';

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

      if(url.contains("login.live.com/Me.htm")){
        Fluttertoast.showToast(
            msg: translate("requestLogin"),
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

      if(url.contains("logoutsession")){
        print("注销完成，可以去登录了");
        // 这里应该要清空本地 token
        webviewReference.reloadUrl("https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=fd49989c-b57c-49a4-9832-8172ae6a4162&scope=files.readwrite%20offline_access&response_type=code&redirect_uri=https://login.microsoftonline.com/common/oauth2/nativeclient");
      }
    });

    _onStateChanged =
        webviewReference.onStateChanged.listen((WebViewStateChanged state) {});

    // url打开错误或网络发生问题监听
    _onHttpError =
        webviewReference.onHttpError.listen((WebViewHttpError error) {
      print("出现错误?");
//      showAboutDialog(
//        context: context,
//        applicationName:'连接异常',
//        children: <Widget>[
//          Text('错误信息如下:'),
//          Text(error.toString()),
//        ],
//      );

//      Fluttertoast.showToast(
//          msg: "连接异常: " + error.toString() ,
//          toastLength: Toast.LENGTH_LONG,
//          gravity: ToastGravity.BOTTOM,
//          timeInSecForIosWeb: 3,
//          backgroundColor: Colors.red,
//          textColor: Colors.white,
//          fontSize: 16.0);
      print(error);
    });
  }

  /// 该方法在 splash_screen_page.dart 定义过一次
  Future<List<Document>> getNotebook(String accessToken) async {
    return await DocumentListUtil.instance.getNotebookList(context, accessToken,
            (list) async {
          ParentIdProvider parentIdModel =
          Provider.of<ParentIdProvider>(context, listen: false);
          DirAndFileCacheProvider dirCacheModel =
          Provider.of<DirAndFileCacheProvider>(context, listen: false);
          DataListProvider dataListModel =
          Provider.of<DataListProvider>(context, listen: false);
          ConfigIdProvider configIdModel =
          Provider.of<ConfigIdProvider>(context, listen: false);
          if (list.length == 0) {
            print("笔记本没有数据!");
            // 为毛没有数据我还要插入? 感觉这里有 bug
            dirCacheModel.addDirAndFileList(parentIdModel.parentId, list);
          } else {
            print("获取了笔记本List, 如下:");
            NotebooksProvider notebooksProvider =
            Provider.of<NotebooksProvider>(context, listen: false);
            notebooksProvider.updateList(list);

            // 这里应该用 SP,记录选择的笔记本的 id,如果没有则取list第一个
            String chooseNotebookId =
            Application.sp.getString("choose_notebook_id");
            String chooseNotebookName =
            Application.sp.getString("choose_notebook_name");

            // 同时需要判断从本地取出来的 id 是否真的存在, 不存在则取 list 第一个
            bool idIsValue = false;

            list.forEach((i) {
              print(i.name);
              if (i.id == chooseNotebookId) {
                idIsValue = true;
              }
            });

            // 本地有用户曾经选择过的笔记本 id,同时该笔记本还活着,没有被删掉
            if (chooseNotebookId == null || !idIsValue) {
              chooseNotebookId = list[0].id;
              chooseNotebookName = list[0].name;
            }

            await DocumentListUtil.instance
                .getChildList(context, accessToken, chooseNotebookId, (list) {})
                .then((data) {
              if (data == null) {
                print("获取的儿子为空, 不处理!");
              } else {
                print("在 splash_screen 页面, 获取的儿子有数据");
                parentIdModel.goAheadParentId(chooseNotebookId, chooseNotebookName);
                parentIdModel.setGenId(chooseNotebookId);

                dataListModel.goAheadDataList(data);
                for (Document d in dataListModel.dataList) {
                  if (d.name == "_vnote.json") {
                    configIdModel.updateConfigId(d.id);
                    break;
                  }
                }
                dirCacheModel.addDirAndFileList(chooseNotebookId, data);
              }
            });
          }
        });
  }

  void getTokenAndGoHomePage(String code) async {
    await OneDriveTokenDao.getToken(context, code).then((value) async {
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
//        appBar: AppBar(
//            title: Text('OneDrive登录', style: TextStyle(fontSize: fontSize40)),),
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