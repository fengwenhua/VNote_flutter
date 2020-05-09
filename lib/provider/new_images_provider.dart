import 'package:flutter/material.dart';

/// [NewImageListProvider] 存储用户编辑笔记过程中新增的本地图片集合
class NewImageListProvider with ChangeNotifier {
  List<String> _newImageList = new List<String>();
  List<String> get newImageList => _newImageList;

  /// [addImage] 根据 [imagePath] 新增图片 list
  void addImage(String imagePath) {
    _newImageList.add(imagePath);
    notifyListeners();
  }

  /// [clearList] 在处理完所有的新增图片之后, 需要清空该 list
  void clearList() {
    _newImageList.clear();
    notifyListeners();
  }
}
