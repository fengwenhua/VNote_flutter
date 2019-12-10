import 'package:flutter/material.dart';

class TokenModel with ChangeNotifier{
  String _accessToken="";
  String _refreshToken="";
  String get accessToken => _accessToken;
  String get refreshToken => _refreshToken;

  // 更新两个token的值
  void updateValue(String p_accessToken, String p_refreshToken){
    _accessToken = p_accessToken;
    _refreshToken = p_refreshToken;
    notifyListeners();
  }
}