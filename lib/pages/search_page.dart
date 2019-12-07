import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vnote/utils/global.dart';

class SearchPage extends StatefulWidget{
  @override
  _SearchPageState createState() => _SearchPageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _SearchPageState extends State<SearchPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我是搜索', style: TextStyle(fontSize: fontSize40)),
      ),
      body: Center(
        child: Text("搜索"),
      ),
    );
  }
}