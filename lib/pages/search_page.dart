import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/widgets/search_bar.dart';

class SearchPage extends StatefulWidget{
  @override
  _SearchPageState createState() => _SearchPageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _SearchPageState extends State<SearchPage>{
  TextEditingController inputController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
          title: Text('个人笔记', style: TextStyle(fontSize: fontSize40)),
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
        child: Text("搜索"),
      ),
    );
  }
}