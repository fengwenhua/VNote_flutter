import 'package:flutter/material.dart';
import 'package:vnote/utils/my_stack.dart';

/// 存储当前目录的爸爸的 id, 用于刷新用
class ParentIdModel with ChangeNotifier{
  MyStack<String> _parentId = MyStack<String>();

  String get getParentId => _parentId.top();

  void goAheadParentId(String newId){
    _parentId.push(newId);
    notifyListeners();
  }

  void goBackParentId(){
    _parentId.pop();
    notifyListeners();
  }
}