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
      if(s!=null){
        _token = OneDriveTokenModel.fromJson(json.decode(s));
      }else{
        _token = null;
      }
    }
  }

  // 更新token
  void updateToken(OneDriveTokenModel token){
    _token = token;
    Application.sp.setString("onedrive_token", json.encode(token.toJson()));
    notifyListeners();
  }
}