import 'package:flutter/material.dart';

/// 存储每个md 文件同目录下的_v_images 的 id
class ImageFolderIdModel with ChangeNotifier{
  String _imageFolderId;
  String get imageFolderId => _imageFolderId;

  void updateImageFolderId(String newId){
    _imageFolderId = newId;
    notifyListeners();
  }
}