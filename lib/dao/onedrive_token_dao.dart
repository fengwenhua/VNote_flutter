import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnote/models/onedrive_token_model.dart';
import 'package:vnote/provider/token_model.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/utils/net_utils.dart';

import '../application.dart';

const ONEDRIVE_TOKEN_URL =
    'https://login.microsoftonline.com/common/oauth2/v2.0/token';

class OnedriveTokenDao {
  static Future<Response> getToken(BuildContext context, String code) {
    Map<String, String> params = {
      "client_id": CLIENT_ID,
      "redirect_uri": REDIRECT_URL,
      "code": code,
      "grant_type": "authorization_code"
    };

    return NetUtils.instance.post(
        context,
        ONEDRIVE_TOKEN_URL,
        (data) {
          OneDriveTokenModel model =
              OneDriveTokenModel.fromJson(json.decode(data));
          print('获取token, 解析出来的结果如下:');
          print("access_token: " + model.accessToken);
          TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);
          tokenModel.updateToken(model);
        },
        params: params,
        errorCallBack: (errorMsg) {
          print("error: " + errorMsg);
          return null;
        });
  }

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
        ONEDRIVE_TOKEN_URL,
        (data) {
          OneDriveTokenModel model =
              OneDriveTokenModel.fromJson(json.decode(data));

          print('刷新token, 解析出来的结果如下:');
          print("access_token: " + model.accessToken);

          TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);
          tokenModel.updateToken(model);
        },
        params: params,
        errorCallBack: (errorMsg) {
          print("error: " + errorMsg);
        });
  }
}
