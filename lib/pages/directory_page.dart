import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vnote/utils/global.dart';

class DirectoryPage extends StatefulWidget{
  @override
  _DirectoryPageState createState() => _DirectoryPageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _DirectoryPageState extends State<DirectoryPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我是目录', style: TextStyle(fontSize: fontSize40)),
      ),
      body: Center(
        child: Text("目录"),
      ),
    );
  }
}