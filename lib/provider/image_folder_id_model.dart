import 'package:flutter/material.dart';

class ImageFolderIdModel with ChangeNotifier{
  String _imageFolderId;
  String get imageFolderId => _imageFolderId;

  void updateImageFolderId(String newId){
    _imageFolderId = newId;
    notifyListeners();
  }
}