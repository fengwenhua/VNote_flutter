import 'package:flutter/material.dart';

/// 存储当前目录的爸爸的 id, 用于刷新用
class ParentIdModel with ChangeNotifier{
  String _parentId;
  String get getParentId => _parentId;

  void updateParentId(String newId){
    _parentId = newId;
    notifyListeners();
  }
}