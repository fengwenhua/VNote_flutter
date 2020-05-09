import 'package:flutter/material.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/utils/my_stack.dart';

/// [DataListModel] 类, 使用栈操作当前目录需要显示的 data
class DataListModel with ChangeNotifier {
  MyStack<List<Document>> _dataList = MyStack<List<Document>>();
  List<Document> get dataList {
    if (_dataList.isNotEmpty) {
      return _dataList.top();
    } else {
      return null;
    }
  }

  /// [getLength] 因为在显示的时候需要干掉一些黑名单, 所以要重新计算长度
  int getLength() {
    int length = _dataList.top().length;
    _dataList.top().forEach((f) {
      if (BLACK_NAME.contains(f.name)) {
        length--;
      }
    });
    return length;
  }

  /// [removeEle] 删除栈顶 list 中的某个元素, 干掉某个文件/目录时要调用的
  void removeEle(Document document) {
    List<Document> list = _dataList.pop();
    print("要干掉的是" + document.name);
    list.removeWhere((test) => test.name == document.name);
    _dataList.push(list);
    notifyListeners();
  }

  /// [addEle] 给栈顶 list 添加新元素
  void addEle(Document document) {
    // 先弹出来
    List<Document> list;
    if (_dataList.isNotEmpty) {
      list = _dataList.pop();
    } else {
      print("根目录没有数据的情况");
      list = new List<Document>();
    }
    // 文件就插到后面
    if (document.isFile) {
      list.add(document);
    } else {
      // 文件夹就查到一开始
      list.insert(0, document);
    }

    // 然后压回去
    _dataList.push(list);
    notifyListeners();
  }

  /// [renameEle] 根据 [id] 和 [name] 重命名栈顶 list 的某个元素
  void renameEle(String id, String name) {
    List<Document> list = _dataList.pop();
    List<Document> newList = list.map((f) {
      if (f.id == id) {
        f.name = name;
      }
      return f;
    }).toList();
    _dataList.push(newList);
    notifyListeners();
  }

  /// [goAheadDataList] 点开来目录, 所以要压栈
  void goAheadDataList(List<Document> newDataList) {
    _dataList.push(newDataList);
    notifyListeners();
  }

  /// [goBackDataList] 点击了返回, 所以要弹栈
  void goBackDataList() {
    _dataList.pop();
    notifyListeners();
  }

  /// [updateCurrentDir] 点击了刷新, 所以要刷新当前栈顶 list
  void updateCurrentDir(List<Document> newDataList) {
    // 首先先干掉当前的
    if (_dataList.isNotEmpty) _dataList.pop();
    // 在添加新的
    _dataList.push(newDataList);
    notifyListeners();
  }
}
