import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:vnote/application.dart';
import 'package:vnote/dao/onedrive_data_dao.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/models/onedrive_data_model.dart';

class DocumentListUtil {
  factory DocumentListUtil() => _getInstance();

  static DocumentListUtil get instance => _getInstance();
  static DocumentListUtil _instance;

  DocumentListUtil._internal();

  static DocumentListUtil _getInstance() {
    if (_instance == null) {
      _instance = new DocumentListUtil._internal();
    }
    return _instance;
  }

  void getDirectoryList(BuildContext context, String token, Function callBack,
      {bool fromNetwork = false}) async {
    List<Document> result = new List<Document>();

    OneDriveDataModel oneDriveDataModel;
    // 先拿到json, 应该先从本地拿, 再从网络拿, 看情况
    if (fromNetwork || !_hasRawData()) {
      oneDriveDataModel = await _getDataFromNetwork(context, token);
    } else {
      if (!_hasRawData()) {
        // 本地没有数据
        oneDriveDataModel = await _getDataFromNetwork(context, token);
      } else {
        oneDriveDataModel = await _getDataFromLocal();
      }
    }

    // 解析json,  获取所有的路径

    var pathsList = <Item>[];
    var pathsListSet = <Item>[];
    //List pathsList = [];
    //List pathsListSet = [];

    var pathsSet = new Set<Item>();

    // 路径
    for (Value value in oneDriveDataModel.value) {
      //print(value.parentReference.path);
      String id = value.parentReference.id;
      String path = value.parentReference.path;
      if (path == "/drive/root:/应用") {
        continue;
      } else if (path == "/drive/root:/应用/VNote") {
        continue;
      }
      path = path.replaceAll("/drive/root:/应用/VNote/", "");

      pathsList.add(Item(id: id, path: path));
    }
    // pathsList.forEach((i) => print(i));

    // 去重
    for (var p in pathsList) {
      pathsSet.add(p);
    }
    //print(pathsSet.toList());
    pathsListSet = pathsSet.toList();
    //print("排序后:");
    // List 按照 path 排序
    pathsListSet.sort((a, b) => b.path.compareTo(a.path));
    //pathsListSet.forEach((i) => print(i));

    // 遍历生成result
    //print("\n");
    for (var p in pathsListSet) {
      //print("开始处理: " + p);
      go(p, result, null);
      //print("\n");
    }

    // 写到本地

    if (callBack != null) {
      callBack(result);
    }

//    // 测试List是否构建成功
//    print("测试List是否构建成功");
//    print(result[0].name);
//    print(result[0].childData[0].name);
  }

  void go(Item item, List<Document> result, Document parent) {
    if (item.path.isEmpty) {
      return;
    }
    // 临时字符串
    String tempStr = item.path.split("/")[0];
    String newStr;
    bool skip = false;
    int count = 0;

    //print("要处理的节点: " + tempStr);
    // 应该先查一下该节点是否存在

    for (Document d in result) {
      if (d.name == tempStr) {
        //print("跳过该节点: " + tempStr);
        skip = true;
        break;
      }
      count++;
    }

    // 删除提取出来的字符串, 包括/
    if (item.path.split("/").length > 1) {
      newStr = item.path.substring(tempStr.length + 1);
      //print("剩下的数据: " + newStr);
    } else {
      newStr = "";
    }

    if (!skip) {
      List<Document> l = new List<Document>();
      Document document = new Document(
          id: item.id,
          name: tempStr,
          dateModified: DateTime.now(),
          parent: parent,
          childData: l);
      if (result == null) {
        result = List<Document>();
      }
      print("添加一个节点: " + tempStr);
      print("路径: " + item.path);
      result.add(document);
    }

    if (newStr != "") {
      //print("Count: " + count.toString());
      item.path = newStr;
      go(item, result[count].childData, result[count]);
    }
  }

  List<Document> getAllList() {
    List<Document> result;

    return result;
  }

  Future<OneDriveDataModel> _getDataFromNetwork(
      BuildContext context, String token) async {
    print("从网络获得数据");
    OneDriveDataModel oneDriveDataModel;
    await OneDriveDataDao.getAllData(context, token).then((value) {
      oneDriveDataModel =
          OneDriveDataModel.fromJson(json.decode(value.toString()));
      //print("Model内容如下:");
      //print(json.encode(oneDriveDataModel));
    });
    return oneDriveDataModel;
  }

  bool _hasRawData() {
    if (Application.sp.getString("raw_data") != null) {
      print("本地有原始数据");
      return true;
    } else {
      return false;
    }
  }

  OneDriveDataModel _getDataFromLocal() {
    print("从本地获得数据");
    return OneDriveDataModel.fromJson(
        json.decode(Application.sp.getString("raw_data")));
  }
}

class Item {
  Item({this.id = '', this.path = ''});
  String id;
  String path;
}
