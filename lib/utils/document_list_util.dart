import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:vnote/application.dart';
import 'package:vnote/dao/onedrive_data_dao.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/models/onedrive_data_model.dart';
import 'package:vnote/provider/preview_model.dart';

import 'global.dart';

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

  Future<List<Document>> getNotebookList(
      BuildContext context, String token, Function callBack,
      {bool fromNetwork = false}) async {
    List<Document> result = new List<Document>();
    OneDriveDataModel oneDriveDataModel;
    while (true) {
      oneDriveDataModel = await _getNoteBookFromNetwork(context, token);
      if (oneDriveDataModel != null) {
        break;
      } else {
        print("gg, 特么的没有数据呀!!!");
        print("再来一发");
      }
    }

    print("笔记本如下:");
    // 路径

    for (Value value in oneDriveDataModel.value) {
      // print(value.id);
      print(value.name);
      Document parent =
          new Document(id: value.parentReference.id, name: "VNote");
      bool isFile = false;
      for (String tmp in WHILE_NAME) {
        if (value.name.endsWith(tmp)) {
          isFile = true;
        }
      }
      Document temp = new Document(
          id: value.id,
          name: value.name,
          isFile: isFile,
          dateModified: DateTime.parse(value.lastModifiedDateTime));
      result.add(temp);
    }

    if (callBack != null) {
      callBack(result);
    }

    return result;
  }

  /// 根据 imageFolderId 与 imageUrls 对比获得所有图片
  Future<List<Document>> getImagesList(BuildContext context, String token,
      String id, List<String> imageUrls, Function callBack) async {
    print("根据 imageFolderId 与 imageUrls 对比获得所有图片");
    List<Document> result = new List<Document>();
    return await _getImagesFromNetwork(context, token, id)
        .then((oneDriveDataModel) {
      for (String imageUrl in imageUrls) {
        for (Value value in oneDriveDataModel.value) {
          if (value.name == imageUrl) {
            Document temp = new Document(
                id: value.id,
                name: value.name,
                isFile: true,
                dateModified: DateTime.parse(value.lastModifiedDateTime));
            result.add(temp);
            // 这里可以算出来获取图片的总数
          }
        }
      }

      if (callBack != null) {
        callBack(result);
      }
      return result;
    });
  }

  // 根据 id 获得儿子们
  Future<List<Document>> getChildList(
      BuildContext context, String token, String id, Function callBack,
      {bool fromNetwork = false}) async {
    List<Document> result = new List<Document>();
    OneDriveDataModel oneDriveDataModel;

    while (true) {
      oneDriveDataModel = await _getChildFromNetwork(context, token, id);
      if (oneDriveDataModel != null) {
        break;
      } else {
        print("gg, 特么的没有数据呀1!!!");
        print("再来一发1");
      }
    }

    print("目录如下:");
    // 1. 根据 file 和 folder 字段来判断是文件还是文件夹
    // 2. 过滤, 文件只要白名单之内的
    // 3. 分两个循环, 先插入目录, 再插入文件

    /// 插入目录
    for (Value value in oneDriveDataModel.value) {
      if (value.folder != null) {
        Document temp = new Document(
            id: value.id,
            name: value.name,
            isFile: false,
            dateModified: DateTime.parse(value.lastModifiedDateTime));
        result.add(temp);
      }
    }

    /// 插入文件
    for (Value value in oneDriveDataModel.value) {
      if (value.file != null) {
        /// 过滤
        bool skip = true;
        for (String tmp in WHILE_NAME) {
          if (value.name.endsWith(tmp)) {
            skip = false;
          }
        }
        // 虽然是文件, 但是不在白名单之内, 跳过
        if (skip) {
          continue;
        }

        // print(value.id);
        print(value.name);

        Document temp = new Document(
            id: value.id,
            name: value.name,
            isFile: true,
            dateModified: DateTime.parse(value.lastModifiedDateTime));
        result.add(temp);
      }
    }

    if (callBack != null) {
      callBack(result);
    }

    return result;
  }

  Future<List<Document>> getDirectoryList(
      BuildContext context, String token, Function callBack,
      {bool fromNetwork = false}) async {
    List<Document> result = new List<Document>();

    OneDriveDataModel oneDriveDataModel;
    // 先拿到json, 应该先从本地拿, 再从网络拿, 看情况
    oneDriveDataModel = await _getDataFromNetwork(context, token);
//    if (fromNetwork || !_hasRawData()) {
//      oneDriveDataModel = await _getDataFromNetwork(context, token);
//    } else {
//      if (!_hasRawData()) {
//        // 本地没有数据
//        oneDriveDataModel = await _getDataFromNetwork(context, token);
//      } else {
//        oneDriveDataModel = await _getDataFromLocal();
//      }
//    }

    // 解析json,  获取所有的路径

    var pathsList = <Item>[];
    var pathsListSet = <Item>[];
    //List pathsList = [];
    //List pathsListSet = [];

    var pathsSet = new Set<Item>();

    print("开始打印每一项, 检查是否缺少");
    // 路径
    for (Value value in oneDriveDataModel.value) {
      print(value.name + "  " + value.id);
      //print(value.parentReference.path);
      String id = value.parentReference.id;
      String path = value.parentReference.path;
      String name = value.parentReference.name;
      if (path == "/drive/root:/应用") {
        continue;
      } else if (path == "/drive/root:/应用/VNote") {
        continue;
      } else if (path.contains("_v_recycle_bin") ||
          path.contains("_v_images") ||
          path.contains("_v_attachments")) {
        continue;
      }
      path = path.replaceAll("/drive/root:/应用/VNote/", "");

      pathsList.add(Item(id: id, path: path, name: name));
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
    // 遍历插入文件
//    result.forEach((i){
//      for (Value value in oneDriveDataModel.value){
//        if(value.parentReference.id == i.id){
//          print("处理id: " + i.id);
//          print("给 "+i.name + "增加文件: " + value.name);
//          Document document = new Document(
//              id: value.id,
//              name: value.name,
//              dateModified: DateTime.parse(value.lastModifiedDateTime),
//          isFile: true);
//          i.childData.add(document);
//        }
//      }
//    });
    return result;
  }

  void go(Item item, List<Document> result, Document parent) {
    if (item.path.isEmpty) {
      return;
    }
    // 临时字符串
    //print("传入路径: "+item.path);
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
      item.fullPath = item.fullPath + tempStr + "/";
      //print("剩下的数据: " + newStr);
    } else {
      newStr = "";
    }

    if (!skip) {
      List<Document> l = new List<Document>();
      Document document = new Document(
          name: tempStr,
          dateModified: DateTime.now(),
          parent: parent,
          childData: l);
      if (result == null) {
        result = List<Document>();
      }
      print("添加一个节点: " + tempStr);
      //print("路径: " + item.path);
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
      if (value == null) {
        print("value 真特么没有数据");
      } else {
        oneDriveDataModel =
            OneDriveDataModel.fromJson(json.decode(value.toString()));
        //print("Model内容如下:");
        //print(json.encode(oneDriveDataModel));
      }
    });
    return oneDriveDataModel;
  }

  /// 从网络获取笔记本, 即第一层文件夹
  Future<OneDriveDataModel> _getNoteBookFromNetwork(
      BuildContext context, String token) async {
    print("从网络获取文件夹");
    OneDriveDataModel oneDriveDataModel;
    await OneDriveDataDao.getNoteBookData(context, token).then((value) {
      if (value == null) {
        print("麻蛋, value 为空, 没有数据");
      } else {
        oneDriveDataModel =
            OneDriveDataModel.fromJson(json.decode(value.toString()));
        //print("Model内容如下:");
        //print(json.encode(oneDriveDataModel));
      }
    });
    return oneDriveDataModel;
  }

  /// 根据 id 从网络获取目录
  Future<OneDriveDataModel> _getChildFromNetwork(
      BuildContext context, String token, String id) async {
    print("根据 id 从网络获取文件夹");
    OneDriveDataModel oneDriveDataModel;

    await OneDriveDataDao.getChildData(context, token, id).then((value) {
      if (value == null) {
        print("可能因为超时等原因, 没有数据");
      } else {
        oneDriveDataModel =
            OneDriveDataModel.fromJson(json.decode(value.toString()));
        print("get 到Model内容");
        //print(json.encode(oneDriveDataModel));
      }
    });
    // 返回 model
    print("返回 oneDriveDataModel");
    return oneDriveDataModel;
  }

  /// 根据 image id 从网络获取图片列表
  Future<OneDriveDataModel> _getImagesFromNetwork(
      BuildContext context, String token, String id) async {
    print("根据 imageId 从网络获取图片列表");
    OneDriveDataModel oneDriveDataModel;
    await OneDriveDataDao.getImagesID(context, token, id).then((value) {
      oneDriveDataModel =
          OneDriveDataModel.fromJson(json.decode(value.toString()));
      print("进来-----根据 imageId 从网络获取图片列表");
      //print("Model内容如下:");
      //print(json.encode(oneDriveDataModel));
    });
    return oneDriveDataModel;
  }

  // 根据 id 从网路下载 md 文件, 返回其内容
  Future<String> getMDFileContentFromNetwork(BuildContext context, String token,
      String id, String imageFolderId, ProgressDialog prt) async {
    String content;
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    final previewContent = Provider.of<PreviewModel>(context, listen:false);

    return await OneDriveDataDao.getMDFileContent(
            context, token, id, imageFolderId)
        .then((value) {
      print("看看, 数据张啥样?");
      print(value);
      if (value == null) {
        return null;
      } else {
        // 这里需要处理本地图片的问题
        // 1. 正则匹配出里面的本地图片, 注意后面的图片缩放" =数字px"
        // 2. 发送请求访问_v_images下的文件, 怎么拿到_v_images 的 id?
        // 3. 循环对应并且下载下来, 用插件转换地址
        // 4. 用上面的地址替换原地址
        //字符串前加字母"r"，字符串不会解析转义""
        RegExp reg = new RegExp(r"!\[.*?\]\((.*?)\)");

        /// 1. 正则匹配所有图片
        //调用allMatches函数，对字符串应用正则表达式
        //返回包含所有匹配的迭代器
        Iterable<Match> matches = reg.allMatches(value.toString());
        // 存放所有图片的名字
        List<String> imageUrls = [];
        print("解析文章中的图片链接如下: ");
        String matchString="";
        for (Match m in matches) {
          //groupCount返回正则表达式的分组数
          //由于group(0)保存了匹配信息，因此字符串的总长度为：分组数+1
          matchString = m.group(1);
          print(matchString);
          if(matchString.contains("http://") || matchString.contains("https://")){
            imageUrls.add(matchString.split("/")[1]);
          }else{
            continue;
          }
        }
        content = value.toString();

        /// 2. 发送请求访问_v_images下的文件
        // 有图片才需要去找
        return imageUrls;
      }
    }).then((imageUrls) async {
      if (imageUrls == null) {
        return null;
      } else {
        return await getImagesList(
            context, token, imageFolderId, imageUrls, (data) {});
      }
    }).then((imagesList) async {
      if (imagesList == null) {
        return null;
      } else {
        return await downloadImages(
            context, token, appDocPath, imagesList, content, prt);
      }
    }).then((data) {
      if (data == null) {
        return null;
      } else {
        print("##########################################");
        print("此时笔记内容是: ");
        print(data);
        // 存入本地
        print("存入本地");
        Application.sp.setString(id, data);
        print("##########################################");

        // 更新预览数据
        // 前面都更新完了, 这里应该不用更新了
        // previewContent.updateContent(data);

        return data;
      }
    });
  }

  Future<String> downloadImages(BuildContext context, String token, String path,
      List<Document> imagesList, String content, ProgressDialog prt) async {
    // 先将旧窗口隐藏掉
    prt.hide();
    // 批量下载图片
    int repeatCount = 3; // 重复下次三次

    final previewContent = Provider.of<PreviewModel>(context, listen: false);

    // 这里才是真的获取所需下载图片数量的地方
    // 可以在这里弹下载对话框
    ProgressDialog pr;
    pr = new ProgressDialog(context,type: ProgressDialogType.Download, isDismissible: true);
    pr.style(
        message: '开始下载...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
    );

    await pr.show();

    for (int i = 0; i < imagesList.length; i++) {
      await OneDriveDataDao.downloadImage(
              context, token, imagesList[i].id, path + "/" + imagesList[i].name)
          .then((value) {

        if (value == null) {
          print("没有数据, 得知连接超时");
          if (repeatCount > 0) {
            print("重试还剩: " + repeatCount.toString() + " 次");
            i--; // 减少 1, 让它重新操作
            repeatCount--;
          } else {
            print("已经重试 3 次, down 不下来, 用指定图片替换!");
            repeatCount = 3; // 重置
            // https://gitee.com/tamlok/vnote/raw/master/screenshots/vnote.png
            content = content.replaceAll("_v_images/" + imagesList[i].name,
                "https://gitee.com/tamlok/vnote/raw/master/screenshots/vnote.png");
            print("处理完: " + imagesList[i].name);
            // 每处理一张, 更新一下
            //previewContent.updateContent(content);
          }
        } else {
          content = content.replaceAll("_v_images/" + imagesList[i].name,
              path + "/" + imagesList[i].name);
          print("处理完: " + imagesList[i].name);
          repeatCount = 3; // 重置

          // 每处理一张, 更新一下
          //previewContent.updateContent(content);

          pr.update(
            progress: double.parse((100.0/imagesList.length * (i+1)).toStringAsFixed(1)),
            message: "下载 ing...",
            progressWidget: Container(
                padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
            maxProgress: 100.0,
            progressTextStyle: TextStyle(
                color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
            messageTextStyle: TextStyle(
                color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
          );
        }
      });
    }
    pr.hide();
    return content;
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
  Item({this.id = '', this.path = '', this.name = '', this.fullPath = ''});
  String id;
  String path;
  String name;
  String fullPath;
}

Future requestPermission() async {
  // 申请权限
  Map<PermissionGroup, PermissionStatus> permissions =
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  // 申请结果
  PermissionStatus permission =
      await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  if (permission == PermissionStatus.granted) {
    Fluttertoast.showToast(msg: "权限申请通过");
  } else {
    Fluttertoast.showToast(msg: "权限申请被拒绝");
  }
}
