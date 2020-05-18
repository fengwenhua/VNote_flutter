import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/provider/notebooks_list_provider.dart';
import 'package:vnote/provider/token_provider.dart';
import 'package:vnote/widgets/directory_widget.dart';

class NotebooksPage extends StatefulWidget {
  @override
  _NotebooksPageState createState() => _NotebooksPageState();
}

class _NotebooksPageState extends State<NotebooksPage> {
  SlidableController slidableController = SlidableController();
  @override
  Widget build(BuildContext context) {
    NotebooksProvider notebooksProvider =
        Provider.of<NotebooksProvider>(context, listen: false);
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
          )),
      body: notebooksProvider.list == null || notebooksProvider.list.length == 0
          ? Center(
              child: Text(translate("noNoteBookTips")),
            )
          : Scrollbar(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: notebooksProvider.list.length,
                itemBuilder: (context, index) {
                  return getListWidget(notebooksProvider.list).elementAt(index);
                },
              ),
            ),
    );
  }

  List<Widget> getListWidget(List<Document> documents) {
    List<Document> childDocuments = new List<Document>();

    documents.forEach((f) {
      childDocuments.add(f);
    });

    return childDocuments.map((document) {
      //print("要处理的是: " + document.name);

      TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);

      NotebooksProvider notebooksProvider =
          Provider.of<NotebooksProvider>(context, listen: false);

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
//              showDialog<bool>(
//                  context: context,
//                  builder: (context) {
//                    return _renameDialog(
//                        context, document, tokenModel, dataListModel);
//                  });
            },
          ),
          IconSlideAction(
            caption: translate("item.delete"),
            color: Colors.red,
            icon: Icons.delete,
            closeOnTap: true,
            onTap: () async {
              print("点击了删除");
//              showDialog<bool>(
//                  context: context,
//                  builder: (context) {
//                    return _deleteDialog(
//                        context, document, tokenModel, dataListModel);
//                  });
            },
          ),
        ],
        dismissal: SlidableDismissal(
          child: SlidableDrawerDismissal(),
//          onWillDismiss: (actionType) {
//            return showDialog<bool>(
//                context: context,
//                builder: (context) {
//                  return _deleteDialog(
//                      context, document, tokenModel, dataListModel);
//                });
//          },
          onDismissed: (actionType) {
            print("actionType: " + actionType.toString());
          },
        ),
      );
    }).toList();
  }

  Widget _getNotebooksWidget({@required Document document}) => DirectoryWidget(
      directoryName: document.name,
      lastModified: document.dateModified,
      onPressedNext: () async {
        print("点开 ${document.name} 笔记本");
        // 记得将这个 id 记录下来, 以后刷新用
      });
}
