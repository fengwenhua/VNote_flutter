import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/widgets/webview.dart';

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _CreatePageState extends State<CreatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('我是新建', style: TextStyle(fontSize: fontSize40)),
        ),
      body: Center(
        child: Text("新建"),
      ),
        );
  }
}
