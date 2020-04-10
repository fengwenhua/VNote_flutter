import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vnote/application.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/utils/net_utils.dart';
import 'package:vnote/models/onedrive_data_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

const ONEDRIVE_ALL_DATA_URL =
    "https://graph.microsoft.com/v1.0/drive/special/approot/delta?select=id,name,lastModifiedDateTime,parentReference,file,folder";
const ONEDRIVE_SPECIAL_FOLDER_URL =
    "https://graph.microsoft.com/v1.0/me/drive/special/approot/children?select=id,name,lastModifiedDateTime,parentReference,file,folder";
const TEST_URL = "https://httpbin.org/get";

class OneDriveDataDao {
  /// 该递归的方法已经废除
  static Future<Response> getAllData(BuildContext context, String p_token) {
    Map<String, dynamic> headers = {"Authorization": p_token};
    return NetUtils.instance.get(
        context,
        ONEDRIVE_ALL_DATA_URL,
        (data) {
          print('返回的json数据如下1:');
          print(data);
          // 将原始数据写进本地
          Application.sp.setString("raw_data", data);
          return OneDriveDataModel.fromJson(json.decode(data));
        },
        headers: headers,
        errorCallBack: (errorMsg) {
          print("error: " + errorMsg);
          return null;
        });
  }

  /// 获取第一层的文件夹作为笔记本
  /// 列出应用文件夹子项：GET /drive/special/approot/children
  static Future<Response> getNoteBookData(
      BuildContext context, String p_token) {
    Map<String, dynamic> headers = {"Authorization": p_token};
    return NetUtils.instance.get(
        context,
        ONEDRIVE_SPECIAL_FOLDER_URL,
        (data) {
          print('返回的json数据如下2:');
          print(data);
          // 将原始数据写进本地
          Application.sp.setString("special_folder_raw_data", data);
          return OneDriveDataModel.fromJson(json.decode(data));
        },
        headers: headers,
        errorCallBack: (errorMsg) {
          print("error: " + errorMsg);
          return null;
        });
  }

  // 根据 id 获取儿子那一层
  static Future<Response> getChildData(
      BuildContext context, String token, String id) {
    Map<String, dynamic> headers = {"Authorization": token};
    String URL =
        "https://graph.microsoft.com/v1.0/me/drive/items/$id/children?select=id,name,lastModifiedDateTime,parentReference,file,folder";

    return NetUtils.instance.get(
        context,
        URL,
        (data) {
          print('返回的json数据如下3:');
          print(data);
          // 将原始数据写进本地
          Application.sp.setString("id_children_raw_data", data);
          return OneDriveDataModel.fromJson(json.decode(data));
        },
        headers: headers,
        errorCallBack: (errorMsg) {
          print("error: " + errorMsg);
          return null;
        });
  }

  // 根据 id 获取 md 文件内容
  static Future<Response> getFileContent(
      BuildContext context, String token, String id) {
    Map<String, dynamic> headers = {"Authorization": token};
    String URL = "https://graph.microsoft.com/v1.0/me/drive/items/$id/content";

    return NetUtils.instance.get(
        context,
        URL,
        (data) {
          print('返回文件内容如下:');
          print(data);
          return data;
        },
        headers: headers,
        errorCallBack: (errorMsg) {
          print("error: " + errorMsg);
          return null;
        });
  }

  /// 根据 _v_images 的 Id 返回所有图片id
  static Future<Response> getImagesID(
      BuildContext context, String token, String id) {
    print("根据 _v_images 的 Id 返回所有图片id");
    Map<String, dynamic> headers = {"Authorization": token};
    String URL =
        "https://graph.microsoft.com/v1.0/me/drive/items/$id/children?select=id,name,lastModifiedDateTime,parentReference,file,folder";

    return NetUtils.instance.get(
        context,
        URL,
        (data) {
          print('返回的json数据如下4:');
          print(data);
          // 将原始数据写进本地
          Application.sp.setString("image_id_children_raw_data", data);

          return data;
        },
        headers: headers,
        errorCallBack: (errorMsg) {
          print("error: " + errorMsg);
          return null;
        });
  }

  /// 根据图片 id 下载图片内容
  static Future<Response> downloadImage(
      BuildContext context, String token, String id, String path) {
    Map<String, dynamic> headers = {"Authorization": token};
    String URL = "https://graph.microsoft.com/v1.0/me/drive/items/$id/content";
    return NetUtils.instance.download(
        context,
        URL,
        (data) {
          print("拿到图片的二进制数据");
          return data;
        },
        headers: headers,
        errorCallBack: (errorMsg) {
          print("error: " + errorMsg);
          print("是超时吗? " + errorMsg);
          if (errorMsg.contains("timed out") || errorMsg.contains("timeout")) {
            print("确实是超时");
          } else {
            print("竟然没有超时");
          }

          String msg = "";
          if (errorMsg.contains("timed out")) {
            msg = "下载图片时, 网络连接超时, 重试 ing";
          } else {
            msg = errorMsg;
          }
          // 这个地方, 竟然是显示了内容才弹....
          Fluttertoast.showToast(
              msg: msg,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 2,
              backgroundColor: Color(0x9E9E9E),
              textColor: Color(0xffffff));
          return msg;
        },
        path: path);
  }

