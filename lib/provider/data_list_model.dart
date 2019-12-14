import 'package:flutter/material.dart';
import 'package:vnote/models/document_model.dart';

class DataListModel with ChangeNotifier{
  List<Document> _list = new List<Document>();
  List<Document> get dataList => _list;

  void updateValue(List<Document> p){
    _list = p;
    // 这里可能会不生效
    notifyListeners();
  }
}