import 'package:flutter/material.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/utils/my_stack.dart';

class DataListModel with ChangeNotifier{
  MyStack<List<Document>> _dataList = MyStack<List<Document>>();
  List<Document> get dataList => _dataList.top();

  void goAheadDataList(List<Document> newDataList){
    _dataList.push(newDataList);
    notifyListeners();
  }

  void goBackDataList(){
    _dataList.pop();
    notifyListeners();
  }

}