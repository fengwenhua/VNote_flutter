import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/provider/data_list_model.dart';
import 'package:vnote/provider/image_folder_id_model.dart';
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
        final _imageFolderId =Provider.of<ImageFolderIdModel>(context, listen: false);
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
          if(prt.isShowing()){
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

  _postData(Document document) async {
    DataListModel dataListModel =
        Provider.of<DataListModel>(context, listen: false);

    // 获取当前 token
    TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);
    // 网络请求
    await getChildData(tokenModel.token.accessToken, document.id).then((data) {
      document.childData = data;
      // 这里应该遍历里面的元素, 让他们的爸爸变成 document
      data.forEach((i) {
        i.parent = document;
      });
      // 显示
      if (document.childData.length > 0) {
        position.add(controller.offset);

        DataListModel dataListModel =
            Provider.of<DataListModel>(context, listen: false);
        dataListModel.updateValue(document.childData);
        //initPathFiles(document.childData);
        pr.hide().whenComplete(() {
          jumpToPosition(true);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    rootDocuments = widget.documents;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    //print("进入 build 方法");
    pr = new ProgressDialog(context, isDismissible: true);
    pr.style(message: '慢慢等吧...');
    DataListModel dataListModel =
        Provider.of<DataListModel>(context, listen: false);

    return WillPopScope(
        onWillPop: onWillPop,
        child: Consumer<DataListModel>(
          builder: (context, DataListModel model, _) => Scaffold(
            appBar: AppBar(
                title: model.dataList.length > 0 &&
                        model.dataList[0]?.parent == null
                    ? Text('目录', style: TextStyle(fontSize: fontSize40))
                    : Text(model.dataList[0].parent.name,
                        style: TextStyle(fontSize: fontSize40)),
                leading: model.dataList[0]?.parent == null
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
            body: model.dataList.length == 0
                ? Center(
                    child: Text("The folder is empty"),
                  )
                : Scrollbar(
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      controller: controller,
                      itemCount: model.dataList.length,
                      itemBuilder: (context, index) {
                        return getListWidget(model.dataList).elementAt(index);
                      },
                    ),
                  ),
          ),
        ));
  }

  Future<bool> onWillPop() async {
    DataListModel dataListModel =
        Provider.of<DataListModel>(context, listen: false);
    if (dataListModel.dataList[0].parent != null) {
      //initPathFiles(dataListModel.dataList[0].parent.parent?.childData ?? rootDocuments);
      dataListModel.updateValue(
          dataListModel.dataList[0]?.parent?.parent?.childData ??
              rootDocuments);
      jumpToPosition(false);
    } else {
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
    List<Document> newDocument = new List<Document>();
    childDocuments.forEach((i) {
      Document d = new Document(
          id: i.id,
          name: i.name,
          isFile: i.isFile,
          dateModified: i.dateModified,
          parent: i.parent,
          childData: i.childData);
      newDocument.add(d);
    });

    return newDocument.map((document) {
      if (!document.isFile) {
        return Container(
          margin: const EdgeInsets.only(left: 4.0),
          child: _getDirectoryWidget(document: document),
        );
      } else {
        // 文件
        return Container(
          margin: const EdgeInsets.only(left: 4.0),
          child: _getFileWidget(document: document),
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

        // 转圈圈和网络请求
        //_myClick(document);
        await pr.show().then((_){
          _postData(document);
        });

      });

  FileWidget _getFileWidget({@required Document document}) => FileWidget(
        fileName: document.name,
        lastModified: document.dateModified,
        onPressedNext: () async {
          print("点击了 ${document.name} 文件");
          // 转圈圈和下载 md 文件
          await pr.show().then((_){
            _getMDFile(document, pr);
          });
          //_clickDocument(document);
        },
      );

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
