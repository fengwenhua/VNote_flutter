import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vnote/application.dart';

class PreviewModel with ChangeNotifier{
  String _previewContent = "";
  String get previewContent => _previewContent;

  void updateContent(String content){
    _previewContent = content;
    notifyListeners();
  }
}