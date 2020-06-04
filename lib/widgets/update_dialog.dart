import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:r_upgrade/r_upgrade.dart';
import 'package:vnote/application.dart';

class UpdateDialog extends StatefulWidget {
  final String name;
  final String downloadUrl;
  final String content;
  final String version;

  UpdateDialog(
      {Key key,
      String name,
      String downloadUrl,
      String content,
      String version})
      : this.name = name,
        this.downloadUrl = downloadUrl,
        this.content = content,
        this.version = version,
        super(key: key);

  @override
  _UpdateDialogState createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  CancelToken _cancelToken = CancelToken();
  bool _isDownload = false;
  double _value = 0;

  @override
  void dispose() {
    if (!_cancelToken.isCancelled && _value != 1) {
      _cancelToken.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    return WillPopScope(
      onWillPop: () async {
        /// 使用false禁止返回键返回，达到强制升级目的
        return true;
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                width: 280.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                        height: 120.0,
                        width: 280.0,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: const Radius.circular(8.0),
                              topRight: const Radius.circular(8.0)),
                          image: DecorationImage(
                            image: AssetImage('assets/images/update_head.jpg'),
                            fit: BoxFit.cover,
                          ),
                        )),
                    Padding(
                      padding:
                          EdgeInsets.only(left: 15.0, right: 15.0, top: 16.0),
                      child: Text('新版本更新 ' + widget.version,
                          style: TextStyle(
                            fontSize: 14.0,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 10.0),
                      child: Text(widget.content),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 15.0, left: 15.0, right: 15.0, top: 5.0),
                      child: _isDownload
                          ? LinearProgressIndicator(
                              backgroundColor: Color(0xFFEEEEEE),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primaryColor),
                              value: _value,
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: 110.0,
                                  height: 36.0,
                                  child: FlatButton(
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      Navigator.pop(context);
                                    },
                                    textColor: primaryColor,
                                    color: Colors.transparent,
                                    disabledTextColor: Colors.white,
                                    disabledColor: Color(0xFFcccccc),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        side: BorderSide(
                                          color: primaryColor,
                                          width: 0.8,
                                        )),
                                    child: Text(
                                      '残忍拒绝',
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 110.0,
                                  height: 36.0,
                                  child: FlatButton(
                                    onPressed: () async {
                                      if (defaultTargetPlatform ==
                                          TargetPlatform.iOS) {
                                        FocusScope.of(context).unfocus();
                                        Navigator.pop(context);
                                        Fluttertoast.showToast(
                                            msg: "苹果平台, 请自行前往仓库下载...");
                                      } else {
//                                        setState(() {
//                                          _isDownload = true;
//                                        });
                                        //_download();

                                        FocusScope.of(context).unfocus();
                                        Navigator.pop(context);
                                        String route =
                                            '/update?name=${Uri.encodeComponent(widget.name)}&downloadUrl=${Uri.encodeComponent(widget.downloadUrl)}&content=${Uri.encodeComponent(widget.content)}&version=${Uri.encodeComponent(widget.version)}';
                                        Application.router.navigateTo(
                                            context, route,
                                            transition: TransitionType.fadeIn);
                                      }
                                    },
                                    textColor: Colors.white,
                                    color: primaryColor,
                                    disabledTextColor: Colors.white,
                                    disabledColor: Color(0xFFcccccc),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                    child: Text(
                                      '立即更新',
                                    ),
                                  ),
                                )
                              ],
                            ),
                    )
                  ],
                )),
          )),
    );
  }

  _download() async {
    try {
      Directory appDocDir;
      if (Platform.isIOS) {
        appDocDir = await getApplicationDocumentsDirectory();
      } else {
        appDocDir = await getApplicationSupportDirectory();
      }
      String appDocPath = appDocDir.path;
      File file = File(appDocPath);

      await Dio().download(
        "https://github.strcpy.cn/fengwenhua/test/releases/download/v1.2.0/vnote.apk",
        file.path + "/" + widget.name,
        cancelToken: _cancelToken,
        onReceiveProgress: (int count, int total) {
          if (total != -1) {
            setState(() {
              _value = count / total;
            });
            if (count == total) {
              FocusScope.of(context).unfocus();
              Navigator.pop(context);

              print("这时候要安装 APP 了");
//              MethodChannel _channel = const MethodChannel('top.fengwenhua.vnote');
//              _channel.invokeMethod('install', {'path': file.path +"/"+ widget.name});

            }
          }
        },
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "下载失败!");
      print(e);
      setState(() {
        _isDownload = false;
      });
    }
  }
}
