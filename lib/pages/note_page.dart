import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vnote/utils/global.dart';
import 'package:flutter_translate/flutter_translate.dart';

class NotePage extends StatefulWidget{
  @override
  _NotePageState createState() => _NotePageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _NotePageState extends State<NotePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate("note.appbar"), style: TextStyle(fontSize: fontSize40)),
        leading: IconButton(
            icon: Icon(Icons.dehaze, color: Colors.white,),
            onPressed: (){
              // 打开Drawer抽屉菜单
              print("点击了侧滑按钮");
              Scaffold.of(context).openDrawer();
            },
          )
      ),
      body: Center(
        child: Text(translate("note.tips")),
      ),
    );
  }
}