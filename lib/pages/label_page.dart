import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vnote/utils/global.dart';

class LabelPage extends StatefulWidget{
  @override
  _LabelPageState createState() => _LabelPageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _LabelPageState extends State<LabelPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我是标签', style: TextStyle(fontSize: fontSize40)),
      ),
      body: Center(
        child: Text("标签"),
      ),
    );
  }
}