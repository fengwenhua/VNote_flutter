import 'package:flutter/material.dart';

class CreatePage extends StatefulWidget{
  @override
  _CreatePageState createState() => _CreatePageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _CreatePageState extends State<CreatePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("新建"),
      ),
    );
  }
}