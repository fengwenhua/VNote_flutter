import 'package:flutter/material.dart';
import 'package:vnote/models/document_model.dart';

/// [NotebooksProvider] 类用于记录笔记本
class NotebooksProvider with ChangeNotifier {
  List<Document> _list;

  List<Document> get list => _list;

  /// [updateList] 更新笔记本 list
  void updateList(List<Document> newList) {
    print("更新笔记本 list");
    newList.forEach((f){
      print(f.name);
    });
    print("内容如上~~~~~");
    _list = newList;
    notifyListeners();
  }
}
