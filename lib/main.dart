import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnote/provider/token_model.dart';
import 'package:vnote/route/application.dart';
import 'package:vnote/route/routes.dart';
import 'package:vnote/utils/log_util.dart';
import 'package:vnote/utils/net_utils.dart';
import 'package:vnote/widgets/tab_navigator.dart';

void main() {
  // 初始化路由
  final router = new Router();
  Routes.configureRoutes(router);
  Application.router = router;
  LogUtil.init(tag: "VNote");
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<TokenModel>(
        create: (context)=>TokenModel(),
      )
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VNote',
      debugShowCheckedModeBanner: false, // 去除调试
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TabNavigator(),
      // 初始化路由
      onGenerateRoute: Application.router.generator,
    );
  }
}