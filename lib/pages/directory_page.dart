import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/provider/data_list_model.dart';
import 'package:vnote/provider/token_model.dart';
import 'package:vnote/utils/document_list_util.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/widgets/directory_widget.dart';
import 'package:vnote/widgets/file_widget.dart';
import 'package:vnote/widgets/show_progress_widget.dart';

class DirectoryPage extends StatefulWidget {
  List<Document> documents;

  DirectoryPage({Key key, @required List<Document> documents})
      : this.documents = documents,
        super(key: key);

  @override
  _DirectoryPageState createState() => _DirectoryPageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _DirectoryPageState extends State<DirectoryPage> with AutomaticKeepAliveClientMixin{
  ScrollController controller = ScrollController();
  List<double> position = [];
  List<Document> rootDocuments = <Document>[];


  Future<dynamic> _myClick(Document document) {
    return showDialog<dynamic>(
        context: context,
        builder: (ctx) {
          return Center(
            child: new ShowProgress(_postData(document)),
          );
        });
  }

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

  _postData(Document document) async {
    DataListModel dataListModel = Provider.of<DataListModel>(context);
//    print("#################################");
//    print("要处理的是: " + document.name);
//    for (Document p in dataListModel.dataList) {
//      if (p.id == document.id) {
//        print("找到了! 看看有没有儿子");
//        if (p.childData != null) {
//          print(p.childData[0].name);
//        }
//        break;
//      }
//    }
//    print("#################################");
    TokenModel tokenModel = Provider.of<TokenModel>(context);
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

        DataListModel dataListModel = Provider.of<DataListModel>(context);
        dataListModel.updateValue(document.childData);
        //initPathFiles(document.childData);

        jumpToPosition(true);
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
    DataListModel dataListModel = Provider.of<DataListModel>(context);

    return WillPopScope(
        onWillPop: onWillPop,
        child: Consumer<DataListModel>(
          builder: (context, DataListModel model, _) => Scaffold(
            appBar: AppBar(
                title: model.dataList.length > 0 && model.dataList[0]?.parent == null
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
                          Icons.keyboard_arrow_left,
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
                        return getListWidget(model.dataList)
                            .elementAt(index);
                      },
                    ),
                  ),
          ),
        ));
  }

  Future<bool> onWillPop() async {
    DataListModel dataListModel = Provider.of<DataListModel>(context);
    if (dataListModel.dataList[0].parent != null) {
      //initPathFiles(dataListModel.dataList[0].parent.parent?.childData ?? rootDocuments);
      dataListModel.updateValue(dataListModel.dataList[0]?.parent?.parent?.childData ?? rootDocuments);
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
      onPressedNext: () {
        print("点开 ${document.name} 目录, 然后显示该目录下的所有文件");

        // 转圈圈和网络请求
        _myClick(document);
      });

  FileWidget _getFileWidget({@required Document document}) => FileWidget(
        fileName: document.name,
        lastModified: document.dateModified,
        onPressedNext: (){
          print("点击了 ${document.name} 文件");
        },
      );

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}



