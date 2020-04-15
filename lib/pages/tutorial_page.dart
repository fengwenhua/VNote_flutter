import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/utils/global.dart';

class TutorialPage extends StatefulWidget{
  @override
  _TutorialPageState createState() => _TutorialPageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _TutorialPageState extends State<TutorialPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('教程', style: TextStyle(fontSize: fontSize40, color: Colors.black)),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black,),
            onPressed: (){
              Navigator.pop(context);
            },
          )
      ),
      body: Material(
        child: Markdown(data: tutorialText),
      )
    );
  }
}