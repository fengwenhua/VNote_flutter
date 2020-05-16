import 'dart:async';
import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vnote/dao/onedrive_data_dao.dart';
import 'package:vnote/models/desktop_config_model.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/models/onedrive_data_model.dart';
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
import 'package:vnote/utils/utils.dart';
import 'package:vnote/widgets/directory_widget.dart';
import 'package:vnote/widgets/file_widget.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../application.dart';

class DirectoryPage extends StatefulWidget {
  @override
  _DirectoryPageState createState() => _DirectoryPageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _DirectoryPageState extends State<DirectoryPage>
    with AutomaticKeepAliveClientMixin {
  // 进度圈圈
  ProgressDialog pr;
  ScrollController controller = ScrollController(initialScrollOffset: 10.0);
  List<double> position = [];
  //List<Document> rootDocuments = <Document>[];
  final SlidableController slidableController = SlidableController();

  /// 根据点击的 id 来查找目录
  Future<List<Document>> getChildData(String accessToken, String id) async {
    return await DocumentListUtil.instance
        .getChildList(context, accessToken, id, (list) {
//      print("根据 id 获取了List, 如下:");
//      list.forEach((i) {
//        print(i.name);
//      });
//      DataListModel dataListModel = Provider.of<DataListModel>(context);
//      dataListModel.updateValue(list);
    });
  }

  /// 根据 id 下载 md 文件内容
  Future<String> getMDFileContent(
      String accessToken, String id, ProgressDialog prt) async {
    return await DocumentListUtil.instance
        .getMDFileContentFromNetwork(context, accessToken, id, prt);
  }

  _getMDFile(Document document, ProgressDialog prt) async {
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
      print("没有_v_images");
      _imageFolderIdModel.updateImageFolderId("noimagefolder");
    }

    // 测试 Application.sp.containsKey(document.id)
    if (Application.sp.containsKey(document.id)) {
      // 本地有文档缓存
      print("使用本地文章缓存");
      String configId = configIdModel.configId;
      String imageFolderId = _imageFolderIdModel.imageFolderId;
      await Future.delayed(Duration(milliseconds: 100), () {
        prt.hide().whenComplete(() async {
          // 下面使用 markdown_webview
          await Utils.getMarkdownHtml(
                  document.name, Application.sp.getString(document.id))
              .then((htmlPath) {
            // 因为是在目录, 所以不管了, 直接用

            String route =
                '/markdownWebView?htmlPath=${Uri.encodeComponent(htmlPath)}&title=${Uri.encodeComponent(document.name)}&id=${Uri.encodeComponent(document.id)}&configId=${Uri.encodeComponent(configId)}&imageFolderId=${Uri.encodeComponent(imageFolderId)}';
            Application.router
                .navigateTo(context, route, transition: TransitionType.fadeIn);
          });
          // 下面使用 flutter_markdown
//          String route =
//              '/preview?content=${Uri.encodeComponent(Application.sp.getString(document.id))}&id=${Uri.encodeComponent(document.id)}&name=${Uri.encodeComponent(document.name)}&configId=${Uri.encodeComponent(configId)}&imageFolderId=${Uri.encodeComponent(imageFolderId)}';
//          Application.router
//              .navigateTo(context, route, transition: TransitionType.fadeIn);
        });
      });
    } else {
      // 本地没有, 从网络下载
      print("从网络下载文章");
      await getMDFileContent(tokenModel.token.accessToken, document.id, prt)
          .then((data) async {
        print("看看这玩意张啥样:");
        print(data);

        if (data == null) {
          print("超时, 没有获得数据");
          if (prt.isShowing()) {
            prt.hide();
          }
//          Fluttertoast.showToast(
//              msg: "网络连接超时!!!",
//              toastLength: Toast.LENGTH_LONG,
//              gravity: ToastGravity.CENTER,
//              timeInSecForIosWeb: 3,
//              backgroundColor: Colors.red,
//              textColor: Colors.white,
//              fontSize: 16.0);
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
          Map<String, dynamic> newFileMap = jsonDecode(Utils.newLocalFileJson(
              document.id,
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

  /// [_postData] 是根据 [id] 获取下一级目录的内容
  /// 如果[update]为 true 代表只是更新当前目录
  /// 如果 id=="approot"则用另一个请求
  _postData(String id, String name, {bool update = false}) async {
    // 获取当前 token
    TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);
    ParentIdProvider parentIdModel =
        Provider.of<ParentIdProvider>(context, listen: false);
    DataListProvider dataListModel =
        Provider.of<DataListProvider>(context, listen: false);
    ConfigIdProvider configIdModel =
        Provider.of<ConfigIdProvider>(context, listen: false);
    DirAndFileCacheProvider dirCacheModel =
        Provider.of<DirAndFileCacheProvider>(context, listen: false);
    // 在根目录点击了更新
    if (id == "approot" || name == "VNote 根目录") {
      await DocumentListUtil.instance
          .getNotebookList(context, tokenModel.token.accessToken, (data) async {
        if (data != null) {
          if (data.length == 0) {
            Fluttertoast.showToast(
                msg: translate("noNoteBookTips"),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          } else {
            dataListModel.updateCurrentDir(data);

            // 可以在这里, 用 Map<String,List<Document>> 的模式, 将 id 和 dataList 对应起来
            dirCacheModel.updateDirAndFileList(id, data);
          }
          pr.hide().whenComplete(() {
            jumpToPosition(true);
          });
        } else {
          print("进来 2");
          Fluttertoast.showToast(
              msg: translate("noNoteBookTips"),
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          pr.hide().whenComplete(() {
            jumpToPosition(true);
          });

          // 因为点击目录的时候, 已经记录的 parentId , 所以如果当前目录为空, 所以要撤销
          parentIdModel.goBackParentId();
        }
      });
    } else {
      // update 用于判断在其他目录点击了更新或者进入其他目录
      await getChildData(tokenModel.token.accessToken, id).then((data) {
        if (data == null) {
          print("获取的数据为空, 不处理!");
        } else {
          // 显示
          if (data.length > 0) {
            if (controller.hasClients) {
              if (update) {
                if (position.length > 0) position.removeLast();
              }
              print("此时的 offset 是:");
              position.add(controller.offset);
            }
            if (update) {
              dataListModel.updateCurrentDir(data);
              dirCacheModel.updateDirAndFileList(id, data);
            } else {
              dataListModel.goAheadDataList(data);
              dirCacheModel.addDirAndFileList(id, data);
              for (Document d in dataListModel.dataList) {
                if (d.name == "_vnote.json") {
                  configIdModel.updateConfigId(d.id);
                  break;
                }
              }
            }
            //initPathFiles(document.childData);
            pr.hide().whenComplete(() {
              jumpToPosition(true);
            });
          } else {
            Fluttertoast.showToast(
                msg: "该文件夹内容为空了, 不可能的!!!",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            pr.hide().whenComplete(() {
              jumpToPosition(true);
            });
            parentIdModel.goBackParentId();
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    //print("进入 directory_page 的 initState 方法");
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    //print("进入 directory_page 的 build 方法");
//    pr = new ProgressDialog(context, isDismissible: true);
//    pr.style(message: translate("waitTips"));
    DataListProvider dataListModel =
        Provider.of<DataListProvider>(context, listen: false);

    ParentIdProvider parentIdModel =
        Provider.of<ParentIdProvider>(context, listen: false);
    TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);
    ConfigIdProvider configIdModel =
        Provider.of<ConfigIdProvider>(context, listen: false);
    DirAndFileCacheProvider dirCacheModel =
        Provider.of<DirAndFileCacheProvider>(context, listen: false);
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
            title: Text(parentIdModel.parentName,
                style: TextStyle(fontSize: fontSize40)),
            actions: <Widget>[
              // 非隐藏起来的菜单
              new IconButton(
                  icon: new Icon(Icons.add),
                  tooltip: 'Add Folder',
                  onPressed: () {
                    print("点击添加文件夹的按钮");

                    // 1. 弹框输入文件夹名字
                    // 2. 调用接口上传(文件夹新建, _vnote.json 新建)
                    // 3. 修改当前目录的 _vnote.json
                    // 4. 都 ok 后更新本地 dataList

                    showDialog(
                        context: context,
                        builder: (context) {
                          return _addFolderDialog();
                        });
                  }),
              new IconButton(
                  icon: new Icon(Icons.refresh),
                  tooltip: "Update",
                  onPressed: () async {
                    // 手动点击更新按钮
                    pr = new ProgressDialog(context, isDismissible: true);
                    pr.style(message: translate("waitTips"));
                    await pr.show().then((_) {
                      String parentId = parentIdModel.parentId;
                      String parentName = parentIdModel.parentName;
                      // 接下来是根据这个 id 刷新获取数据

                      _postData(parentId, parentName, update: true);
                    });
                  })
            ],
            leading: parentIdModel.parentId == "approot" ||
                    parentIdModel.parentId == parentIdModel.genId
                ? IconButton(
                    icon: Icon(
                      Icons.dehaze,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // 打开Drawer抽屉菜单
                      print("点击了侧滑按钮");
                      Scaffold.of(context).openDrawer();
                    },
                  )
                : IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: onWillPop,
                  )),
        body: dataListModel.dataList == null ||
                dataListModel.dataList.length == 0 ||
                dataListModel.getLength() == 0
            ? Center(
                child: Text(translate("noNoteBookTips")),
              )
            : Scrollbar(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  controller: controller,
                  itemCount: dataListModel.getLength(),
                  itemBuilder: (context, index) {
                    return getListWidget(dataListModel.dataList)
                        .elementAt(index);
                  },
                ),
              ),
      ),
    );
  }

  Future<bool> onWillPop() async {
    // 退回, 所以要弹栈, 更新 ParentID
    final _parentId = Provider.of<ParentIdProvider>(context, listen: false);

    DataListProvider dataListModel =
        Provider.of<DataListProvider>(context, listen: false);
    ConfigIdProvider configIdModel =
        Provider.of<ConfigIdProvider>(context, listen: false);
    _parentId.goBackParentId();
    dataListModel.goBackDataList();
    //print("返回的时候判断 genId: "  + _parentId.genId);
    //print("当前的 parentId: " + _parentId.parentId);
    //print("当前的 parentName: " + _parentId.parentName);

    if (_parentId.parentName != "VNote 根目录" &&
        _parentId.parentId != _parentId.genId) {
      print("不在根目录");

      for (Document d in dataListModel.dataList) {
        if (d.name == "_vnote.json") {
          configIdModel.updateConfigId(d.id);
          break;
        }
      }
      jumpToPosition(false);
    } else {
      print("在根目录了, 所有没有返回的操作了, 也不需要给 parentid 弹栈了");
      print("打开侧滑菜单");
      configIdModel.updateConfigId("approot");
      //Navigator.pop(context);
    }
    return false;
  }

  void jumpToPosition(bool isEnter) async {
    if (controller.hasClients) {
      if (isEnter)
        controller.jumpTo(0.0);
      else {
        try {
          await Future.delayed(Duration(milliseconds: 1));
          controller?.jumpTo(position[position.length - 1]);
        } catch (e) {}
        position.removeLast();
      }
    }
  }

  List<Widget> getListWidget(List<Document> documents) {
    List<Document> childDocuments = new List<Document>();

    documents.forEach((f) {
      childDocuments.add(f);
    });

    // 在黑名单之中, 都不显示
    childDocuments.removeWhere((s) {
      return BLACK_NAME.contains(s.name);
    });

    //print("去掉黑名单中不显示的, 还剩多少?");
    //print(childDocuments.length);

    return childDocuments.map((document) {
      //print("要处理的是: " + document.name);

      TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);
      DataListProvider dataListModel =
          Provider.of<DataListProvider>(context, listen: false);

      // 目录
      return Slidable(
        key: Key(document.id),
        actionPane: SlidableDrawerActionPane(),
        controller: slidableController,
        actionExtentRatio: 0.25,
        child: Container(
          margin: const EdgeInsets.only(left: 4.0),
          child: document.isFile == false
              ? _getDirectoryWidget(document: document)
              : _getFileWidget(document: document),
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
                        context, document, tokenModel, dataListModel);
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
                        context, document, tokenModel, dataListModel);
                  });
            },
          ),
        ],
        dismissal: SlidableDismissal(
          child: SlidableDrawerDismissal(),
          onWillDismiss: (actionType) {
            return showDialog<bool>(
                context: context,
                builder: (context) {
                  return _deleteDialog(
                      context, document, tokenModel, dataListModel);
                });
          },
          onDismissed: (actionType) {
            print("actionType: " + actionType.toString());
          },
        ),
      );
    }).toList();
  }

  Widget _getDirectoryWidget({@required Document document}) => DirectoryWidget(
      directoryName: document.name,
      lastModified: document.dateModified,
      onPressedNext: () async {
        print("点开 ${document.name} 目录, 然后显示该目录下的所有文件");
        // 记得将这个 id 记录下来, 以后刷新用
        final _parentId = Provider.of<ParentIdProvider>(context, listen: false);
        _parentId.goAheadParentId(document.id, document.name);

        DirAndFileCacheProvider dirAndFileCacheModel =
            Provider.of<DirAndFileCacheProvider>(context, listen: false);
        DataListProvider dataListModel =
            Provider.of<DataListProvider>(context, listen: false);
        ConfigIdProvider configIdModel =
            Provider.of<ConfigIdProvider>(context, listen: false);
        List<Document> cache =
            dirAndFileCacheModel.getDirAndFileCache(document.id);
        // 这里可以先查看本地缓存???
        if (cache != null) {
          print("该目录本地有缓存");

          dataListModel.goAheadDataList(cache);
          position.add(controller.offset);
          for (Document d in dataListModel.dataList) {
            if (d.name == "_vnote.json") {
              configIdModel.updateConfigId(d.id);
              break;
            }
          }
        } else {
          // 转圈圈和网络请求
          print("该目录本地没有缓存");
          pr = new ProgressDialog(context, isDismissible: true);
          pr.style(message: translate("waitTips"));
          await pr.show().then((_) {
            _postData(document.id, document.name);
          });
        }
      });

  FileWidget _getFileWidget({@required Document document}) => FileWidget(
        fileName: document.name,
        lastModified: document.dateModified,
        onPressedNext: () async {
          print("点击了 ${document.name} 文件");

          pr = new ProgressDialog(context, isDismissible: true);
          pr.style(message: translate("waitTips"));
          // 转圈圈和下载 md 文件
          await pr.show().then((_) {
            _getMDFile(document, pr);
          });
          //_clickDocument(document);
        },
      );

  Widget _createDialog(
      String _confirmContent, Function sureFunction, Function cancelFunction) {
    return AlertDialog(
      title: Text('警告!'),
      content: Text(_confirmContent),
      actions: <Widget>[
        FlatButton(onPressed: sureFunction, child: Text('确认')),
        FlatButton(onPressed: cancelFunction, child: Text('取消')),
      ],
    );
  }

  showInputAlertDialog(context) {
    showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('温馨提示'),
            content: Card(
              elevation: 0.0,
              child: Column(
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(
                        hintText: '请输入内容',
                        filled: true,
                        fillColor: Colors.grey.shade50),
                    onChanged: (String value) {},
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('取消'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('确定'),
              ),
            ],
          );
        });
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
            pr = new ProgressDialog(context, isDismissible: true);
            pr.style(message: "删除中...");
            await pr.show().then((_) async {
              print("点击了删除");

              await pr.hide().then((isHidden) async {
                print("旧对话框删除了?");
                print(isHidden);
                if (!isHidden) {
                  Navigator.of(context).pop();
                }
              });

              pr = new ProgressDialog(this.context,
                  type: ProgressDialogType.Download, isDismissible: true);
              pr.style(
                message: "0. 开始删除",
                progress: 0,
              );
              await pr.show();
              // 网络请求删除在线的文件夹
              //Utils.showMyToast("0. 开始删除", type: 0);
              await OneDriveDataDao.deleteFile(
                  context, tokenModel.token.accessToken, document.id);
              // 删除本地缓存的文件夹
              dataListModel.removeEle(document);
              dirCacheModel.delDirOrFileEle(parentIdModel.parentId, document);
              // 同时要修改配置文件
              // 如果是顶层 approot 则不用管
              // 否则
              String configId = configIdModel.configId;
              if (configId == "approot" ||
                  parentIdModel.parentId == parentIdModel.genId) {
                print("根目录, 不需要更新 _vnote.json 文件");
              } else {
                await pr.hide().then((isHidden) async {
                  print("0. 开始删除 对话框删除了?");
                  print(isHidden);
                  if (!isHidden) {
                    Navigator.of(this.context).pop();
                  }
                });
                pr = new ProgressDialog(this.context,
                    type: ProgressDialogType.Download, isDismissible: true);
                pr.style(
                  message: "1. 下载 _vnote.json",
                  progress: 40,
                );
                await pr.show();
                //Utils.showMyToast("1. 下载 _vnote.json", type: 0);
                print("接下来开始下载当前目录下的 _vnote.json 文件, 然后更新它的字段");
                await OneDriveDataDao.getFileContent(
                        context, tokenModel.token.accessToken, configId)
                    .then((value) async {
                  print("拿到的 _vnote.json 文件数据为: " + value.toString());
                  print("要干掉的文件/文件夹名字: " + document.name);

                  await pr.hide().then((isHidden) async {
                    print("1. 下载 _vnote.json 对话框删除了?");
                    print(isHidden);
                    if (!isHidden) {
                      Navigator.of(this.context).pop();
                    }
                  });
                  pr = new ProgressDialog(this.context,
                      type: ProgressDialogType.Download, isDismissible: true);
                  pr.style(
                    message: "2. 更新 _vnote.json",
                    progress: 80,
                  );
                  await pr.show();
                  //Utils.showMyToast("2. 删除本地缓存", type: 0);
                  DesktopConfigModel desktopConfigModel =
                      DesktopConfigModel.fromJson(
                          json.decode(value.toString()));
                  //print("干掉之前: ");
                  //print(json.encode(desktopConfigModel));
                  if (document.isFile) {
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
                  } else {
                    desktopConfigModel.deleteFolder(document.name);
                  }
                  print("干掉之后: ");
                  print(json.encode(desktopConfigModel));
                  //Utils.showMyToast("3. 更新 _vnote.json", type: 0);
                  // 修改成功_vnote.json 之后, 就是更新这个文件
                  await OneDriveDataDao.updateContent(
                      context,
                      tokenModel.token.accessToken,
                      configId,
                      json.encode(desktopConfigModel));
                });
              }
            });
            Utils.showMyToast("删除完成");
            await pr.hide().then((isHidden) async {
              print("2. 更新 _vnote.json 对话框删除了?");
              print(isHidden);
              if (!isHidden) {
                Navigator.of(this.context).pop();
              }
            });
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
      title: document.isFile
          ? Text(translate("renameDialog.fileTitle"))
          : Text(translate("renameDialog.dirTitle")),
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
            if (document.isFile) {
              if (!fileOrFolderName.contains(".md")) {
                fileOrFolderName += ".md";
              }
            }
            if (fileOrFolderName != "") {
              pr = new ProgressDialog(context, isDismissible: true);
              pr.style(message: translate("waitTips"));
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
                  if (configIdModel.configId == "approot" ||
                      parentIdModel.parentId == parentIdModel.genId) {
                    print("根目录, 不需要更新 _vnote.json 文件");
                  } else {
                    print("接下来开始下载当前目录下的 _vnote.json 文件, 然后更新它的字段");
                    await OneDriveDataDao.getFileContent(
                            context,
                            tokenModel.token.accessToken,
                            configIdModel.configId)
                        .then((value) async {
                      print("拿到的 _vnote.json 文件数据为: " + value.toString());
                      print("要修改的文件/文件夹名字: " + oldFileOrFolderName);
                      DesktopConfigModel desktopConfigModel =
                          DesktopConfigModel.fromJson(
                              json.decode(value.toString()));
                      if (document.isFile) {
                        desktopConfigModel.renameFile(
                            oldFileOrFolderName, fileOrFolderName);

                        PersonalNoteModel personalNoteModel =
                            await Utils.getPersonalNoteModel();

                        personalNoteModel.renameFile(
                            document.id, fileOrFolderName);
                        LocalDocumentProvider localDocumentProvider =
                            Provider.of<LocalDocumentProvider>(this.context,
                                listen: false);

                        Utils.writeModelToFile(personalNoteModel);
                        await Utils.model2ListDocument().then((data) {
                          print("directory_page rename 这里拿到 _myNote.json 的数据");
                          localDocumentProvider.updateList(data);
                        });
                      } else {
                        desktopConfigModel.renameFolder(
                            oldFileOrFolderName, fileOrFolderName);
                      }

                      await OneDriveDataDao.updateContent(
                          context,
                          tokenModel.token.accessToken,
                          configIdModel.configId,
                          json.encode(desktopConfigModel));
                    });
                  }
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

  /// 添加目录的那个对话框
  Widget _addFolderDialog() {
    DataListProvider dataListModel =
        Provider.of<DataListProvider>(context, listen: false);
    ParentIdProvider parentIdModel =
        Provider.of<ParentIdProvider>(context, listen: false);
    TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);
    ConfigIdProvider configIdModel =
        Provider.of<ConfigIdProvider>(context, listen: false);
    DirAndFileCacheProvider dirCacheModel =
        Provider.of<DirAndFileCacheProvider>(context, listen: false);
    ImageFolderIdProvider _imageFolderId =
        Provider.of<ImageFolderIdProvider>(context, listen: false);
    String folderName = "";
    return CupertinoAlertDialog(
      title: Text(translate("createDialog.title")),
      content: Card(
        elevation: 0.0,
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                  hintText: translate("createDialog.hintTips"),
                  filled: true,
                  fillColor: Colors.grey.shade50),
              onChanged: (String value) {
                folderName = value;
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        CupertinoDialogAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(translate("createDialog.cancel")),
        ),
        CupertinoDialogAction(
          onPressed: () async {
            folderName = folderName.trim(); // 去空
            if (folderName != "") {
              String errorText = "";
              // 应该先关闭询问对话框
              Navigator.pop(context);
              pr = new ProgressDialog(context, isDismissible: true);
              pr.style(message: translate("waitTips"));
              await pr.show().then((_) async {
                await pr.hide();
                pr = new ProgressDialog(this.context,
                    type: ProgressDialogType.Download, isDismissible: true);
                pr.style(
                  message: "0. 开始新建文件夹",
                  progress: 0,
                );
                await pr.show();

                await OneDriveDataDao.createFolder(
                        context,
                        tokenModel.token.accessToken,
                        folderName,
                        parentIdModel.parentId)
                    .then((value) async {
                  //print("创建目录返回来的数据: " + value.toString());
                  if (value == null) {
                    print("创建文件夹网络请求失败");
                    errorText = "创建文件夹的请求超时! 请重试!!";
                  } else {
                    print("更新本地 dataList");
                    Map<String, dynamic> jsonData =
                        jsonDecode(value.toString());
                    String id = jsonData["id"];
                    String configId = configIdModel.configId;
                    String newFolderName = jsonData["name"];
                    String dateString = jsonData['lastModifiedDateTime'];
                    DateTime date = DateTime.parse(dateString);
                    Document doc = new Document(
                        id: id,
                        configId: configId,
                        imageFolderId: _imageFolderId.imageFolderId,
                        name: jsonData["name"],
                        isFile: false,
                        dateModified: date);
                    dataListModel.addEle(doc);
                    dirCacheModel.addDirOrFileEle(parentIdModel.parentId, doc);

                    // 下面是更新当前目录的 _vnote.json 文件
                    print("directory_page 此时的 configId: ");
                    print(configId);
                    if (configId == "approot" ||
                        configId == null ||
                        configId == "null") {
                      print("根目录, 不需要更新 _vnote.json 文件");
                    } else {
                      print(
                          "接下来开始下载当前目录下的 _vnote.json 文件, 然后更新它的 sub_directories 字段");

                      await pr.hide().then((isHidden){
                        print("0. 开始新建文件夹 对话框干掉了没?");
                        print(isHidden);
                        if(!isHidden){
                          Navigator.of(this.context).pop();
                        }
                      });
                      pr = new ProgressDialog(this.context,
                          type: ProgressDialogType.Download,
                          isDismissible: true);
                      pr.style(
                        message: "1. 下载 _vnote.json",
                        progress: 40,
                      );
                      await pr.show();
                      // 如果找到当前目录下的 _vnote.json 的 id???

                      await OneDriveDataDao.getFileContent(
                              context, tokenModel.token.accessToken, configId)
                          .then((value) async {
                        if (value == null) {
                          errorText = "创建文件夹的请求成功, 但是下载 _vnote.json 失败!";
                        } else {
                          print("要添加的文件夹名称: " + newFolderName);
                          Map<String, dynamic> newFolder =
                              jsonDecode('{"name":"$newFolderName"}');
                          DesktopConfigModel desktopConfigModel =
                              DesktopConfigModel.fromJson(
                                  json.decode(value.toString()));
                          //print("添加之前: ");
                          //print(json.encode(desktopConfigModel));
                          desktopConfigModel.addNewFolder(newFolder);
                          print("添加之后: ");
                          print(json.encode(desktopConfigModel));

                          await pr.hide().then((isHidden){
                            print("1. 下载 _vnote.json 对话框干掉了没?");
                            print(isHidden);
                            if(!isHidden){
                              Navigator.of(this.context).pop();
                            }
                          });
                          pr = new ProgressDialog(this.context,
                              type: ProgressDialogType.Download,
                              isDismissible: true);
                          pr.style(
                            message: "2. 更新 _vnote.json",
                            progress: 80,
                          );
                          await pr.show();
                          // 添加成功_vnote.json 之后, 就是更新这个文件
                          await OneDriveDataDao.updateContent(
                                  context,
                                  tokenModel.token.accessToken,
                                  configId,
                                  json.encode(desktopConfigModel))
                              .then((value) {
                            if (value == null) {
                              errorText = "更新 _vnote.json 失败!";
                            }
                          });
                        }
                      });
                    }

                    await pr.hide().then((isHidden){
                      print("2. 更新 _vnote.json 对话框干掉了没?");
                      print(isHidden);
                      if(!isHidden){
                        Navigator.of(this.context).pop();
                      }
                    });
                    pr = new ProgressDialog(this.context,
                        type: ProgressDialogType.Download, isDismissible: true);
                    pr.style(
                      message: "3. 给新建的目录添加 _vnote.json",
                      progress: 90,
                    );
                    await pr.show();
                    // 下面是给新创建的目录新增一个 _vnote.json 文件
                    await OneDriveDataDao.uploadFile(
                            context,
                            tokenModel.token.accessToken,
                            id,
                            Utils.newFolderJson(),
                            "_vnote.json")
                        .then((data) {
                      print("上传_vnote.json 文件之后返回的内容" + data.toString());
                      // 也许可以给新创建的这个目录缓存上直接加上这个 _vnote.json
                    });
                  }
                }).then((_) async {
                  await pr.hide().then((isHidden){
                    print("3. 给新建的目录添加 _vnote.json 对话框干掉了没?");
                    print(isHidden);
                    if(!isHidden){
                      Navigator.of(this.context).pop();
                    }
                  });
                  if (errorText != "") {
                    Fluttertoast.showToast(
                        msg: errorText,
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 3,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                });
              });
            } else {
              Navigator.pop(context);
            }
          },
          child: Text(translate("createDialog.ok")),
        ),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
