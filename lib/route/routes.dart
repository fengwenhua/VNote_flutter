// 用于绑定路由地址和对应的handler
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:vnote/route/route_handlers.dart';

class Routes{
  static String root = "/";
  static String create = "/create";
  static String directory = "/directory";
  static String label = "/label";
  static String note = "/note";
  static String search = "/search";

  static void configureRoutes(Router router){
    router.notFoundHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params){
        print("Route was not found!!");
      });
    //router.define(root, handler: splashHandler);
    router.define(create, handler: createHandler);
    router.define(directory, handler: directoryHandler);
    router.define(label, handler: labelHandler);
    router.define(note, handler: noteHandler);
    router.define(search, handler: searchHandler);
  }

}