import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vnote/models/document.dart';
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
  List<Document> documentList = [
    Document(
      name: 'Desktop',
      dateModified: DateTime.now(),
      isFile: false,
      childData: [
        Document(name: 'Projects', dateModified: DateTime.now(), childData: [
          Document(
              name: 'flutter_app',
              dateModified: DateTime.now(),
              childData: [
                Document(
                  name: 'README.md',
                  dateModified: DateTime.now(),
                  isFile: true,
                ),
                Document(
                  name: 'pubspec.yaml',
                  dateModified: DateTime.now(),
                  isFile: true,
                ),
                Document(
                  name: 'pubspec.lock',
                  dateModified: DateTime.now(),
                  isFile: true,
                ),
                Document(
                  name: '.gitignore',
                  dateModified: DateTime.now(),
                  isFile: true,
                ),
                Document(
                  name: 'lib',
                  dateModified: DateTime.now(),
                  isFile: false,
                  childData: [
                    Document(
                      name: 'main.dart',
                      dateModified: DateTime.now(),
                      isFile: true,
                    ),
                  ],
                ),
              ])
        ]),
        Document(
          name: 'test.sh',
          dateModified: DateTime.now(),
          isFile: true,
        ),
        Document(
          name: 'image.png',
          dateModified: DateTime.now(),
          isFile: true,
        ),
        Document(
          name: 'image2.png',
          dateModified: DateTime.now(),
          isFile: true,
        ),
        Document(
          name: 'image3.png',
          dateModified: DateTime.now(),
          isFile: true,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我是目录', style: TextStyle(fontSize: fontSize40)),
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
