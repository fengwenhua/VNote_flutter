import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vnote/application.dart';
import 'package:vnote/dao/onedrive_token_dao.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/provider/config_id_provider.dart';
import 'package:vnote/provider/data_list_provider.dart';
import 'package:vnote/provider/dir_and_file_cache_provider.dart';
import 'package:vnote/provider/local_document_provider.dart';
import 'package:vnote/provider/notebooks_list_provider.dart';
import 'package:vnote/provider/parent_id_provider.dart';
import 'package:vnote/provider/theme_provider.dart';
import 'package:vnote/provider/token_provider.dart';
import 'package:vnote/utils/document_list_util.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/utils/navigator_util.dart';
import 'package:vnote/utils/utils.dart';

class SplashScreenPage extends StatefulWidget {
  SplashScreenPage({Key key}) : super(key: key);

  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>
    with TickerProviderStateMixin {
  AnimationController _logoController;

  //double类型动画
  Animation<double> _logoAnimation;
  Tween _scaleTween;

  @override
  void initState() {
    super.initState();

    _scaleTween = Tween(begin: 0, end: 1);
    _logoController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..drive(_scaleTween);

    Future.delayed(Duration(milliseconds: 500), () {
      //启动动画
      _logoController.forward();
    });

    _logoAnimation =
        new Tween<double>(begin: 0, end: 0.8).animate(_logoController)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              Future.delayed(Duration(milliseconds: 500), () {
                goPage();
              });
            }
          });
  }

  /// 趁播放 logo 的时候, 将一级目录(笔记本)下载下来
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
            .getChildList(context, accessToken, chooseNotebookId,
                chooseNotebookName, (list) {})
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

  void goPage() async {
    // 初始化shared_preferences
    await Application.initSp();

    Provider.of<ThemeProvider>(context, listen: false).initTheme();
    Utils.setImageFolder();

    LocalDocumentProvider localDocumentProvider =
        Provider.of<LocalDocumentProvider>(context, listen: false);

    await Utils.model2ListDocument().then((data) {
      print("这里拿到 _myNote.json 的数据");
      localDocumentProvider.updateList(data);
    });

    // 第一次安装完后, 这里提示错误
    TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);
    // 从本地存储中读取token
    tokenModel.initToken();
    if (tokenModel.token != null) {
      print("本地有 token");

      Fluttertoast.showToast(
          msg: translate("splash.refreshToken"),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

      // 本地有token, 应该刷新一下token, 然后跳到主页
      await OneDriveTokenDao.refreshToken(
              context, tokenModel.token.refreshToken)
          .then((value) async {
        if (value.data != -1) {
          Fluttertoast.showToast(
              msg: translate("splash.getNotebook"),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          await getNotebook(tokenModel.token.accessToken).then((data) async {
            // 初始化, 爸爸是谁, 这里用 approot标记
            // 以后每点进去或者返回来, 都要刷新这个值
            //final _parentId =Provider.of<ParentIdModel>(context, listen: false);
            //_parentId.goAheadParentId("approot", "目录");

            // 权限申请
            await DocumentListUtil.instance.requestPermission();

            print("跳转到主页");
            NavigatorUtil.goHomePage(context);
          });
          // 跳转到主页
        }
      });
    } else {
      // 否则跳到微软登录界面
      // 权限申请
      await DocumentListUtil.instance.requestPermission();
      print("跳转到微软登录界面");
      NavigatorUtil.goLoginPage(context);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _logoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //ScreenUtil.init(context, width: 750, height: 1334);
    final size = MediaQuery.of(context).size;
    Application.screenWidth = size.width;
    Application.screenHeight = size.height;
    Application.statusBarHeight = MediaQuery.of(context).padding.top;
    Application.bottomBarHeight = MediaQuery.of(context).padding.bottom;

    return ScreenUtilInit(
        designSize: Size(750, 1334),
        builder: () => Scaffold(
              backgroundColor: Colors.white,
              body: Container(
                height: double.infinity,
                width: double.infinity,
                child: ScaleTransition(
                  scale: _logoAnimation,
                  child: Image.asset('assets/images/vnote.png'),
                ),
              ),
            ));
  }
}
