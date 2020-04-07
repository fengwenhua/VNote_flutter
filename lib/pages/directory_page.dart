import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vnote/dao/onedrive_data_dao.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/provider/data_list_model.dart';
import 'package:vnote/provider/image_folder_id_model.dart';
import 'package:vnote/provider/parent_id_model.dart';
import 'package:vnote/provider/token_model.dart';
import 'package:vnote/utils/document_list_util.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/widgets/directory_widget.dart';
import 'package:vnote/widgets/file_widget.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../application.dart';

class DirectoryPage extends StatefulWidget {
  List<Document> documents;

  DirectoryPage({Key key, @required List<Document> documents})
      : this.documents = documents,
        super(key: key);

  @override
  _DirectoryPageState createState() => _DirectoryPageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _DirectoryPageState extends State<DirectoryPage>
    with AutomaticKeepAliveClientMixin {
  // 进度圈圈
  ProgressDialog pr;
  ScrollController controller = ScrollController();
  List<double> position = [];
  List<Document> rootDocuments = <Document>[];

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
    DataListModel dataListModel =
        Provider.of<DataListModel>(context, listen: false);

    for (Document d in dataListModel.dataList) {
      if (d.name == "_v_images") {
        // 在这里拿到了 imageFolder 的 id, 即是 _v_images的 id
        final _imageFolderId =
            Provider.of<ImageFolderIdModel>(context, listen: false);
        _imageFolderId.updateImageFolderId(d.id);

        break;
      }
    }
    // 测试 Application.sp.containsKey(document.id)
    if (Application.sp.containsKey(document.id)) {
      // 本地有文档缓存
      print("使用本地文章缓存");
      await Future.delayed(Duration(milliseconds: 100), () {
        prt.hide().whenComplete(() {
          String route =
              '/preview?content=${Uri.encodeComponent(Application.sp.getString(document.id))}&id=${Uri.encodeComponent(document.id)}&name=${Uri.encodeComponent(document.name)}';
          Application.router
              .navigateTo(context, route, transition: TransitionType.fadeIn);
        });
      });
    } else {
      // 本地没有, 从网络下载
      print("从网络下载文章");
      await getMDFileContent(tokenModel.token.accessToken, document.id, prt)
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
              timeInSecForIos: 3,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          // 这里需要跳转到预览页面
          print("跳转到预览页面");
          prt.hide().whenComplete(() {
            String route =
                '/preview?content=${Uri.encodeComponent(data.toString())}&id=${Uri.encodeComponent(document.id)}&name=${Uri.encodeComponent(document.name)}';
            Application.router
                .navigateTo(context, route, transition: TransitionType.fadeIn);
          });
        }
      });
    }
  }

  /// [_postData] 是根据 [id] 或者下一级目录的内容
  /// 如果[update]为 true 代表只是更新当前目录
  /// 如果 id=="approot"则用另一个请求
  _postData(String id, {bool update = false}) async {
    // 获取当前 token
    TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);

    if (id == "approot") {
      await DocumentListUtil.instance
          .getNotebookList(context, tokenModel.token.accessToken, (data) async {
        if (data.length > 0) {
          DataListModel dataListModel =
              Provider.of<DataListModel>(context, listen: false);
          dataListModel.updateCurrentDir(data);
          pr.hide().whenComplete(() {
            jumpToPosition(true);
          });
        } else {
          Fluttertoast.showToast(
              msg: "GG, 笔记本都没了??",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 3,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          pr.hide().whenComplete(() {
            jumpToPosition(true);
          });
          final _parentId = Provider.of<ParentIdModel>(context, listen: false);
          _parentId.goBackParentId();
        }
      });
    } else {
      // 网络请求
      await getChildData(tokenModel.token.accessToken, id).then((data) {
        // 显示
        if (data.length > 0) {
          if (update) {
            position.removeLast();
          }
          position.add(controller.offset);

          DataListModel dataListModel =
              Provider.of<DataListModel>(context, listen: false);
          if (update) {
            dataListModel.updateCurrentDir(data);
          } else {
            dataListModel.goAheadDataList(data);
          }
          //initPathFiles(document.childData);
          pr.hide().whenComplete(() {
            jumpToPosition(true);
          });
        } else {
          Fluttertoast.showToast(
              msg: "该文件夹内容为空",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 3,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          pr.hide().whenComplete(() {
            jumpToPosition(true);
          });
          final _parentId = Provider.of<ParentIdModel>(context, listen: false);
          _parentId.goBackParentId();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    print("进入 directory_page 的 initState 方法");
    rootDocuments = widget.documents;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("进入 directory_page 的 build 方法");
    pr = new ProgressDialog(context, isDismissible: true);
    pr.style(message: '慢慢等吧...');
    DataListModel dataListModel =
        Provider.of<DataListModel>(context, listen: false);

    ParentIdModel parentIdModel =
        Provider.of<ParentIdModel>(context, listen: false);

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
            title: Text(parentIdModel.parentName,
                style: TextStyle(fontSize: fontSize40)),
            actions: <Widget>[
              // 非隐藏起来的菜单
              new IconButton(
                  icon: new Icon(Icons.refresh),
                  tooltip: "Update",
                  onPressed: () async {
                    // 手动点击更新按钮
                    await pr.show().then((_) {
                      String parentId = parentIdModel.parentId;
                      // 接下来是根据这个 id 刷新获取数据

                      _postData(parentId, update: true);
                    });
                  })
            ],
            leading: parentIdModel.parentId == "approot"
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
        body: dataListModel.dataList.length == 0
            ? Center(
                child: Text("该目录为空"),
              )
            : Scrollbar(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  controller: controller,
                  itemCount: dataListModel.dataList.length,
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
    final _parentId = Provider.of<ParentIdModel>(context, listen: false);

    DataListModel dataListModel =
        Provider.of<DataListModel>(context, listen: false);
    if (_parentId.parentId != "approot") {
      print("不在根目录");
      _parentId.goBackParentId();
      dataListModel.goBackDataList();
      jumpToPosition(false);
    } else {
      print("在根目录了, 所有没有返回的操作了, 也不需要给 parentid 弹栈了");
      print("打开侧滑菜单");
      Navigator.pop(context);
    }
    return false;
  }

  void jumpToPosition(bool isEnter) async {
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

  List<Widget> getListWidget(List<Document> childDocuments) {
    ///print("展开的内容如下:");
//    List<Document> newDocument = new List<Document>();
//    childDocuments.forEach((i) {
//      print("处理 " + i.name);
//
//      Document d = new Document(
//          id: i.id,
//          name: i.name,
//          isFile: i.isFile,
//          dateModified: i.dateModified,
//          parent: i.parent,
//          childData: i.childData);
//      newDocument.add(d);
//    });

    return childDocuments.map((document) {
      //print("要处理的是: " + document.name);
      if (!document.isFile) {
        // 目录
        return Dismissible(
          key: Key(document.id),
          child: Container(
            margin: const EdgeInsets.only(left: 4.0),
            child: _getDirectoryWidget(document: document),
          ),
          direction: DismissDirection.endToStart, // 滑动方向从右到左
          onDismissed: (direction) {
            // 展示 SnackBar
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('删除了${document.name}'),
              duration: Duration(milliseconds: 400),
            ));
          },
          confirmDismiss: (direction) async {
            var _confirmContent = "确认删除${document.name}?";
            var _alertDialog = _createDialog(_confirmContent, () {
              // 展示 SnackBar
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('确认删除${document.name}'),
                duration: Duration(milliseconds: 400),
              ));
              Navigator.of(context).pop(true);
            }, () {
              // 展示 SnackBar
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('不删除${document.name}'),
                duration: Duration(milliseconds: 400),
              ));
              Navigator.of(context).pop(false);
            });
            var isDismiss = await showDialog(
                context: context,
                builder: (context) {
                  return _alertDialog;
                });

            // 这里写删除逻辑
            if (isDismiss) {
              TokenModel tokenModel =
                  Provider.of<TokenModel>(context, listen: false);
              DataListModel dataListModel =
                  Provider.of<DataListModel>(context, listen: false);
              // 网络请求删除在线的文件夹
              await OneDriveDataDao.deleteFile(
                  context, tokenModel.token.accessToken, document.id);
              // 删除本地缓存的文件夹
              dataListModel.removeEle(document);
            }

            return isDismiss;
          },
          background: Container(
              color: Colors.red,
              child: Center(
                child: ListTile(
                  trailing: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
              )),
        );
      } else {
        // 文件
        return Dismissible(
          key: Key(document.id),
          child: Container(
            margin: const EdgeInsets.only(left: 4.0),
            child: _getFileWidget(document: document),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            // 展示 SnackBar
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('删除了${document.name}'),
              duration: Duration(milliseconds: 400),
            ));
          },
          confirmDismiss: (direction) async {
            var _confirmContent = "确认删除${document.name}?";
            var _alertDialog = _createDialog(_confirmContent, () {
              // 展示 SnackBar
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('确认删除${document.name}'),
                duration: Duration(milliseconds: 400),
              ));
              Navigator.of(context).pop(true);
            }, () {
              // 展示 SnackBar
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('不删除${document.name}'),
                duration: Duration(milliseconds: 400),
              ));
              Navigator.of(context).pop(false);
            });
            var isDismiss = await showDialog(
                context: context,
                builder: (context) {
                  return _alertDialog;
                });

            // 这里写删除逻辑
            if (isDismiss) {
              TokenModel tokenModel =
                  Provider.of<TokenModel>(context, listen: false);
              DataListModel dataListModel =
                  Provider.of<DataListModel>(context, listen: false);
              // 网络请求删除在线的文件夹
              await OneDriveDataDao.deleteFile(
                  context, tokenModel.token.accessToken, document.id);
              // 删除本地缓存的文件夹
              dataListModel.removeEle(document);
            }
            return isDismiss;
          },
          background: Container(
              color: Colors.red,
              child: Center(
                child: ListTile(
                  trailing: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
              )),
        );
      }
    }).toList();
  }

  Widget _getDirectoryWidget({@required Document document}) => DirectoryWidget(
      directoryName: document.name,
      lastModified: document.dateModified,
      onPressedNext: () async {
        print("点开 ${document.name} 目录, 然后显示该目录下的所有文件");

        // 这里可以先查看本地缓存

        // 记得将这个 id 记录下来, 以后刷新用
        final _parentId = Provider.of<ParentIdModel>(context, listen: false);
        _parentId.goAheadParentId(document.id, document.name);

        // 转圈圈和网络请求
        //_myClick(document);
        await pr.show().then((_) {
          _postData(document.id);
        });
      });

  FileWidget _getFileWidget({@required Document document}) => FileWidget(
        fileName: document.name,
        lastModified: document.dateModified,
        onPressedNext: () async {
          print("点击了 ${document.name} 文件");
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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
