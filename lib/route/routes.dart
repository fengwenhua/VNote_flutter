// 用于绑定路由地址和对应的handler
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:vnote/pages/login_page.dart';
import 'package:vnote/route/route_handlers.dart';

class Routes{
  static String root = "/";
  static String home = "/home";
  static String login = "/login";

  static void configureRoutes(Router router){
    router.notFoundHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params){
        print("Route was not found!!");
        return LoginPage();
      });

    router.define(root, handler: splashHandler);
    router.define(login, handler: loginHandler);
    router.define(home, handler: homeHandler);
  }

}