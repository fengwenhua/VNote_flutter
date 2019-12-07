import 'package:flutter/material.dart';
import 'package:vnote/widgets/tab_navigator.dart';

void main() => runApp(MyApp());

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
    );
  }
}