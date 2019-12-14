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

    List pathsList = [];
    var pathsSet = new Set();
    List pathsListSet = [];

    // 路径
    for (Value value in oneDriveDataModel.value) {
      //print(value.parentReference.path);
      String p = value.parentReference.path;
      if (p == "/drive/root:/应用") {
        continue;
      } else if (p == "/drive/root:/应用/VNote") {
        continue;
      }
      p = p.replaceAll("/drive/root:/应用/VNote/", "");
      pathsList.add(p);
    }
    // pathsList.forEach((i) => print(i));

    for (var p in pathsList) {
      pathsSet.add(p);
    }
    print(pathsSet.toList());
    pathsListSet = pathsSet.toList();
    //print("排序后:");
    // List排序排序
    pathsListSet.sort();
    //pathsListSet.forEach((i) => print(i));

    // 遍历生成result
    //print("\n");
    for (var p in pathsListSet) {
      //print("开始处理: " + p);
      go(p, result);
      //print("\n");
    }

    // 写到本地

    if (callBack != null) {
      callBack(result);
    }
  }

  void go(String path, List<Document> result) {
    if (path.isEmpty) {
      return;
    }
    // 临时字符串
    String tempStr = path.split("/")[0];
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
    if (path.split("/").length > 1) {
      newStr = path.substring(tempStr.length + 1);
      //print("剩下的数据: " + newStr);
    } else {
      newStr = "";
    }

    if (!skip) {
      List<Document> l = new List<Document>();
      Document document = new Document(
          name: tempStr, dateModified: DateTime.now(), childData: l);
      if (result == null) {
        result = List<Document>();
      }
      print("添加一个节点: " + tempStr);
      result.add(document);
    }

    if (newStr != "") {
      //print("Count: " + count.toString());
      go(newStr, result[count].childData);
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
