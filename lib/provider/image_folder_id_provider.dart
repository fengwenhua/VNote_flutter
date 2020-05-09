import 'package:flutter/material.dart';

/// [ImageFolderIdProvider] 存储每个 md 文件同目录下的 _v_images 的 id
class ImageFolderIdProvider with ChangeNotifier {
  String _imageFolderId;
  String get imageFolderId => _imageFolderId;

  void updateImageFolderId(String newId) {
    _imageFolderId = newId;
    notifyListeners();
  }
}
