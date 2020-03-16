import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/widgets/webview.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('OneDrive登录', style: TextStyle(fontSize: fontSize40)),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () async {
              // 退出应用
              await pop();
            },
          )),
      body: WebView(
        url:
            "https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=fd49989c-b57c-49a4-9832-8172ae6a4162&scope=files.readwrite%20offline_access&response_type=code&redirect_uri=https://login.microsoftonline.com/common/oauth2/nativeclient",
        statusBarColor: "19A0F0",
        hideAppBar: true,
      ),
    );
  }
}

Future<void> pop() async {
  await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
}
