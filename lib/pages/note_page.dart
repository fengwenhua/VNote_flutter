import 'package:flutter/material.dart';

class NotePage extends StatefulWidget{
  @override
  _NotePageState createState() => _NotePageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _NotePageState extends State<NotePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("笔记"),
      ),
    );
  }
}