import 'package:flutter/material.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/utils/global.dart';
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

  /// 因为在显示的时候需要干掉一些黑名单, 所以要重新计算长度
  int getLength(){
    int length = _dataList.top().length;
    _dataList.top().forEach((f){
      if(BLACK_NAME.contains(f.name)){
        length--;
      }
    });
    //print("重新计算 dataList 的长度是: ");
    //print(length);
    return length;
  }

  /// 删除元素
  void removeEle(Document document){
    List<Document> list = _dataList.pop();
    print("要干掉的是" + document.name);
    //list.remove(document);
    list.removeWhere((test)=>test.name==document.name);
//    print("是否还在: ${list.contains(document)}" );
//    print("这个鬼 list 还有: ");
//    list.forEach((i){
//      print(i.name);
//    });
//    print("!~~~~~~~~分割服~~~~~~~");
//    print("还剩下啥?");
//    list.forEach((f){
//      print(f.name);
//    });
//    print("~~~~~以上~~~~~");
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
    // 文件就插到后面
    if(document.isFile){
      list.add(document);
    }else{
      // 文件夹就查到一开始
      list.insert(0, document);
    }

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