  /// [rename] 是根据 [id] 和 [name] 重命名
  static Future<Response> rename(
      BuildContext context, String token, String id, String name) {
    Map<String, dynamic> headers = {"Authorization": token};
    String url = "https://graph.microsoft.com/v1.0/me/drive/items/$id";
    String content = '''{
  "name": "$name"
}''';
    return NetUtils.instance.patch(context, url, (data) {},
        content: content, headers: headers, errorCallBack: (errorMsg) {
      print("出了错误, 是超时吗? " + errorMsg);
    });
  }

  /// 根据文章 id 和 content 更新文章内容
  static Future<Response> updateContent(
      BuildContext context, String token, String id, String content) {
    Map<String, dynamic> headers = {"Authorization": token};
    String URL = "https://graph.microsoft.com/v1.0/me/drive/items/$id/content";
    return NetUtils.instance.put(
        context,
        URL,
        (data) {
          //print("请求返回来的内容如下:");
          //print(data);
          //print("###################################################\n\n");
        },
        content: content,
        headers: headers,
        errorCallBack: (errorMsg) {
          print("出了错误, 是超时吗? " + errorMsg);
        });
  }

  /// [uploadFile] 根据 [parentId] 和 [content] 和 [filename] 上传文件
  /// 可以是 md, 也可以是图片
  /// PUT /me/drive/items/{parent-id}:/{filename}:/content
  static Future<Response> uploadFile(BuildContext context, String token,
      String parentId, dynamic content, String filename) {
    Map<String, dynamic> headers = {"Authorization": token};
    String URL =
        "https://graph.microsoft.com/v1.0/me/drive/items/$parentId:/$filename:/content";
    return NetUtils.instance.put(
        context,
        URL,
        (data) {
          //print("请求返回来的内容如下:");
          //print(data);
          //print("###################################################\n\n");
        },
        content: content,
        headers: headers,
        errorCallBack: (errorMsg) {
          print("出了错误, 是超时吗? " + errorMsg);
        });
  }

  /// [deleteFile] 是根据 [id] 删除文件
  /// DELETE /me/drive/items/{item-id}
  /// 如果成功，此调用将返回 204 No Content 响应
  static Future<Response> deleteFile(
      BuildContext context, String token, String id) {
    Map<String, dynamic> headers = {"Authorization": token};
    String URL = "https://graph.microsoft.com/v1.0/me/drive/items/$id";
    return NetUtils.instance.delete(
        context,
        URL,
        (data, status) {
          print("这里拿到的 status 是 " + status.toString());
          return status.toString();
        },
        headers: headers,
        errorCallBack: (errorMsg) {
          print("出了错误, 是超时吗? " + errorMsg);
        });
  }

  /// [searchText] 是用于搜索
  /// GET /me/drive/special/approot/search(q='{search-query}')?select=id,name,lastModifiedDateTime,parentReference,file,folder
  /// 注意返回来的, 有可能是其 parent 有响应的内容, 也跟着一起返回来, 所以我们要筛选 name 字段, 不管 parent
  static Future<Response> searchText(BuildContext context, String token, String searchText){

  }

  /// [recentFile] 用于获取最近的文件
  /// GET /me/drive/recent
  static Future<Response> recentFile(BuildContext context, String token){

  }

  /// [createFolder] 用于在[parentId]之下创建新文件夹[folderName]
  /// POST /me/drive/items/{parent-item-id}/children
  /// 上传之后如果重名则服务器会自动重命名
  static Future<Response> createFolder(
      BuildContext context, String token, String folderName, String parentId) {
    Map<String, dynamic> headers = {"Authorization": token};
    String URL =
        "https://graph.microsoft.com/v1.0/me/drive/items/$parentId/children";

    String data = '''{
  "name": "$folderName",
  "folder": { },
  "@microsoft.graph.conflictBehavior": "rename"
}''';

    return NetUtils.instance.post(
        context,
        URL,
        (data) {
          print("创建文件夹返回来的数据: " + data.toString());
          return data;
        },
        data: data,
        headers: headers,
        contentType: "application/json",
        errorCallBack: (errorMsg) {
          print("出了错误, 是超时吗? " + errorMsg);
        });
  }


}
