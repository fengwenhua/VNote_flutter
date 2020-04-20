import 'package:dio/dio.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:vnote/application.dart';
import 'package:vnote/dao/onedrive_data_dao.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/models/onedrive_data_model.dart';
import 'package:vnote/provider/config_id_model.dart';
import 'package:vnote/provider/data_list_model.dart';
import 'package:vnote/provider/image_folder_id_model.dart';
import 'package:vnote/provider/token_model.dart';
import 'package:vnote/utils/document_list_util.dart';
import 'package:vnote/utils/utils.dart';
import 'package:vnote/widgets/file_widget.dart';
import 'package:flutter_translate/flutter_translate.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(translate("search.appbar")), actions: <Widget>[
        // 放大镜效果
        IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: SearchBarDelegate());
            }),
      ]),
      body: Center(
        child: Text(translate("search.tips")),
      ),
    );
  }
}

List<String> searchList = [
  "wangcai",
  "wangcai1",
  "xiaoxianrou",
  "dachangtui",
  "nvfengsi"
];

List<String> recentSuggest = ["搜索推荐 1", "搜索推荐 2"];

class SearchBarDelegate extends SearchDelegate<String> {
  //初始化加载
  //重写右侧的图标
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        //将搜索内容置为空
        onPressed: () => query = "",
      )
    ];
  }

  //重写返回图标
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      //关闭上下文，当前页面
      onPressed: () {
        // 如果搜索框没有内容则直接返回
        // 如果有内容则清空搜索框,然后显示搜索建议
        if (query.isEmpty) {
          close(context, null);
        } else {
          query = "";
          showSuggestions(context);
        }
      },
    );
  }

  //重写搜索结果
  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      print("搜索框没有输入内容!");
      return new Center(
        child: Text(translate("search.noInputTips"),
            style: TextStyle(color: Colors.red)),
      );
    }
    return buildSearchFutureBuilder(context, query);
  }

  FutureBuilder<List<Document>> buildSearchFutureBuilder(
      BuildContext context, String key) {
    return FutureBuilder<List<Document>>(
        builder:
            (BuildContext context, AsyncSnapshot<List<Document>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.waiting:
              return new Center(
                child: new CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.hasError) {
                return new Center(
                  child: Text('出错误: ${snapshot.error}',
                      style: TextStyle(color: Colors.red)),
                );
              }
              if (snapshot.data.length <= 0) {
                return new Center(
                  child: Text(
                      translate("search.changeOther", args: {'key': '$key'})),
                );
              }
              return new ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: snapshot.data.length,
                  padding: new EdgeInsets.all(5.0),
                  itemBuilder: (context, index) {
                    return snapshot.data
                        .map((document) {
                          return Container(
                            margin: const EdgeInsets.only(left: 4.0),
                            child: getFileWidget(context, document: document),
                          );
                        })
                        .toList()
                        .elementAt(index);
                  });

            case ConnectionState.none:
              return new Center(
                child: Text('请输入搜索内容!'),
              );
            default:
              return new Center(
                child: Text("出问题了!"),
              );
          }
        },
        future: getSearchData(context, key));
  }

  FileWidget getFileWidget(BuildContext context,
          {@required Document document}) =>
      FileWidget(
        fileName: document.name,
        lastModified: document.dateModified,
        onPressedNext: () async {
          ProgressDialog pr;
          pr = new ProgressDialog(context, isDismissible: true);
          pr.style(message: translate("waitTips"));
          print("点击了 ${document.name} 文件");
          // 转圈圈和下载 md 文件
          await pr.show().then((_) {
            _getMDFile(context, document, pr);
          });
          //_clickDocument(document);
        },
      );

  _getMDFile(
      BuildContext context, Document document, ProgressDialog prt) async {
    TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);
    // 这里
    DataListModel dataListModel =
        Provider.of<DataListModel>(context, listen: false);

    bool hasImageFolder = false;
    final _imageFolderIdAndConfigIdModel =
        Provider.of<ImageFolderIdModel>(context, listen: false);
    for (Document d in dataListModel.dataList) {
      if (d.name == "_v_images") {
        // 在这里拿到了 imageFolder 的 id, 即是 _v_images的 id
        _imageFolderIdAndConfigIdModel.updateImageFolderId(d.id);
        hasImageFolder = true;
        break;
      }
    }

    if (!hasImageFolder) {
      _imageFolderIdAndConfigIdModel.updateImageFolderId("noimagefolder");
    }

    // 测试 Application.sp.containsKey(document.id)
    if (Application.sp.containsKey(document.id)) {
      // 本地有文档缓存
      print("使用本地文章缓存");
      await Future.delayed(Duration(milliseconds: 100), () {
        prt.hide().whenComplete(() async {
//          String route =
//              '/preview?content=${Uri.encodeComponent(Application.sp.getString(document.id))}&id=${Uri.encodeComponent(document.id)}&name=${Uri.encodeComponent(document.name)}&type=${Uri.encodeComponent("0")}';
//          Application.router
//              .navigateTo(context, route, transition: TransitionType.fadeIn);
          ConfigIdModel configIdModel =
          Provider.of<ConfigIdModel>(context, listen: false);
          ImageFolderIdModel _imageFolderIdModel =
          Provider.of<ImageFolderIdModel>(context, listen: false);
          String configId = configIdModel.configId;
          String imageFolderId = _imageFolderIdModel.imageFolderId;
          await Utils.getMarkdownHtml(
              document.name, Application.sp.getString(document.id)).then((data){
            String route =
                '/markdownWebView?content=${Uri.encodeComponent(data.toString())}&title=${Uri.encodeComponent(document.name)}&id=${Uri.encodeComponent(document.id)}&configId=${Uri.encodeComponent(configId)}&imageFolderId=${Uri.encodeComponent(imageFolderId)}';
            Application.router
                .navigateTo(context, route, transition: TransitionType.fadeIn);
          });

        });
      });
    } else {
      // 本地没有, 从网络下载
      print("从网络下载文章");
      await DocumentListUtil.instance
          .getMDFileContentFromNetwork(
              context, tokenModel.token.accessToken, document.id, prt)
          .then((data) {
        print("看看这玩意张啥样:");
        print(data);
        if (data == null) {
          print("超时, 没有获得数据");
          if (prt.isShowing()) {
            prt.hide();
          }
          Fluttertoast.showToast(
              msg: "网络连接超时!!!",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          // 这里需要跳转到预览页面
          print("跳转到预览页面");
          prt.hide().whenComplete(() async {
//            String route =
//                '/preview?content=${Uri.encodeComponent(data.toString())}&id=${Uri.encodeComponent(document.id)}&name=${Uri.encodeComponent(document.name)}&configId=${Uri.encodeComponent(document.configId)}&imageFolderId=${Uri.encodeComponent(document.imageFolderId)}';
//            Application.router
//                .navigateTo(context, route, transition: TransitionType.fadeIn);
            ConfigIdModel configIdModel =
            Provider.of<ConfigIdModel>(context, listen: false);
            ImageFolderIdModel _imageFolderIdModel =
            Provider.of<ImageFolderIdModel>(context, listen: false);
            String configId = configIdModel.configId;
            String imageFolderId = _imageFolderIdModel.imageFolderId;
            await Utils.getMarkdownHtml(
                document.name, data.toString()).then((result){
              String route =
                  '/markdownWebView?content=${Uri.encodeComponent(result.toString())}&title=${Uri.encodeComponent(document.name)}&id=${Uri.encodeComponent(document.id)}&configId=${Uri.encodeComponent(configId)}&imageFolderId=${Uri.encodeComponent(imageFolderId)}';
              Application.router
                  .navigateTo(context, route, transition: TransitionType.fadeIn);
            });

          });
        }
      });
    }
  }

  Future<List<Document>> getSearchData(BuildContext context, String key) async {
    return DocumentListUtil.instance.getSearchList(context, key);
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: Colors.blue,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.white),
      primaryColorBrightness: Brightness.light,
      primaryTextTheme: theme.textTheme,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? recentSuggest
        : searchList.where((input) => input.startsWith(query)).toList();
    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) => ListTile(
        title: RichText(
            text: TextSpan(
                text: suggestionList[index].substring(0, query.length),
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                children: [
              TextSpan(
                  text: suggestionList[index].substring(query.length),
                  style: TextStyle(color: Colors.grey))
            ])),
      ),
    );
  }
}
