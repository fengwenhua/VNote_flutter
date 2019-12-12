import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vnote/application.dart';
import 'package:vnote/models/onedrive_token_model.dart';

class TokenModel with ChangeNotifier{
  OneDriveTokenModel _token;
  OneDriveTokenModel get token => _token;

  // 初始化token, 即读取本地存储的token
  void initToken(){
    if(Application.sp.containsKey("onedrive_token")){
      String s = Application.sp.getString("onedrive_token");
      _token = OneDriveTokenModel.fromJson(json.decode(s));
    }
  }

  // 保存token信息到 sp
  _saveTokenInfo(OneDriveTokenModel token){
    _token = token;
    Application.sp.setString("onedrive_token", json.encode(token.toJson()));
  }
}