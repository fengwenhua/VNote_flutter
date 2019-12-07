import 'package:flutter/material.dart';

class DirectoryPage extends StatefulWidget{
  @override
  _DirectoryPageState createState() => _DirectoryPageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _DirectoryPageState extends State<DirectoryPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("目录"),
      ),
    );
  }
}