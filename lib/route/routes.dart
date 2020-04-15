// 用于绑定路由地址和对应的handler
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:vnote/pages/login_page.dart';
import 'package:vnote/route/route_handlers.dart';

class Routes{
  static String root = "/";
  static String home = "/home";
  static String login = "/login";
  static String preview = "/preview";
  static String edit = "/edit";
  static String newFile = "/newFile";
  static String about = "/about";
  static String tutorial = "/tutorial";
  static String language = "/language";

  static void configureRoutes(Router router){
    router.notFoundHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params){
        print("Route was not found!!");
        return LoginPage();
      });

    router.define(root, handler: splashHandler);
    router.define(login, handler: loginHandler);
    router.define(home, handler: homeHandler);
    router.define(preview, handler: mdPreviewHandler);
    router.define(edit, handler: mdEditHandler);
    router.define(newFile, handler: newFileHandler);
    router.define(about, handler: aboutHandler);
    router.define(tutorial, handler: tutorialHandler);
    router.define(language, handler: languageHandler);
  }

}