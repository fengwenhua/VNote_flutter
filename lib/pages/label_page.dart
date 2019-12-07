import 'package:flutter/material.dart';

class LabelPage extends StatefulWidget{
  @override
  _LabelPageState createState() => _LabelPageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _LabelPageState extends State<LabelPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("标签"),
      ),
    );
  }
}