import 'dart:convert';
import 'dart:io';

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:vnote/application.dart';
import 'package:vnote/dao/onedrive_data_dao.dart';
import 'package:vnote/models/desktop_config_model.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/models/personal_note_model.dart';
import 'package:vnote/provider/config_id_provider.dart';
import 'package:vnote/provider/data_list_provider.dart';
import 'package:vnote/provider/dir_and_file_cache_provider.dart';
import 'package:vnote/provider/image_folder_id_provider.dart';
import 'package:vnote/provider/local_document_provider.dart';
import 'package:vnote/provider/parent_id_provider.dart';
import 'package:vnote/provider/token_provider.dart';
import 'package:vnote/utils/document_list_util.dart';
import 'package:vnote/utils/global.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:vnote/utils/utils.dart';
import 'package:vnote/widgets/file_widget.dart';

class NotePage extends StatefulWidget {
  @override
  _NotePageState createState() => _NotePageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _NotePageState extends State<NotePage> {
  // 先判断本地有没有 _myNote.json
  // 没有就新建, 内容为 {"files":[]}
  // 有就读取进来, 变成 Document, 渲染出来
  // 在 directroy_page 中, 每次点击一个 md 文件, 都用 SP 记录下来(id,content),并且写入_myNote.json 文件
  // 不搞 provider, 直接弄个下拉更新, 或者点击更新按钮
  ProgressDialog pr;
  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(this.context, type: ProgressDialogType.Download);
    pr.style(
      message: translate("waitTips"),
      progress: 0.0,
      maxProgress: 100.0,
    );

    DataListProvider dataListModel =
        Provider.of<DataListProvider>(context, listen: false);

    TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          title: Text(translate("note.appbar"),
              style: TextStyle(fontSize: fontSize40)),
          leading: IconButton(
            icon: Icon(
              Icons.dehaze,
              color: Colors.white,
            ),
            onPressed: () {
              // 打开Drawer抽屉菜单
              print("点击了侧滑按钮");
              Scaffold.of(context).openDrawer();
            },
          ),
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.refresh),
                tooltip: "Update",
                onPressed: () async {
                  print("点击刷新");
                  // 这里应该重新比对???
                  LocalDocumentProvider localDocumentProvider =
                      Provider.of<LocalDocumentProvider>(context,
                          listen: false);
                  await Utils.model2ListDocument().then((data) {
                    print("directory_page 这里拿到 _myNote.json 的数据");
                    localDocumentProvider.updateList(data);
                    Fluttertoast.showToast(
                        msg: "本地缓存读取完成!",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 3,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  });
                })
          ],
        ),
        body: Consumer<LocalDocumentProvider>(
          builder: (context, LocalDocumentProvider localDocumentProvider,
                  child) =>
              localDocumentProvider.list == null ||
                      localDocumentProvider.list.length == 0
                  ? Center(
                      child: Text(translate("note.tips")),
                    )
                  : Scrollbar(
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: localDocumentProvider.list.length,
                        itemBuilder: (context, index) {
                          return localDocumentProvider.list
                              .map((document) {
                                return Slidable(
                                  key: Key(document.id),
                                  actionPane: SlidableDrawerActionPane(),
                                  actionExtentRatio: 0.25,
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 4.0),
                                    child: getFileWidget(context,
                                        document: document),
                                  ),
                                  secondaryActions: <Widget>[
                                    IconSlideAction(
                                      caption: translate("item.rename"),
                                      color: Colors.black45,
                                      icon: Icons.create,
                                      onTap: () {
                                        print("点击了重命名");
                                        showDialog<bool>(
                                            context: context,
                                            builder: (context) {
                                              return _renameDialog(
                                                  context,
                                                  document,
                                                  tokenModel,
                                                  dataListModel);
                                            });
                                      },
                                    ),
                                    IconSlideAction(
                                      caption: translate("item.delete"),
                                      color: Colors.red,
                                      icon: Icons.delete,
                                      closeOnTap: true,
                                      onTap: () async {
                                        showDialog<bool>(
                                            context: context,
                                            builder: (context) {
                                              return _deleteDialog(
                                                  context,
                                                  document,
                                                  tokenModel,
                                                  dataListModel);
                                            });
                                      },
                                    ),
                                  ],
                                );
                              })
                              .toList()
                              .elementAt(index);
                        },
                      ),
                    ),
        ));
  }

  Widget _deleteDialog(BuildContext context, Document document,
      TokenModel tokenModel, DataListProvider dataListModel) {
    ConfigIdProvider configIdModel =
        Provider.of<ConfigIdProvider>(context, listen: false);
    DirAndFileCacheProvider dirCacheModel =
        Provider.of<DirAndFileCacheProvider>(context, listen: false);
    ParentIdProvider parentIdModel =
        Provider.of<ParentIdProvider>(context, listen: false);
    return AlertDialog(
      title: Text(translate("delDialog.name")),
      content: document.isFile
          ? Text(translate("delDialog.fileTitle"))
          : Text(translate("delDialog.dirTitle")),
      actions: <Widget>[
        FlatButton(
          child: Text(translate("delDialog.cancel")),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        FlatButton(
          child: Text(translate("delDialog.ok")),
          onPressed: () async {
            Navigator.of(context).pop(true);
            pr = new ProgressDialog(this.context,
                type: ProgressDialogType.Download);
            pr.style(
              message: translate("waitTips"),
              progress: 0.0,
              maxProgress: 100.0,
            );
            await pr.show();
            print("点击了删除");
            pr.update(message: "0. 开始删除", progress: 30);
            // 网络请求删除在线的文件夹
            await OneDriveDataDao.deleteFile(
                context, tokenModel.token.accessToken, document.id);
            // 删除本地缓存的文件夹
            dataListModel.removeEle(document);
            dirCacheModel.delDirOrFileEle(parentIdModel.parentId, document);
            // 同时要修改配置文件
            // 如果是顶层 approot 则不用管
            // 否则

            pr.update(message: "1. 下载 _vnote.json", progress: 60);
            print("接下来开始下载当前目录下的 _vnote.json 文件, 然后更新它的字段");
            await OneDriveDataDao.getFileContent(
                    context, tokenModel.token.accessToken, document.configId)
                .then((value) async {
              //pr.update(message: "这是更新测试,崩溃?", progress: 70);
              await pr.hide().then((isHidden) async {
                print("1. 下载 _vnote.json 的对话框关闭了?");
                print(isHidden);
                if (!isHidden) {
                  await Future.delayed(Duration(seconds: 1)).then((_) async {
                    await pr.hide();
                  });
                }
              });
              pr = new ProgressDialog(this.context,
                  type: ProgressDialogType.Download, isDismissible: true);
              pr.style(
                message: "2. 删除本地缓存",
                progress: 80,
              );
              await pr.show();
              //pr.update(message: "2. 更新 _vnote.json", progress: 80);
              print("拿到的 _vnote.json 文件数据为: " + value.toString());
              print("要干掉的文件/文件夹名字: " + document.name);
              DesktopConfigModel desktopConfigModel =
                  DesktopConfigModel.fromJson(json.decode(value.toString()));
              //print("干掉之前: ");
              //print(json.encode(desktopConfigModel));

              desktopConfigModel.delFile(document.name);

              PersonalNoteModel personalNoteModel =
                  await Utils.getPersonalNoteModel();
              personalNoteModel.delFile(document.id);
              LocalDocumentProvider localDocumentProvider =
                  Provider.of<LocalDocumentProvider>(this.context,
                      listen: false);

              Utils.writeModelToFile(personalNoteModel);
              await Utils.model2ListDocument().then((data) {
                print("directory_page del 这里拿到 _myNote.json 的数据");
                localDocumentProvider.updateList(data);
              });

              print("干掉之后: ");
              print(json.encode(desktopConfigModel));
              // 修改成功_vnote.json 之后, 就是更新这个文件
              //Utils.showMyToast("修改 _vnote.json");
              await pr.hide().then((isHidden) async {
                print("2. 删除本地缓存 的对话框关闭了?");
                print(isHidden);
                if (!isHidden) {
                  await pr.hide();
                }
              });
              Future.delayed(Duration(seconds: 2));

              print("3. 更新 _vnote.json");
              pr = new ProgressDialog(this.context,
                  type: ProgressDialogType.Download, isDismissible: true);
              pr.style(
                message: "3. 更新 _vnote.json",
                progress: 90,
              );
              await OneDriveDataDao.updateContent(
                      context,
                      tokenModel.token.accessToken,
                      document.configId,
                      json.encode(desktopConfigModel))
                  .then((value) async {
                print("更新完成");
                await pr.hide().then((isHidden) async {
                  print("3. 更新 _vnote.json 的对话框关闭了?");
                  print(isHidden);
                  if (!isHidden) {
                    await pr.hide();
                  }
                });
                Future.delayed(Duration(seconds: 2));
              });
            });
            if (pr.isShowing()) print("还没关闭?");
            await pr.hide();
          },
        ),
      ],
    );
  }

  Widget _renameDialog(BuildContext context, Document document,
      TokenModel tokenModel, DataListProvider dataListModel) {
    DirAndFileCacheProvider dirCacheModel =
        Provider.of<DirAndFileCacheProvider>(context, listen: false);
    ParentIdProvider parentIdModel =
        Provider.of<ParentIdProvider>(context, listen: false);
    ConfigIdProvider configIdModel =
        Provider.of<ConfigIdProvider>(context, listen: false);
    String fileOrFolderName = "";
    String oldFileOrFolderName = document.name;
    return CupertinoAlertDialog(
      title: Text(translate("renameDialog.fileTitle")),
      content: Card(
        elevation: 0.0,
        child: Column(
          children: <Widget>[
            TextField(
                decoration: InputDecoration(
                    hintText: translate("renameDialog.hintTips"),
                    filled: true,
                    fillColor: Colors.grey.shade50),
                onChanged: (String value) {
                  fileOrFolderName = value;
                },
                controller: TextEditingController.fromValue(TextEditingValue(
                    // 设置内容
                    text: document.name,
                    // 保持光标在最后
                    selection: TextSelection.fromPosition(TextPosition(
                        affinity: TextAffinity.downstream,
                        offset: document.name.length))))),
          ],
        ),
      ),
      actions: <Widget>[
        CupertinoDialogAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(translate("renameDialog.cancel")),
        ),
        CupertinoDialogAction(
          onPressed: () async {
            Navigator.pop(context);
            // 1. 发送请求更改名字
            // 2. 更新 dataList 的 name
            // 3. 更新 dircache 的 name
            // 4. 更新 _vnote.json
            fileOrFolderName = fileOrFolderName.trim(); //去空
            // 防止手贱将 md 干掉的情况
            if (!fileOrFolderName.contains(".md")) {
              fileOrFolderName += ".md";
            }
            if (fileOrFolderName != "") {
              pr.update(message: "开始重命名");
              Utils.showMyToast("将新名字上传到 onedrive 中...");
              await pr.show().then((_) async {
                await OneDriveDataDao.rename(
                        context,
                        tokenModel.token.accessToken,
                        document.id,
                        fileOrFolderName)
                    .then((data) async {
                  print("重命名返回的数据: " + data.toString());
                  // 更新本地数据
                  dataListModel.renameEle(document.id, fileOrFolderName);
                  dirCacheModel.renameEle(
                      parentIdModel.parentId, document.id, fileOrFolderName);
                  // 更新 _vnote.json
                  // 重命名文件和文件夹是不一样的
                  // 根目录则不用修改 _vnote.json

                  print("接下来开始下载当前目录下的 _vnote.json 文件, 然后更新它的字段");
                  Utils.showMyToast("下载 _vnote.json..");
                  await OneDriveDataDao.getFileContent(context,
                          tokenModel.token.accessToken, document.configId)
                      .then((value) async {
                    print("拿到的 _vnote.json 文件数据为: " + value.toString());
                    print("要修改的文件/文件夹名字: " + oldFileOrFolderName);
                    DesktopConfigModel desktopConfigModel =
                        DesktopConfigModel.fromJson(
                            json.decode(value.toString()));

                    desktopConfigModel.renameFile(
                        oldFileOrFolderName, fileOrFolderName);

                    PersonalNoteModel personalNoteModel =
                        await Utils.getPersonalNoteModel();

                    personalNoteModel.renameFile(document.id, fileOrFolderName);
                    LocalDocumentProvider localDocumentProvider =
                        Provider.of<LocalDocumentProvider>(this.context,
                            listen: false);

                    Utils.writeModelToFile(personalNoteModel);
                    await Utils.model2ListDocument().then((data) {
                      print("directory_page rename 这里拿到 _myNote.json 的数据");
                      localDocumentProvider.updateList(data);
                    });
                    Utils.showMyToast("修改 _vnote.json");
                    await OneDriveDataDao.updateContent(
                        context,
                        tokenModel.token.accessToken,
                        document.configId,
                        json.encode(desktopConfigModel));
                  });
                });
              }).then((_) async {
                await pr.hide();
              });
            }
          },
          child: Text(translate("renameDialog.ok")),
        ),
      ],
    );
  }
}

