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
        body: Column(
          children: <Widget>[
            MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: new Text('点我'),
              onPressed: () {
                // 页面跳转
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WebView(
                              url:
                                  "https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=fd49989c-b57c-49a4-9832-8172ae6a4162&scope=files.readwrite%20offline_access&response_type=code&redirect_uri=https://login.microsoftonline.com/common/oauth2/nativeclient",
                              statusBarColor: "19A0F0",
                              hideAppBar: true,
                            )));
              },
            )
          ],
        ));
  }
}
