import 'dart:async';
import 'dart:convert';
import 'package:vnote/models/onedrive_token_model.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/utils/net_utils.dart';

const ONEDRIVE_TOKEN_URL =
    'https://login.microsoftonline.com/common/oauth2/v2.0/token';

class OnedriveTokenDao{
  static void getToken(String code){
    Map<String, String> params = {
      "client_id": CLIENT_ID,
      "redirect_uri": REDIRECT_URL,
      "code": code,
      "grant_type": "authorization_code"
    };

    HttpCore.instance.post(
        ONEDRIVE_TOKEN_URL,
            (data) {
          OnedriveTokenModel model = OnedriveTokenModel.fromJson(json.decode(data));
          print('解析出来的结果如下:');
          print("access_token: " + model.accessToken);
          print("refresh_token: " + model.refreshToken);
        },
        params: params,
        errorCallBack: (errorMsg) {
          print("error: " + errorMsg);
          return null;
        });
  }
}