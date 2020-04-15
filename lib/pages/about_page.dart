import 'package:flutter/material.dart';
import 'package:vnote/utils/global.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('关于',
                style: TextStyle(fontSize: fontSize40, color: Colors.black)),
            elevation: 0.5,
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 60.0,
                height: 60.0,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: ExactAssetImage('images/vnote.png'),
                ),
              ),
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: Text('评价'),
                onPressed: () {
                  print("点击了评价");
                },
              ),
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: Text('检查更新'),
                onPressed: () {
                  print("点击了检查更新");
                },
              )
            ],
          ),
        ));
  }
}
