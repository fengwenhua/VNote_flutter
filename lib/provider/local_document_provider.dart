import 'package:flutter/material.dart';
import 'package:vnote/models/document_model.dart';

/// [LocalDocumentProvider] 类用于读取 _myNote.json 之后显示本地 list, 由于只在笔记 tab 中, 所以不需要栈
class LocalDocumentProvider with ChangeNotifier {
  List<Document> _list;

  List<Document> get list => _list;

  /// [updateList] 更新本地文档 list
  void updateList(List<Document> newList) {
    print("\n\n\n");
    print("#################################################################");
    print("更新这个本地文档 list");
    newList.forEach((f){
      print(f.name);
    });
    print("内容如上~~~~~");
    print("#################################################################");
    print("\n\n\n");
    _list = newList;
    notifyListeners();
  }
}
