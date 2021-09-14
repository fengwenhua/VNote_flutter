import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:vnote/application.dart';
import 'package:vnote/provider/token_provider.dart';
import 'package:vnote/res/colors.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/utils/log_util.dart';
import 'package:vnote/utils/net_utils.dart';
import 'package:vnote/widgets/click_item.dart';
import 'package:vnote/widgets/update_dialog.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            translate("settings.name"),
          ),
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )),
      body: Column(
        children: <Widget>[
          SizedBox(height: 5),
          ClickItem(
              title: translate("settings.token"),
              onTap: () {
                print("点击复制 token");
                TokenModel tokenModel =
                    Provider.of<TokenModel>(context, listen: false);
                String refreshToken = tokenModel.token.refreshToken;
                Clipboard.setData(ClipboardData(text: 'token:' + refreshToken));
                Fluttertoast.showToast(
                    msg: "token 已经复制到剪切板, 请直接发送到公众号进行绑定",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    textColor: Colors.red);
              }),
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
                Application.router.navigateTo(context, "/theme",
                    transition: TransitionType.fadeIn);
              }),
          ClickItem(
              title: translate("settings.checkUpdate"),
              onTap: () async {
                ProgressDialog pr = new ProgressDialog(context);
                pr.style(message: "检查更新 ing");
                await pr.show();

                // 首先获取当前版本号
                PackageInfo packageInfo = await PackageInfo.fromPlatform();
                String version = packageInfo.version;
                print(version);

                await NetUtils.instance.get(context,
                    "https://api.github.com/repos/fengwenhua/VNote_flutter/releases/latest",
                    (data) async {
                  print('返回版本相关 json 如下:');
                  LogUtil.e(data);

                  Map<String, dynamic> json = jsonDecode(data.toString());
                  String remoteVersion =
                      json["tag_name"].toString().substring(1);
                  print("服务器的版本是: " + remoteVersion);
                  if (remoteVersion.compareTo(version) == 1) {
                    print("需要更新");
                    String updateContent = json["body"];
                    print("更新的内容是: " + updateContent);
                    List assets = json["assets"];
                    print("类型: ");
                    print(assets[0].runtimeType.toString());
                    String download_name = "";
                    String download_link = "";

                    for(Map<String, dynamic> asset in assets){
                      if(asset['name'].endsWith(".apk")){
                        print(asset);
                        download_name = asset['name'];
                        download_link = asset['browser_download_url'];
                        break;
                      }
                    }

                    print("下载链接: ");
                    print(download_link);
                    print("下载名字");
                    print(download_name);

                    await pr.hide();

                    _showUpdateDialog(
                        download_name,
                        download_link,
                        updateContent,
                        "v" + remoteVersion);
                  } else {
                    print("不需要更新");
                    await pr.hide();
                    Fluttertoast.showToast(msg: "当前版本已经是最新, 不需要更新!");
                    return;
                  }

                  return data;
                }, errorCallBack: (errorMsg) {
                  print("error: " + errorMsg);
                  return null;
                });
                await pr.hide();
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

  void _showUpdateDialog(
      String name, String downloadUrl, String content, String version) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => UpdateDialog(
            name: name,
            downloadUrl: downloadUrl,
            content: content,
            version: version));
  }
}
