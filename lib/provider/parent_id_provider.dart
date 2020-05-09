import 'package:flutter/material.dart';
import 'package:vnote/utils/my_stack.dart';

/// [ParentIdProvider] 存储当前目录的爸爸的 id, 用于刷新用
class ParentIdProvider with ChangeNotifier {
  MyStack<String> _parentId = MyStack<String>();
  MyStack<String> _parentName = MyStack<String>();
  String _genId = "";
  String get parentId => _parentId.top();
  String get parentName => _parentName.top();
  String get genId => _genId;

  void setGenId(String id) {
    this._genId = id;
    print("这里设置 vnote 根目录的 id 是: " + id);
    notifyListeners();
  }

  void goAheadParentId(String newId, String newName) {
    _parentId.push(newId);
    _parentName.push(newName);
    print("goAhead 之后");
    print("此时 ParentId 是: " + newId);
    print("此时 ParentName 是: " + newName);
    notifyListeners();
  }

  void goBackParentId() {
    _parentId.pop();
    _parentName.pop();
    print("goBack 之后");
    print("此时 ParentId 是: " + _parentId.top());
    print("此时 ParentName 是: " + _parentName.top());
    notifyListeners();
  }
}
