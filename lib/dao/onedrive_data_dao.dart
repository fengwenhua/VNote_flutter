import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/utils/net_utils.dart';
import 'package:vnote/models/onedrive_data_model.dart';

const ONEDRIVE_ALL_DATA_URL =
    "https://graph.microsoft.com/v1.0/drive/special/approot/delta?select=id,name,lastModifiedDateTime,parentReference,file,folder";

class OneDriveDataModel {
  static Future<Response> getAllData(BuildContext context, String p_token) {
    Map<String, dynamic> headers = {"Authorization": p_token};
    return NetUtils.instance.get(
        context,
        ONEDRIVE_ALL_DATA_URL,
        (data) {
          print('返回的数据如下:');
          print(data);
        },
        headers: headers,
        errorCallBack: (errorMsg) {
          print("error: " + errorMsg);
          return null;
        });
  }
}
