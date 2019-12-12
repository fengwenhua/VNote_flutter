import 'dart:async';
import 'dart:convert';
import 'package:vnote/models/onedrive_token_model.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/utils/net_utils.dart';

import '../application.dart';

const ONEDRIVE_TOKEN_URL =
    'https://login.microsoftonline.com/common/oauth2/v2.0/token';

const ONEDRIVE_REFRESH_TOKEN_URL = "";

class OnedriveTokenDao {
  static void getToken(String code) {
    Map<String, String> params = {
      "client_id": CLIENT_ID,
      "redirect_uri": REDIRECT_URL,
      "code": code,
      "grant_type": "authorization_code"
    };

    NetUtils.instance.post(
        ONEDRIVE_TOKEN_URL,
        (data) {
          OneDriveTokenModel model =
              OneDriveTokenModel.fromJson(json.decode(data));
          print('获取token, 解析出来的结果如下:');
          print("access_token: " + model.accessToken);
          Application.sp.setString("onedrive_token", json.encode(model.toJson()));
        },
        params: params,
        errorCallBack: (errorMsg) {
          print("error: " + errorMsg);
          return null;
        });
  }

  static void refreshToken(String refreshToken){
    Map<String, String> params = {
      "client_id": CLIENT_ID,
      "redirect_uri": REDIRECT_URL,
      "refresh_token": refreshToken,
      "grant_type": "refresh_token"
    };

    NetUtils.instance.post(
        ONEDRIVE_REFRESH_TOKEN_URL,
            (data) {
          OneDriveTokenModel model =
          OneDriveTokenModel.fromJson(json.decode(data));
          print('刷新token, 解析出来的结果如下:');
          print("access_token: " + model.accessToken);
          Application.sp.setString("onedrive_token", json.encode(model.toJson()));
        },
        params: params,
        errorCallBack: (errorMsg) {
          print("error: " + errorMsg);
          return null;
        });
  }
}
