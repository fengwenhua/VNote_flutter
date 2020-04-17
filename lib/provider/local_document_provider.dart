import 'package:flutter/material.dart';
import 'package:vnote/models/document_model.dart';

class LocalDocumentProvider with ChangeNotifier {
  List<Document> _list;

  List<Document> get list => _list;

  void updateList(List<Document> newList) {
    print("更新这个本地文档 list");
    newList.forEach((f){
      print(f.name);
    });
    print("内容如上~~~~~");
    _list = newList;
    notifyListeners();
  }
}
