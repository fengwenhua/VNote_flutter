// 用于初始化跳转到各个页面的handle, 并获取到上个页面传递过来的值, 然后在初始化要跳转到的页面
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:vnote/pages/about_page.dart';
import 'package:vnote/pages/create_page.dart';
import 'package:vnote/pages/language_page.dart';
import 'package:vnote/pages/login_page.dart';
import 'package:vnote/pages/logout_page.dart';
import 'package:vnote/pages/markdown_webview_page.dart';
import 'package:vnote/pages/node_edit.page.dart';
import 'package:vnote/pages/note_preview_page.dart';
import 'package:vnote/pages/notebooks_page.dart';
import 'package:vnote/pages/setting_page.dart';
import 'package:vnote/pages/splash_screen_page.dart';
import 'package:vnote/pages/theme_page.dart';
import 'package:vnote/pages/tutorial_page.dart';
import 'package:vnote/pages/update_page.dart';
import 'package:vnote/pages/webview_page.dart';
import 'package:vnote/widgets/tab_navigator.dart';

// splash 页面
var splashHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return SplashScreenPage();
});

// login 页面
var loginHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return LoginPage();
});

// logout 页面
var logoutHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return LogoutPage();
});

// home 页面
var homeHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return TabNavigator();
});

// 预览界面
var mdPreviewHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  String content = params["content"].first;
  String id = params["id"].first;
  String configId = params["configId"].first;
  String imageFolderId = params["imageFolderId"].first;
  String name = params["name"].first; //0代表编辑, 1 代表新建
  return new NotePreviewPage(
      markdownSource: content,
      id: id,
      configId: configId,
      imageFolderId: imageFolderId,
      name: name);
});

// 编辑页面
var mdEditHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  String content = params["content"].first;
  String id = params["id"].first;
  String name = params["name"].first;
  return new NoteEditPage(
    markdownSource: content,
    id: id,
    name: name,
  );
});

// 新建文件页面
var newFileHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return new CreatePage();
});

// 关于页面
var aboutHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return new AboutPage();
});

// 教程页面
var tutorialHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return new TutorialPage();
});

// 语言设置页面
var languageHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return new LanguagePage();
});

// 设置页面
var settingsHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return new SettingPage();
});

// 笔记本选择页面
var notebooksHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
      return new NotebooksPage();
    });

// webview
var webViewHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  String title = params['title']?.first;
  String url = params['url']?.first;
  return WebViewPage(title: title, url: url);
});

// 主题切换页面
var themeHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return new ThemePage();
});

// markdownWebView
var markdownWebViewHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  String content = params['htmlPath']?.first;
  String title = params['title']?.first;
  String id = params["id"].first;
  String configId = params["configId"].first;
  String imageFolderId = params["imageFolderId"].first;
  return MarkdownWebViewPage(
      title: title,
      htmlPath: content,
      id: id,
      configId: configId,
      imageFolderId: imageFolderId);
});

// 更新页面
var updateHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
      String name = params['name']?.first;
      String downloadUrl = params['downloadUrl']?.first;
      String content = params["content"].first;
      String version = params["version"].first;
  return new UpdatePage(name: name,downloadUrl: downloadUrl,content: content,version: version,);
});
