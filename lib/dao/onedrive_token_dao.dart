import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnote/models/onedrive_token_model.dart';
import 'package:vnote/provider/token_model.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/utils/net_utils.dart';

const oneDrive_token_url =
    'https://login.microsoftonline.com/common/oauth2/v2.0/token';

class OneDriveTokenDao {
  /// [getToken] 通过 [code] 获取 token
  static Future<Response> getToken(BuildContext context, String code) {
    Map<String, String> params = {
      "client_id": CLIENT_ID,
      "redirect_uri": REDIRECT_URL,
      "code": code,
      "grant_type": "authorization_code"
    };

    return NetUtils.instance.post(
        context,
        oneDrive_token_url,
        (data) {
          OneDriveTokenModel model =
              OneDriveTokenModel.fromJson(json.decode(data));
          print('获取token, 解析出来的结果如下:');
          print("access_token: " + model.accessToken);
          TokenModel tokenModel =
              Provider.of<TokenModel>(context, listen: false);
          tokenModel.updateToken(model);
        },
        params: params,
        errorCallBack: (errorMsg) {
          print("error: " + errorMsg);
          return null;
        });
  }

  /// [refreshToken] 通过 [refreshToken] 刷新token
  static Future<Response> refreshToken(
      BuildContext context, String refreshToken) {
    Map<String, String> params = {
      "client_id": CLIENT_ID,
      "redirect_uri": REDIRECT_URL,
      "refresh_token": refreshToken,
      "grant_type": "refresh_token"
    };

    return NetUtils.instance.post(
        context,
        oneDrive_token_url,
        (data) {
          OneDriveTokenModel model =
              OneDriveTokenModel.fromJson(json.decode(data));

          print('刷新token, 解析出来的结果如下:');
          print("access_token: " + model.accessToken);

          TokenModel tokenModel =
              Provider.of<TokenModel>(context, listen: false);
          tokenModel.updateToken(model);
        },
        params: params,
        errorCallBack: (errorMsg) {
          print("error: " + errorMsg);
        });
  }
}
