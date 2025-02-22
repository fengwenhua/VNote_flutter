import 'dart:convert';

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
import 'package:vnote/models/personal_note_model.dart';
import 'package:vnote/provider/config_id_provider.dart';
import 'package:vnote/provider/data_list_provider.dart';
import 'package:vnote/provider/image_folder_id_provider.dart';
import 'package:vnote/provider/local_document_provider.dart';
import 'package:vnote/provider/parent_id_provider.dart';
import 'package:vnote/provider/token_provider.dart';
import 'package:vnote/res/colors.dart';
import 'package:vnote/res/styles.dart';
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
  // 初始化加载
  // 重写右侧的图标, 这里放清除按钮
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
        parentName: document.parentName,
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
    DataListProvider dataListModel =
        Provider.of<DataListProvider>(context, listen: false);
    ConfigIdProvider configIdModel =
        Provider.of<ConfigIdProvider>(context, listen: false);
    bool hasImageFolder = false;
    final _imageFolderIdModel =
        Provider.of<ImageFolderIdProvider>(context, listen: false);
    for (Document d in dataListModel.dataList) {
      if (d.name == "_v_images") {
        // 在这里拿到了 imageFolder 的 id, 即是 _v_images的 id
        _imageFolderIdModel.updateImageFolderId(d.id);
        hasImageFolder = true;
        break;
      }
    }

    if (!hasImageFolder) {
      _imageFolderIdModel.updateImageFolderId("noimagefolder");
    }

    // 测试 Application.sp.containsKey(document.id)
    if (Application.sp.containsKey(document.id)) {
      // 本地有文档缓存
      print("使用本地文章缓存");
      String configId = configIdModel.configId;
      String imageFolderId = _imageFolderIdModel.imageFolderId;

      // 防止 Android 会干掉 _myNote.json 文件, 这里需要加入一个判断该缓存是否还在
      // _myNote.json , 不在则需要加上
      PersonalNoteModel personalNoteModel = await Utils.getPersonalNoteModel();
      ParentIdProvider parentIdModel =
          Provider.of<ParentIdProvider>(context, listen: false);
      if (!personalNoteModel.checkDocument(document.id)) {
        print("_myNote.json 中没有 " + document.name);
        print("应该是 _myNote.json 被干掉了, 需要重新加入");

        // 写到 _myNote.json, 同时更新"笔记"tab
        Map<String, dynamic> newFileMap = jsonDecode(Utils.newLocalFileJson(
            document.id,
            parentIdModel.parentId,
            parentIdModel.parentName,
            Application.sp.getString("choose_notebook_id"),
            configIdModel.configId,
            _imageFolderIdModel.imageFolderId,
            document.name));
        personalNoteModel.addNewFile(newFileMap);
        LocalDocumentProvider localDocumentProvider =
            Provider.of<LocalDocumentProvider>(context, listen: false);

        Utils.writeModelToFile(personalNoteModel);
        await Utils.model2ListDocument().then((data) {
          print("directory_page 这里拿到 _myNote.json 的数据");
          localDocumentProvider.updateList(data);
        });
      }

      await Future.delayed(Duration(milliseconds: 100), () {
        prt.hide().whenComplete(() async {
//          String route =
//              '/preview?content=${Uri.encodeComponent(Application.sp.getString(document.id))}&name=${Uri.encodeComponent(document.name)}&id=${Uri.encodeComponent(document.id)}&configId=${Uri.encodeComponent(configId)}&imageFolderId=${Uri.encodeComponent(imageFolderId)}';
//          Application.router
//              .navigateTo(context, route, transition: TransitionType.fadeIn);

          await Utils.getMarkdownHtml(
                  document.name, Application.sp.getString(document.id))
              .then((htmlPath) {
            String route =
                '/markdownWebView?htmlPath=${Uri.encodeComponent(htmlPath.toString())}&title=${Uri.encodeComponent(document.name)}&id=${Uri.encodeComponent(document.id)}&configId=${Uri.encodeComponent(configId)}&imageFolderId=${Uri.encodeComponent(imageFolderId)}';
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
          .then((data) async {
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

          print("同时也要写进 _myNote.json");
          // 先更新 model
          // 先写到文件
          // 然后再更新provider
          PersonalNoteModel personalNoteModel =
              await Utils.getPersonalNoteModel();
          ConfigIdProvider configIdModel =
              Provider.of<ConfigIdProvider>(context, listen: false);
          ParentIdProvider parentIdModel =
              Provider.of<ParentIdProvider>(context, listen: false);

          // 写到 _myNote.json, 同时更新"笔记"tab
          Map<String, dynamic> newFileMap = jsonDecode(Utils.newLocalFileJson(
              document.id,
              parentIdModel.parentId,
              parentIdModel.parentName,
              Application.sp.getString("choose_notebook_id"),
              configIdModel.configId,
              _imageFolderIdModel.imageFolderId,
              document.name));
          personalNoteModel.addNewFile(newFileMap);
          LocalDocumentProvider localDocumentProvider =
              Provider.of<LocalDocumentProvider>(context, listen: false);

          Utils.writeModelToFile(personalNoteModel);
          await Utils.model2ListDocument().then((data) {
            print("directory_page 这里拿到 _myNote.json 的数据");
            localDocumentProvider.updateList(data);
          });

          prt.hide().whenComplete(() async {
            String configId = configIdModel.configId;
            String imageFolderId = _imageFolderIdModel.imageFolderId;
            // 下面是用 markdown_webveiw
            await Utils.getMarkdownHtml(document.name, data.toString())
                .then((htmlPath) {
              String route =
                  '/markdownWebView?htmlPath=${Uri.encodeComponent(htmlPath.toString())}&title=${Uri.encodeComponent(document.name)}&id=${Uri.encodeComponent(document.id)}&configId=${Uri.encodeComponent(configId)}&imageFolderId=${Uri.encodeComponent(imageFolderId)}';
              Application.router.navigateTo(context, route,
                  transition: TransitionType.fadeIn);
            });

            // 下面是用 flutter_markdown
//            String route =
//                '/preview?content=${Uri.encodeComponent(data.toString())}&id=${Uri.encodeComponent(document.id)}&name=${Uri.encodeComponent(document.name)}&configId=${Uri.encodeComponent(configId)}&imageFolderId=${Uri.encodeComponent(imageFolderId)}';
//            Application.router
//                .navigateTo(context, route, transition: TransitionType.fadeIn);
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
    String themeStr = Application.sp?.getString('AppTheme');

    ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: themeStr == 'Dark' ? Colours.dark_line : Colors.blue,
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
