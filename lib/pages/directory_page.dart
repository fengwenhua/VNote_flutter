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
import 'package:vnote/widgets/tree_view.dart';

class DirectoryPage extends StatefulWidget {
  int level;
  List<Document> documents;

  DirectoryPage(
      {Key key, @required List<Document> documents})
      :this.documents = documents,
        super(key: key);

  @override
  _DirectoryPageState createState() => _DirectoryPageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _DirectoryPageState extends State<DirectoryPage> {
  ScrollController controller = ScrollController();
  List<double> position = [];
  List<Document> treeDocuments = <Document>[];
  List<Document> documents = <Document>[];
  List<Document> rootDocuments = <Document>[];
  List<String> ids = []; // 存放 id

  Future<dynamic> _myClick(Document document, int count)  {
    return showDialog<dynamic>(
        context: context,
        builder: (ctx){
          return Center(
            child: new ShowProgress(_postData(document, count)),
          );
        }
    );
  }

  /// 根据点击的 id 来查找目录
  Future<List<Document>> getChildData(String accessToken, String id) async{
    return await DocumentListUtil.instance.getChildList(context, accessToken, id, (list){
//      print("根据 id 获取了List, 如下:");
//      list.forEach((i) {
//        print(i.name);
//      });
//      DataListModel dataListModel = Provider.of<DataListModel>(context);
//      dataListModel.updateValue(list);
    });
  }

  void addChild(List<String> ids, List<Document> treeDocuments, List<Document> childList){
        int count = 0;
        if(ids.length>0){
          String id = ids[0];
          ids.removeAt(0);
          for(Document d in treeDocuments){
            if(d.id == id){
              break;
            }else{
              count++;
            }
          }
        }else{
          treeDocuments = childList;
        }

        addChild(ids, treeDocuments[count].childData, childList);
  }

  _postData(Document document, int count) async{
    TokenModel tokenModel = Provider.of<TokenModel>(context);
    // 网络请求
    await getChildData(tokenModel.token.accessToken, document.id).then((data){
      print("############");
      print(document?.parent?.name);
      print("当前处理的是 '"+ document.name + "'文件夹下的");
      document.childData  = data;
      // 这里应该遍历里面的元素, 让他们的爸爸变成 document
      data.forEach((i) {
        i.parent = document;
      });
      print("第一个元素: '" + document.childData[0].name);
      print("他的爸爸是: " + document.childData[0].parent.name);
      print(document.childData[0]?.parent?.parent?.name);
      print("############");
      // 显示
      if(document.childData.length>0){
        position.add(controller.offset);
        anoInitPathFiles(document.childData, count);
        //initPathFiles(document.childData);
        jumpToPosition(true);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    documents = widget.documents;
    rootDocuments = documents;
    treeDocuments = documents;
  }

  @override
  Widget build(BuildContext context) {
//    final tokenModel = Provider.of<TokenModel>(context);
//    String token = tokenModel.token.accessToken;
//    print("这里获得的token是: " + token);
//    DocumentListUtil.instance.getDirectoryList(context, token, (list){
//      documentList = list;
//      print("获取了List, 如下:");
//      documentList.forEach((i) => print(i.name));
//    });
    DataListModel dataListModel = Provider.of<DataListModel>(context);

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
          appBar: AppBar(
              title: documents.length>0 && documents[0]?.parent == null
                  ? Text('目录', style: TextStyle(fontSize: fontSize40))
                  : Text(documents[0].parent.name, style: TextStyle(fontSize: fontSize40)),
              leading: documents[0]?.parent == null
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
          body: documents.length == 0
              ? Center(
                  child: Text("The folder is empty"),
                )
              : Scrollbar(
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    controller: controller,
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      return getListWidget(widget.level, documents)
                          .elementAt(index);
                    },
                  ),
                )),
    );
  }

  Future<bool> onWillPop() async {
    if (documents[0].parent != null) {
      ids.removeLast(); // 回退一级就要将末尾的 id 值删掉
      print("进来了");
      print("当前: " + documents[0].name);
      print("爸爸: " + documents[0].parent.name);
      if(documents[0].parent.parent != null){
        print("爷爷: " + documents[0].parent.parent.name);
      }else{
        print("没有爷爷");
      }

      initPathFiles(documents[0].parent.parent?.childData ?? rootDocuments);
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

  // 初始化该路径下的文件、文件夹
  void initPathFiles(List<Document> list) {
    try {
      setState(() {
        // 问题出现在这里, 所以他们只有爸爸
        documents = list;
        //print(documents[0].name);
      });
    } catch (e) {
      print(e);
      print("Directory does not exist！");
    }
  }

  void anoInitPathFiles(List<Document> list, int count){
    print("进入了另一个初始化的方法");
    try {
      setState(() {
        print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
        print(documents[0].name);
        print(documents[0].parent?.name);
        print(documents[1].parent?.name);

        documents = list;
        print(documents[0].name);
        print(documents[0].parent?.name);
        print(documents[0].parent?.parent?.name);
        print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
      });
    } catch (e) {
      print(e);
      print("Directory does not exist！");
    }
  }

  List<Widget> getListWidget(int level, List<Document> childDocuments) {
    ///print("展开的内容如下:");
    List<Document> newDocument = new List<Document>();
    childDocuments.forEach((i) {
      Document d = new Document(
          id: i.id,
          name: i.name,
          dateModified: i.dateModified,
          parent: i.parent,
          childData: i.childData);
      newDocument.add(d);
    });

    return newDocument.map((document) {
      if (!document.isFile){
        return Container(
          margin: const EdgeInsets.only(left: 4.0),
          child: _getDirectoryWidget(document: document),
        );
      }else{
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
        // 试试将下标传进去
        int count = 0;
        for(Document d in documents){
          if(d.id == document.id){
            break;
          }else{
            count ++;
          }
        }
        ids.add(document.id);  // 将 id 加进来
        print("Click index: " + count.toString());
        _myClick(document, count);


      });

  FileWidget _getFileWidget({@required Document document}) => FileWidget(
        fileName: document.name,
        lastModified: document.dateModified,
      );
}

/// 加载的圈圈
class ShowProgress extends StatefulWidget {
  ShowProgress(this.requestCallback);
  final Future<dynamic> requestCallback;//这里Null表示回调的时候不指定类型
  @override
  _ShowProgressState createState() => new _ShowProgressState();
}

class _ShowProgressState extends State<ShowProgress> {
  @override
  initState() {
    super.initState();
    new Timer(new Duration(milliseconds: 10), () {//每隔10ms回调一次
      widget.requestCallback.then((dynamic) {//这里Null表示回调的时候不指定类型
        Navigator.of(context).pop();//所以pop()里面不需要传参,这里关闭对话框并获取回调的值
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new CircularProgressIndicator(),//获取控件实例
    );
  }
}