FileWidget getFileWidget(BuildContext context, {@required Document document}) =>
    FileWidget(
      fileName: document.name,
      lastModified: document.dateModified,
      onPressedNext: () async {
        ProgressDialog pr;
        pr = new ProgressDialog(context, isDismissible: true);
        pr.style(message: translate("waitTips"));
        print("note_page 点击了 ${document.name} 文件");
        print("其 configId: " + document.configId);
        print("其 imageFolderId: " + document.imageFolderId);
        // 转圈圈和下载 md 文件
        await pr.show().then((_) {
          _getMDFile(context, document, pr);
        });
        //_clickDocument(document);
      },
    );

_getMDFile(BuildContext context, Document document, ProgressDialog prt) async {
  TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);
  // 这里
  DataListProvider dataListModel =
      Provider.of<DataListProvider>(context, listen: false);

  bool hasImageFolder = false;
  final _imageFolderIdAndConfigIdModel =
      Provider.of<ImageFolderIdProvider>(context, listen: false);
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
        // 下面用 flutter_markdown
//        String route =
//            '/preview?content=${Uri.encodeComponent(Application.sp.getString(document.id))}&id=${Uri.encodeComponent(document.id)}&name=${Uri.encodeComponent(document.name)}&configId=${Uri.encodeComponent(document.configId)}&imageFolderId=${Uri.encodeComponent(document.imageFolderId)}';
//        Application.router
//            .navigateTo(context, route, transition: TransitionType.fadeIn);
        // 下面用 webview_markdown
        await Utils.getMarkdownHtml(
                document.name, Application.sp.getString(document.id))
            .then((htmlPath) {
          String route =
              '/markdownWebView?htmlPath=${Uri.encodeComponent(htmlPath.toString())}&title=${Uri.encodeComponent(document.name)}&id=${Uri.encodeComponent(document.id)}&configId=${Uri.encodeComponent(document.configId)}&imageFolderId=${Uri.encodeComponent(document.imageFolderId)}';
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
//          String route =
//              '/preview?content=${Uri.encodeComponent(data.toString())}&id=${Uri.encodeComponent(document.id)}&name=${Uri.encodeComponent(document.name)}&configId=${Uri.encodeComponent(document.configId)}&imageFolderId=${Uri.encodeComponent(document.imageFolderId)}';
//          Application.router
//              .navigateTo(context, route, transition: TransitionType.fadeIn);

          await Utils.getMarkdownHtml(document.name, data.toString())
              .then((htmlPath) {
            String route =
                '/markdownWebView?htmlPath=${Uri.encodeComponent(htmlPath.toString())}&title=${Uri.encodeComponent(document.name)}&id=${Uri.encodeComponent(document.id)}&configId=${Uri.encodeComponent(document.configId)}&imageFolderId=${Uri.encodeComponent(document.imageFolderId)}';
            Application.router
                .navigateTo(context, route, transition: TransitionType.fadeIn);
          });
        });
      }
    });
  }
}
