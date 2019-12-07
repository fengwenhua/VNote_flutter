// 用于初始化跳转到各个页面的handle, 并获取到上个页面传递过来的值, 然后在初始化要跳转到的页面
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:vnote/pages/create_page.dart';
import 'package:vnote/pages/directory_page.dart';
import 'package:vnote/pages/label_page.dart';
import 'package:vnote/pages/note_page.dart';
import 'package:vnote/pages/search_page.dart';

// create 页面
var createHandler = new Handler(
  handlerFunc: (BuildContext context, Map<String, List<Object>> params){
    return CreatePage();
  }
);

// directory 页面
var directoryHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params){
      return DirectoryPage();
    }
);

// label 页面
var labelHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params){
      return LabelPage();
    }
);

// note 页面
var noteHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params){
      return NotePage();
    }
);

// search 页面
var searchHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params){
      return SearchPage();
    }
);

