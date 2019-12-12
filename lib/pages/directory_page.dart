import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/widgets/directory_widget.dart';
import 'package:vnote/widgets/file_widget.dart';
import 'package:vnote/widgets/tree_view.dart';

class DirectoryPage extends StatefulWidget {
  @override
  _DirectoryPageState createState() => _DirectoryPageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _DirectoryPageState extends State<DirectoryPage> {
  List<Document> documentList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我是目录', style: TextStyle(fontSize: fontSize40)),
          leading: IconButton(
            icon: Icon(Icons.dehaze, color: Colors.white,),
            onPressed: (){
              // 打开Drawer抽屉菜单
              print("点击了侧滑按钮");
              Scaffold.of(context).openDrawer();
            },
          )
      ),
      body: TreeView(
        startExpanded: false,
        children: _getChildList(documentList),
      ),
    );
  }

  List<Widget> _getChildList(List<Document> childDocuments) {
    return childDocuments.map((document) {
      // 目录
      if (!document.isFile) {
        return Container(
          margin: EdgeInsets.only(left: 16),
          child: TreeViewChild(
            parent: _getDocumentWidget(document: document),
            children: _getChildList(document.childData),
          ),
        );
      }

      // 文件
      return Container(
        margin: const EdgeInsets.only(left: 4.0),
        child: _getDocumentWidget(document: document),
      );
    }).toList();
  }

  Widget _getDocumentWidget({@required Document document}) => document.isFile
      ? _getFileWidget(document: document)
      : _getDirectoryWidget(document: document);

  DirectoryWidget _getDirectoryWidget({@required Document document}) =>
      DirectoryWidget(
        directoryName: document.name,
        lastModified: document.dateModified,
        onPressedNext: (){
          print("点开目录, 然后显示该目录下的所有文件");
        },
      );

  FileWidget _getFileWidget({@required Document document}) => FileWidget(
        fileName: document.name,
        lastModified: document.dateModified,
      );
}
