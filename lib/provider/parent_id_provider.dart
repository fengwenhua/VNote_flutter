import 'package:flutter/material.dart';
import 'package:vnote/utils/my_stack.dart';

/// [ParentIdProvider] 存储当前目录的爸爸的 id, 用于刷新用
class ParentIdProvider with ChangeNotifier {
  MyStack<String> _parentIdStack = MyStack<String>();
  MyStack<String> _parentNameStack = MyStack<String>();
  String _genId = "";

  String get parentId => _parentIdStack.top();
  String get parentName => _parentNameStack.top();
  String get rootId => _genId;

  /// [setGenId] 设置根 id
  void setGenId(String id) {
    this._genId = id;
    // print("这里设置 vnote 根目录的 id 是: " + id);
    notifyListeners();
  }

  /// [goAheadParentId] 用户点击了目录, 则设置新的 parentId 的 [newId] 和 [newName]
  void goAheadParentId(String newId, String newName) {
    _parentIdStack.push(newId);
    _parentNameStack.push(newName);
    // print("goAhead 之后");
    // print("此时 ParentId 是: " + newId);
    // print("此时 ParentName 是: " + newName);
    notifyListeners();
  }

  /// [goBackParentId] 用户点击了返回, 则用回之前的 id 和 name
  void goBackParentId() {
    _parentIdStack.pop();
    _parentNameStack.pop();
    // print("goBack 之后");
    // print("此时 ParentId 是: " + _parentIdStack.top());
    // print("此时 ParentName 是: " + _parentNameStack.top());
    notifyListeners();
  }
}
