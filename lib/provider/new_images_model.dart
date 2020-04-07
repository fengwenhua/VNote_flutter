
import 'package:flutter/material.dart';

/// 存储新增的本地图片集合
class NewImageListModel with ChangeNotifier{
  List<String> _newImageList = new List<String>();
  List<String> get newImageList => _newImageList;

  void addImage(String imagePath){
    _newImageList.add(imagePath);
    notifyListeners();
  }

  void clearList(){
    _newImageList.clear();
    notifyListeners();
  }
}