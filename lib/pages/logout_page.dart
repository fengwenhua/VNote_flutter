import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/widgets/webview.dart';

class LogoutPage extends StatefulWidget {
  @override
  _LogoutPageState createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('OneDrive注销并重新登录', style: TextStyle(fontSize: fontSize40)),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          )),
      body: WebView(
        url:
        "https://login.microsoftonline.com/common/oauth2/v2.0/logout?post_logout_redirect_uri=https://login.microsoftonline.com/common/oauth2/nativeclient",
        statusBarColor: "19A0F0",
        hideAppBar: true,
      ),
    );
  }
}

Future<void> pop() async {
  await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
}
