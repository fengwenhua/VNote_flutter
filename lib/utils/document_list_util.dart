import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:vnote/application.dart';
import 'package:vnote/dao/onedrive_data_dao.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/models/onedrive_data_model.dart';
import 'package:vnote/provider/config_id_provider.dart';
import 'package:vnote/provider/dir_and_file_cache_provider.dart';
import 'package:vnote/provider/image_folder_id_provider.dart';
import 'package:vnote/provider/parent_id_provider.dart';
import 'package:vnote/provider/token_provider.dart';
import 'package:vnote/utils/log_util.dart';
import 'package:vnote/utils/utils.dart';

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

  Future<List<Document>> getSearchList(BuildContext context, String key) async {
    print("调用 getSearchList!");
    TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);
    List<Document> result = new List<Document>();
    Response response = await OneDriveDataDao.searchText(
            context, tokenModel.token.accessToken, key)
        .then((data) {
      LogUtil.e("搜索拿到数据: " + data.toString());

      return data;
    });

    OneDriveDataModel bean = OneDriveDataModel.fromJson(response.data);
    print("搜索的关键字是: " + key);
    for (Value value in bean.value) {
      // 首先要是文件
      if (value.file != null) {
        print("检测名字: " + value.name);
        if (value.name.toLowerCase().contains(key.toLowerCase())) {
          print("名字包含了搜索关键字");
          if (value.name.endsWith(".json")) {
            print("跳过 json 配置文件");
            continue;
          }
          if (value.name.endsWith(".jpg") ||
              value.name.endsWith(".png") ||
              value.name.endsWith(".gif")) {
            print("跳过图片");
            continue;
          }
          if(value.name.endsWith(".vswp")){
            print("跳过中间文件");
            continue;
          }
          Document temp = new Document(
              id: value.id,
              name: value.name,
              isFile: value.file == null ? false : true,
              dateModified: DateTime.parse(value.lastModifiedDateTime));
          result.add(temp);
        }
      }
    }
    return result;
  }

  Future<List<Document>> getNotebookList(
      BuildContext context, String token, Function callBack,
      {bool fromNetwork = false}) async {
    List<Document> result = new List<Document>();
    OneDriveDataModel oneDriveDataModel;
    DirAndFileCacheProvider dirCacheModel =
        Provider.of<DirAndFileCacheProvider>(context, listen: false);
    oneDriveDataModel = await _getNoteBookFromNetwork(context, token);
    if (oneDriveDataModel != null) {
      print("拿到 oneDriveDataModel");
      if (oneDriveDataModel.value.length == 0) {
        print("onedrive 没有数据, 直接返回!");
        if (callBack != null) {
          callBack(result);
        }
        return result;
      }
    } else {
      print("gg, 特么的没有数据呀!!!");
      print("再来一发");

      Fluttertoast.showToast(
          msg: "特么的没有数据, 请重启 app",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

//        Future.delayed(Duration(seconds: 3), () async {
//          Navigator.of(context).pop();
//          print('延时3s执行, 退出 app');
//          await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//        });
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
      ConfigIdProvider configIdModel =
          Provider.of<ConfigIdProvider>(context, listen: false);
      ImageFolderIdProvider _imageFolderId =
          Provider.of<ImageFolderIdProvider>(context, listen: false);
      Document temp = new Document(
          id: value.id,
          configId: configIdModel.configId,
          imageFolderId: _imageFolderId.imageFolderId,
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
      List<String> imageUrls, Function callBack) async {
    print("根据 imageFolderId 与 imageUrls 对比获得所有图片");
    List<Document> result = new List<Document>();
    print("要找的图片大小: " + imageUrls.length.toString());

    final _imageFolderId =
        Provider.of<ImageFolderIdProvider>(context, listen: false);
    String imageFolderId = _imageFolderId.imageFolderId;
    ConfigIdProvider configIdModel =
        Provider.of<ConfigIdProvider>(context, listen: false);

    print("此时的 imageFolderId: ");
    print(imageFolderId);
    if (imageFolderId == null ||
        imageFolderId == "null" ||
        imageFolderId == "noimagefolder" ||
        imageUrls.length == 0) {
      print("md, 你特么的本地没有 imageFolder 文件夹, 你下个鸡儿的图片!");
      return result;
    }
    return await _getImagesFromNetwork(context, token, imageFolderId)
        .then((oneDriveDataModel) {
      if (oneDriveDataModel == null) {
        print("我擦, oneDriveDataModel没有东西!!! 那下个鸡儿的图片!!!");
      } else {
        for (String imageUrl in imageUrls) {
          //print("找图片: " + imageUrl);
          for (Value value in oneDriveDataModel.value) {
            //print("对比: " + value.name);
            if (value.name == imageUrl) {
              //print("临时: 增加: " + value.name);
              Document temp = new Document(
                  id: value.id,
                  configId: configIdModel.configId,
                  imageFolderId: imageFolderId,
                  name: value.name,
                  isFile: true,
                  dateModified: DateTime.parse(value.lastModifiedDateTime));
              result.add(temp);
              // 这里可以算出来获取图片的总数
              break;
            }
          }
        }
      }

      if (result.length == 0) {
        print("该文章没有图片, 或者因为网络原因, 没有搞到图片!");
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

    oneDriveDataModel = await _getChildFromNetwork(context, token, id);
    if (oneDriveDataModel != null) {
    } else {
      print("gg, 特么的没有数据呀1!!!");
      return null;
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
            parentId: id,
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
            parentId: id,
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

  List<Document> getAllList() {
    List<Document> result;

    return result;
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
        ParentIdProvider parentIdModel =
            Provider.of<ParentIdProvider>(context, listen: false);

        String genId;
        if (oneDriveDataModel.value.length == 0) {
          print("麻蛋, 没有笔记本!!");
          genId = "approot";
        } else {
          print("有笔记本!");
          genId = oneDriveDataModel.value[0]?.parentReference?.id;
        }
        print("在这里拿到 vnote 文件夹的 id, 并且设置好 parentId");
        parentIdModel.goAheadParentId(genId, "VNote 根目录");
        parentIdModel.setGenId(genId);
//        print("同时设置_vnote.json 的 id, 当然, 因为这里是第一层, 没有这文件, 所以设置默认是 approot");
//        ConfigIdProvider configIdModel =
//            Provider.of<ConfigIdProvider>(context, listen: false);
//        configIdModel.updateConfigId("approot");
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
      if (value == null) {
        print("网络不行");
      } else {
        oneDriveDataModel =
            OneDriveDataModel.fromJson(json.decode(value.toString()));
        print("进来-----根据 imageId 从网络获取图片列表");
        //print("Model内容如下:");
        //print(json.encode(oneDriveDataModel));
      }
    });
    return oneDriveDataModel;
  }

  // 根据 id 从网路下载 md 文件, 返回其内容
  Future<String> getMDFileContentFromNetwork(
      BuildContext context, String token, String id, ProgressDialog prt) async {
    String content;
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    String appImagePath = appDocPath + '/image';

    return await OneDriveDataDao.getFileContent(context, token, id)
        .then((value) {
      print("看看, 数据张啥样?");
      //print(value);
      if (value == null) {
        return null;
      } else {
        // 这里需要处理本地图片的问题
        // 1. 正则匹配出里面的本地图片, 注意后面的图片缩放" =数字px"
        // 2. 发送请求访问_v_images下的文件, 怎么拿到_v_images 的 id?
        // 3. 循环对应并且下载下来, 用插件转换地址
        // 4. 用上面的地址替换原地址
        //字符串前加字母"r"，字符串不会解析转义""

        List<String> imageUrls = Utils.getMDImages(value.toString());

        content = value.toString();

        /// 2. 发送请求访问_v_images下的文件
        // 有图片才需要去找
        return imageUrls;
      }
    }).then((imageUrls) async {
      if (imageUrls == null) {
        return null;
      } else {
        return await getImagesList(context, token, imageUrls, (data) {});
      }
    }).then((imagesList) async {
      if (imagesList == null) {
        return null;
      } else {
        return await downloadImages(
            context, token, appImagePath, imagesList, content, prt);
      }
    }).then((data) async {
      if (data == null) {
        return null;
      } else {
        print("##########################################");
        print("此时笔记内容是: ");
        //print(data);
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
    print("准备下载图片");
    // 先将旧窗口隐藏掉
    if (prt.isShowing()) {
      await prt.hide().then((isHidden) async {
        print("old dialog was killed ??");
        print(isHidden);
        if (!isHidden) {
          Navigator.of(context).pop();
        }
      });
    }

    // 批量下载图片
    int repeatCount = 10; // 重复下次10次

    // 这里才是真的获取所需下载图片数量的地方
    // 可以在这里弹下载对话框
    prt = new ProgressDialog(context,
        type: ProgressDialogType.Download, isDismissible: false);
    prt.style(
        message: '开始下载...',
        progress: 0.0,
        maxProgress: double.parse(imagesList.length.toString()));

    await prt.show();
    print("处理的图片: " + imagesList.length.toString());
    for (int i = 0; i < imagesList.length; i++) {
      await OneDriveDataDao.downloadImage(
              context, token, imagesList[i].id, path + "/" + imagesList[i].name)
          .then((value) async {
        if (value == null) {
          print("没有数据, 得知连接超时");
          if (repeatCount > 0) {
            print("重试还剩: " + repeatCount.toString() + " 次");
            i--; // 减少 1, 让它重新操作
            repeatCount--;
          } else {
            print("已经重试 10 次, down 不下来, 用指定图片替换!");
            repeatCount = 10; // 重置
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

          repeatCount = 10; // 重置

          // 每处理一张, 更新一下
          //previewContent.updateContent(content);
          await prt.hide().then((isHidden) async {
            print("download dialog killed ?");
            print(isHidden);
            if (!isHidden) {
              Navigator.of(context).pop();
            }
          });
          prt = new ProgressDialog(context,
              type: ProgressDialogType.Download, isDismissible: false);
          prt.style(
            message: "下载中...",
            progress: double.parse((i + 1).toString()),
            maxProgress: double.parse(imagesList.length.toString()),
          );
          await prt.show();
//          prt.update(
//            progress: double.parse(
//                (100.0 / imagesList.length * (i + 1)).toStringAsFixed(1)),
//            message: "下载 ing...",
//            progressWidget: Container(
//                padding: EdgeInsets.all(8.0),
//                child: CircularProgressIndicator()),
//            maxProgress: 100.0,
//          );
        }
      });
    }
    print("关闭下载对话框");
    Utils.showMyToast("下载完成!!");
    await prt.hide().then((isHidden) async {
      print("下载对话框关闭了吗? ");
      print(isHidden);
      if (!isHidden) {
        Navigator.of(context).pop();
      }
    });
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

  Future requestPermission() async {
    // 申请权限
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
      Permission.camera,
      Permission.storage,
    ].request();

    // 申请结果
    if (statuses[Permission.storage] == PermissionStatus.granted) {
      //Fluttertoast.showToast(msg: "存储权限申请通过");
      print("存储权限申请通过");
    } else {
      //Fluttertoast.showToast(msg: "存储权限申请被拒绝");
      print("存储权限申请被拒绝");
    }

    if (statuses[Permission.camera] == PermissionStatus.granted) {
      //Fluttertoast.showToast(msg: "相机权限申请通过");
      print("相机权限申请通过");
    } else {
      //Fluttertoast.showToast(msg: "相机权限申请被拒绝");
      print("相机权限申请被拒绝");
    }

    if (statuses[Permission.photos] == PermissionStatus.granted) {
      //Fluttertoast.showToast(msg: "相册权限申请通过");
      print("相册权限申请通过");
    } else {
      //Fluttertoast.showToast(msg: "相册权限申请被拒绝");
      print("相册权限申请被拒绝");
    }
  }
}

class Item {
  Item({this.id = '', this.path = '', this.name = '', this.fullPath = ''});
  String id;
  String path;
  String name;
  String fullPath;
}
