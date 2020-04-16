import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
              title: translate("settings.language"),
              onTap: () {
                print("点击语言设置");
                Application.router.navigateTo(context, "/language",
                    transition: TransitionType.fadeIn);
              }),
          ClickItem(
              title: translate("settings.clearCache"),
              content: '23.5MB',
              onTap: () {
                Fluttertoast.showToast(msg: "实现 ing");
              }),
          ClickItem(
              title: translate("settings.darkModel"),
              onTap: () {
                Fluttertoast.showToast(msg: "实现 ing");
              }),
          ClickItem(
              title: translate("settings.checkUpdate"),
              onTap: () {
                Fluttertoast.showToast(msg: "实现 ing");
              }),
          ClickItem(
              title: translate("settings.tutorial"),
              onTap: () {
                Application.router.navigateTo(context, "/tutorial",
                    transition: TransitionType.fadeIn);
              }),
          ClickItem(
              title: translate("settings.about"),
              onTap: () {
                Application.router.navigateTo(context, "/about",
                    transition: TransitionType.fadeIn);
              }),
        ],
      ),
    );
  }
}
