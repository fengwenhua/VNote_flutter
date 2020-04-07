import 'package:flutter/material.dart';
import 'package:vnote/utils/my_stack.dart';

/// 存储当前目录的爸爸的 id, 用于刷新用
class ParentIdModel with ChangeNotifier{
  MyStack<String> _parentId = MyStack<String>();
  MyStack<String> _parentName = MyStack<String>();

  String get parentId => _parentId.top();
  String get parentName => _parentName.top();

  void goAheadParentId(String newId, String newName){
    _parentId.push(newId);
    _parentName.push(newName);
    notifyListeners();
  }

  void goBackParentId(){
    _parentId.pop();
    _parentName.pop();
    notifyListeners();
  }
}