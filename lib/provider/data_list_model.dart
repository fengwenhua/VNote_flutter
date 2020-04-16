import 'package:flutter/material.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/utils/my_stack.dart';

class DataListModel with ChangeNotifier{
  MyStack<List<Document>> _dataList = MyStack<List<Document>>();
  List<Document> get dataList {
    if(_dataList.isNotEmpty){
      return _dataList.top();
    }else{
     return null;
    }
  }

  void removeEle(Document document){
    List<Document> list = _dataList.pop();
    print("要干掉的是" + document.name);
    list.remove(document);
//    print("是否还在: ${list.contains(document)}" );
//    print("这个鬼 list 还有: ");
//    list.forEach((i){
//      print(i.name);
//    });
//    print("!~~~~~~~~分割服~~~~~~~");
    _dataList.push(list);
    notifyListeners();
  }

  /// 添加新元素
  void addEle(Document document){
    // 先弹出来
    List<Document> list;
    if(_dataList.isNotEmpty){
      list = _dataList.pop();
    }else{
      print("根目录没有数据的情况");
      list = new List<Document>();
    }

    list.add(document);
    // 然后压回去
    _dataList.push(list);
    notifyListeners();
  }

  void renameEle(String id, String name){
    List<Document> list = _dataList.pop();
    List<Document> newList = list.map((f){
      if(f.id == id){
        print("DataList 重命名!");
        f.name = name;
      }
      return f;
    }).toList();
    _dataList.push(newList);
    notifyListeners();
  }

  void goAheadDataList(List<Document> newDataList){
    _dataList.push(newDataList);
    notifyListeners();
  }

  void goBackDataList(){
    _dataList.pop();
    notifyListeners();
  }

  void updateCurrentDir(List<Document> newDataList){
    // 首先先干掉当前的
    if(_dataList.isNotEmpty)
        _dataList.pop();
    // 在添加新的
    _dataList.push(newDataList);
    notifyListeners();
  }

}