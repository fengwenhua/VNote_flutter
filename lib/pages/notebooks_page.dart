import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:vnote/application.dart';
import 'package:vnote/dao/onedrive_data_dao.dart';
import 'package:vnote/models/desktop_config_model.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/provider/config_id_provider.dart';
import 'package:vnote/provider/data_list_provider.dart';
import 'package:vnote/provider/dir_and_file_cache_provider.dart';
import 'package:vnote/provider/image_folder_id_provider.dart';
import 'package:vnote/provider/notebooks_list_provider.dart';
import 'package:vnote/provider/parent_id_provider.dart';
import 'package:vnote/provider/token_provider.dart';
import 'package:vnote/utils/document_list_util.dart';
import 'package:vnote/utils/utils.dart';

class NotebooksPage extends StatefulWidget {
  @override
  _NotebooksPageState createState() => _NotebooksPageState();
}

class _NotebooksPageState extends State<NotebooksPage> {
  SlidableController slidableController = SlidableController();
  ProgressDialog pr;

  @override
  Widget build(BuildContext context) {
    ParentIdProvider parentIdModel =
        Provider.of<ParentIdProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          translate("notebooks.title"),
        ),
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.add),
              tooltip: 'Add Folder',
              onPressed: () {
                print("点击添加笔记本的按钮");

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
                  print("Update Notebooks");

                  // 接下来是根据这个 id 刷新获取数据
                  _updateNoteBooks();
                });
              })
        ],
      ),
      body: Consumer<NotebooksProvider>(
        builder: (context, NotebooksProvider notebooksProvider, _) =>
            notebooksProvider.list == null || notebooksProvider.list.length == 0
                ? Center(
                    child: Text(translate("noNoteBookTips")),
                  )
                : Scrollbar(
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: notebooksProvider.list.length,
                      itemBuilder: (context, index) {
                        return getListWidget(notebooksProvider.list)
                            .elementAt(index);
                      },
                    ),
                  ),
      ),
    );
  }

  List<Widget> getListWidget(List<Document> documents) {
    List<Document> childDocuments = new List<Document>();
    TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);
    documents.forEach((f) {
      childDocuments.add(f);
    });

    return childDocuments.map((document) {
      // 目录
      return Slidable(
        key: Key(document.id),
        actionPane: SlidableDrawerActionPane(),
        controller: slidableController,
        actionExtentRatio: 0.25,
        child: Container(
            margin: const EdgeInsets.only(left: 4.0),
            child: _getNotebooksWidget(document: document)),
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
                    return _renameDialog(context, document, tokenModel);
                  });
            },
          ),
          IconSlideAction(
            caption: translate("item.delete"),
            color: Colors.red,
            icon: Icons.delete,
            closeOnTap: true,
            onTap: () async {
              print("点击了删除");
              showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return _deleteDialog(context, document, tokenModel);
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
                  return _deleteDialog(context, document, tokenModel);
                });
          },
          onDismissed: (actionType) {
            print("actionType: " + actionType.toString());
          },
        ),
      );
    }).toList();
  }

  Widget _getNotebooksWidget({@required Document document}) => NotebooksWidget(
      directoryName: document.name,
      onPressedNext: () async {
        print("点开 ${document.name} 笔记本");
        if (Application.sp.getString("choose_notebook_id") == document.id) {
          print("点击同一个笔记本, 不用管!");
          Navigator.of(context).pop();
        } else {
          _chooseNotebook(document);
        }
      });

  /// [] 选择笔记本
  _chooseNotebook(Document document) async {
    // 记得将这个 id 记录下来, 以后刷新用
    Application.sp.setString("choose_notebook_id", document.id);
    Application.sp.setString("choose_notebook_name", document.name);

    ParentIdProvider parentIdModel =
        Provider.of<ParentIdProvider>(context, listen: false);
    DirAndFileCacheProvider dirCacheModel =
        Provider.of<DirAndFileCacheProvider>(context, listen: false);
    DataListProvider dataListModel =
        Provider.of<DataListProvider>(context, listen: false);
    ConfigIdProvider configIdModel =
        Provider.of<ConfigIdProvider>(context, listen: false);
    TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);

    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "加载笔记本中...");
    await pr.show();

    await DocumentListUtil.instance
        .getChildList(
            context, tokenModel.token.accessToken, document.id, (list) {})
        .then((data) {
      if (data == null) {
        print("获取的儿子为空, 不处理!");
      } else {
        print("在 splash_screen 页面, 获取的儿子有数据");
        print("操作的id和 name 如下:");
        print(document.id);
        print(document.name);
        parentIdModel.clear();
        parentIdModel.goAheadParentId(document.id, document.name);
        parentIdModel.setGenId(document.id);

        dataListModel.clear();
        dataListModel.goAheadDataList(data);
        for (Document d in dataListModel.dataList) {
          if (d.name == "_vnote.json") {
            configIdModel.updateConfigId(d.id);
            break;
          }
        }
        dirCacheModel.clear();
        dirCacheModel.addDirAndFileList(document.id, data);
        print("完成了笔记本的加载工作");
        Navigator.of(context).pop();
      }
    }).whenComplete(() async => await pr.hide());
  }

  /// [_updateNoteBooks] 更新笔记本
  _updateNoteBooks() async {
    TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);

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
          NotebooksProvider notebooksProvider =
              Provider.of<NotebooksProvider>(context, listen: false);
          notebooksProvider.updateList(data);
        }
        pr.hide().whenComplete(() {
          //jumpToPosition(true);
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
          //jumpToPosition(true);
        });

        // 因为点击目录的时候, 已经记录的 parentId , 所以如果当前目录为空, 所以要撤销
        //parentIdModel.goBackParentId();
      }
    });
  }

  /// [_renameDialog] 重命名对话框
  Widget _renameDialog(
      BuildContext context, Document document, TokenModel tokenModel) {
    String fileOrFolderName = "";
    NotebooksProvider notebooksProvider =
        Provider.of<NotebooksProvider>(context, listen: false);
    ParentIdProvider parentIdModel =
        Provider.of<ParentIdProvider>(context, listen: false);
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

            fileOrFolderName = fileOrFolderName.trim(); //去空
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

                  notebooksProvider.renameEle(document.id, fileOrFolderName);
                  parentIdModel.rename(fileOrFolderName);
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

  /// [_deleteDialog] 删除对话框
  Widget _deleteDialog(
      BuildContext context, Document document, TokenModel tokenModel) {
    DataListProvider dataListModel =
        Provider.of<DataListProvider>(context, listen: false);
    ConfigIdProvider configIdModel =
        Provider.of<ConfigIdProvider>(context, listen: false);
    DirAndFileCacheProvider dirCacheModel =
        Provider.of<DirAndFileCacheProvider>(context, listen: false);
    ParentIdProvider parentIdModel =
        Provider.of<ParentIdProvider>(context, listen: false);
    NotebooksProvider notebooksProvider =
        Provider.of<NotebooksProvider>(context, listen: false);
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
            pr = new ProgressDialog(context, isDismissible: false);
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
                  type: ProgressDialogType.Download, isDismissible: false);
              pr.style(
                message: "0. 开始删除",
                progress: 0,
              );
              await pr.show();
              // 网络请求删除在线的文件夹
              //Utils.showMyToast("0. 开始删除", type: 0);
              await OneDriveDataDao.deleteFile(
                  context, tokenModel.token.accessToken, document.id);
//              // 删除本地缓存的文件夹
//              dataListModel.removeEle(document);
//              dirCacheModel.delDirOrFileEle(parentIdModel.parentId, document);
              // 1. 删除笔记本 list对应 document
              notebooksProvider.removeEle(document);
              // 2. 参考点击文件夹(记得清空 dataListModel 和 dirCacheModel)
              parentIdModel.clear();
              dataListModel.clear();
              dirCacheModel.clear();
            });
            Utils.showMyToast("删除完成");
            await pr.hide().then((isHidden) async {
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

  /// 添加目录的那个对话框
  Widget _addFolderDialog() {
    TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);
    ConfigIdProvider configIdModel =
        Provider.of<ConfigIdProvider>(context, listen: false);

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
                  message: "0. 开始新建笔记本",
                  progress: 0,
                );
                await pr.show();

                await OneDriveDataDao.createFolder(context,
                        tokenModel.token.accessToken, folderName, "approot")
                    .then((value) async {
                  //print("创建目录返回来的数据: " + value.toString());
                  if (value == null) {
                    print("创建文件夹网络请求失败");
                    errorText = "创建文件夹的请求超时! 请重试!!";
                  } else {
                    print("更新 notebooksList");
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
                        name: newFolderName,
                        isFile: false,
                        dateModified: date);

                    NotebooksProvider notebooksProvider =
                        Provider.of<NotebooksProvider>(context, listen: false);
                    notebooksProvider.addNotebook(doc);

                    await pr.hide().then((isHidden) {
                      print("更新 _vnote.json 对话框干掉了没?");
                      print(isHidden);
                      if (!isHidden) {
                        Navigator.of(this.context).pop();
                      }
                    });
                    pr = new ProgressDialog(this.context,
                        type: ProgressDialogType.Download, isDismissible: true);
                    pr.style(
                      message: "1. 给新建的目录添加 _vnote.json",
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
                  await pr.hide().then((isHidden) {
                    print("给新建的目录添加 _vnote.json 对话框干掉了没?");
                    print(isHidden);
                    if (!isHidden) {
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
}

class NotebooksWidget extends StatefulWidget {
  final String directoryName;
  final VoidCallback onPressedNext;

  NotebooksWidget({
    Key key,
    @required this.directoryName,
    this.onPressedNext,
  }) : super(key: key);

  @override
  _NotebooksWidgetState createState() => _NotebooksWidgetState();
}

class _NotebooksWidgetState extends State<NotebooksWidget> {
  @override
  Widget build(BuildContext context) {
    Widget titleWidget = GestureDetector(
      child: Text(widget.directoryName),
      onTap: widget.onPressedNext,
    );
    //Icon folderIcon = Icon(Icons.folder);
    IconButton folderIcon = IconButton(
      icon: Icon(Icons.folder),
      onPressed: () => widget.onPressedNext,
    );

    return Card(
        child: ListTile(
      leading: folderIcon,
      title: titleWidget,
      onTap: () {
        setState(() {
          widget.onPressedNext();
        });
      },
    ));
  }
}
