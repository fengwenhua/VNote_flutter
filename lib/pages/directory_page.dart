import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/provider/data_list_model.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/widgets/directory_widget.dart';
import 'package:vnote/widgets/file_widget.dart';
import 'package:vnote/widgets/tree_view.dart';

class DirectoryPage extends StatefulWidget {
  int level;
  List<Document> documents;

  DirectoryPage(
      {Key key, @required int level, @required List<Document> documents})
      : this.level = level,
        this.documents = documents,
        super(key: key);

  @override
  _DirectoryPageState createState() => _DirectoryPageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _DirectoryPageState extends State<DirectoryPage> {
  ScrollController controller = ScrollController();
  List<double> position = [];
  List<Document> documents = <Document>[];
  List<Document> rootDocuments = <Document>[];

  @override
  void initState() {
    super.initState();
    documents = widget.documents;
    rootDocuments = documents;
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
              title: documents.length>0&&documents[0]?.parent == null
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
      initPathFiles(documents[0].parent.parent?.childData ?? rootDocuments);
      jumpToPosition(false);
    } else {
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
        //print("进入了, 第一项是:");

        documents = list;
        //print(documents[0].name);
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

  List<Widget> _getChildList(List<Document> childDocuments) {
    return childDocuments.map((document) {
      // 目录
      if (!document.isFile) {
        return Container(
            margin: EdgeInsets.only(left: 16),
            child: TreeViewChild(
              parent: _getDirectoryWidget(document: document),
              children: _getChildList(document.childData),
              onTap: () {
                print("要展开的是: " + document.name);
              },
            ));
      }

      // 文件
      return Container(
        margin: const EdgeInsets.only(left: 4.0),
        child: _getFileWidget(document: document),
      );
    }).toList();
  }

  Widget _getDirectoryWidget({@required Document document}) => DirectoryWidget(
      directoryName: document.name,
      lastModified: document.dateModified,
      onPressedNext: () {
        print("点开 ${document.name} 目录, 然后显示该目录下的所有文件");
        //print("第一个目录是: ");
        //print(document.childData[0].name);
        if(document.childData.length>0){
          position.add(controller.offset);
          initPathFiles(document.childData);
          jumpToPosition(true);
        }
      });

  FileWidget _getFileWidget({@required Document document}) => FileWidget(
        fileName: document.name,
        lastModified: document.dateModified,
      );
}
