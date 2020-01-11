// 用于初始化跳转到各个页面的handle, 并获取到上个页面传递过来的值, 然后在初始化要跳转到的页面
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:vnote/pages/login_page.dart';
import 'package:vnote/pages/note_preview_page.dart';
import 'package:vnote/pages/splash_screen_page.dart';
import 'package:vnote/widgets/tab_navigator.dart';

// splash 页面
var splashHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params){
      return SplashScreenPage();
    }
);

// login 页面
var loginHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params){
      return LoginPage();
    }
);

// home 页面
var homeHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params){
      return TabNavigator();
    }
);

// 预览界面
var mdPreviewHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params){
      String content = params["content"].first;
      String id =  params["id"].first;
      String name =  params["name"].first;
      return new NotePreviewPage(markdownSource: content, id:id,name: name,);
    }
);
