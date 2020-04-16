import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:vnote/application.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/widgets/click_item.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(translate("settings.name"),
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
              Navigator.of(context).pop();
            },
          )),
      body: Column(
        children: <Widget>[
          SizedBox(height: 5),
          ClickItem(
              title: '语言设置',
              onTap: () {
                print("点击语言设置");
                Application.router.navigateTo(context, "/language",
                    transition: TransitionType.fadeIn);
              }),
          ClickItem(title: '清除缓存', content: '23.5MB', onTap: () {}),
          ClickItem(title: '夜间模式', onTap: () => {}),
          ClickItem(title: '检查更新', onTap: () => {}),
          ClickItem(
              title: '简易教程',
              onTap: () {
                Application.router.navigateTo(context, "/tutorial",
                    transition: TransitionType.fadeIn);
              }),
          ClickItem(
              title: '关于我们',
              onTap: () {
                Application.router.navigateTo(context, "/about",
                    transition: TransitionType.fadeIn);
              }),
        ],
      ),
    );
  }
}
