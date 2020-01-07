import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:vnote/application.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/utils/net_utils.dart';
import 'package:vnote/models/onedrive_data_model.dart';

const ONEDRIVE_ALL_DATA_URL =
    "https://graph.microsoft.com/v1.0/drive/special/approot/delta?select=id,name,lastModifiedDateTime,parentReference,file,folder";
const ONEDRIVE_SPECIAL_FOLDER_URL = "https://graph.microsoft.com/v1.0/me/drive/special/approot/children?select=id,name,lastModifiedDateTime,parentReference,file,folder";
const TEST_URL = "https://httpbin.org/get";

class OneDriveDataDao {
  static Future<Response> getAllData(BuildContext context, String p_token) {
    Map<String, dynamic> headers = {"Authorization": p_token};
    return NetUtils.instance.get(
        context,
        ONEDRIVE_ALL_DATA_URL,
        (data) {
          print('返回的json数据如下:');
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

  // 获取第一层的文件夹作为笔记本
  static Future<Response> getNoteBookData(BuildContext context, String p_token){
    Map<String, dynamic> headers = {"Authorization": p_token};
    return NetUtils.instance.get(
        context,
        ONEDRIVE_SPECIAL_FOLDER_URL,
            (data) {
          print('返回的json数据如下:');
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
  static Future<Response> getChildData(BuildContext context, String p_token, String id){
    Map<String, dynamic> headers = {"Authorization": p_token};
    String URL = "https://graph.microsoft.com/v1.0/me/drive/items/";
    URL += id;
    URL += "/children?select=id,name,lastModifiedDateTime,parentReference,file,folder";

    return NetUtils.instance.get(
        context,
        URL,
            (data) {
          print('返回的json数据如下:');
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

}
