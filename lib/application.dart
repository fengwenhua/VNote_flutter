// 用于跳转时获取router
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vnote/route/navigate_service.dart';

class Application{
  static FluroRouter router;
  static GlobalKey<NavigatorState> key = GlobalKey();
  static SharedPreferences sp;

  static double screenWidth;
  static double screenHeight;
  static double statusBarHeight;
  static double bottomBarHeight;

  static initSp() async{
    sp = await SharedPreferences.getInstance();
  }
}