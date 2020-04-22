import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:r_upgrade/r_upgrade.dart';

const version = 1;

class UpdatePage extends StatefulWidget {
  final String name;
  final String downloadUrl;
  final String content;
  final String version;

  UpdatePage(
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
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  int id;
  bool isAutoRequestInstall = true;

  bool isClickHotUpgrade;

  GlobalKey<ScaffoldState> _state = GlobalKey();

  String iosVersion = "";

  @override
  void initState() {
    super.initState();
  }

  Widget _buildMultiPlatformWidget() {
    if (Platform.isAndroid) {
      return _buildAndroidPlatformWidget();
    } else if (Platform.isIOS) {
      return _buildIOSPlatformWidget();
    } else {
      return Container(
        child: Text('Sorry, your platform is not support'),
      );
    }
  }

  Widget _buildIOSPlatformWidget() => ListView(
        children: <Widget>[
          ListTile(
            title: Text('Go to url(WeChat)'),
            onTap: () async {
              RUpgrade.upgradeFromUrl(
                'https://apps.apple.com/cn/app/wechat/id414478124?l=en',
              );
            },
          ),
          ListTile(
            title: Text('Go to appStore from appId(WeChat)'),
            onTap: () async {
              RUpgrade.upgradeFromAppStore(
                '414478124',
              );
            },
          ),
          ListTile(
            title: Text('get version from app store(WeChat)'),
            trailing: iosVersion != null
                ? Text(iosVersion,
                    style: Theme.of(context).textTheme.subtitle.copyWith(
                          color: Colors.grey,
                        ))
                : null,
            onTap: () async {
              String versionName =
                  await RUpgrade.getVersionFromAppStore('414478124');
              setState(() {
                iosVersion = versionName;
              });
            },
          ),
        ],
      );

  Widget _buildAndroidPlatformWidget() => ListView(
        children: <Widget>[
          _buildDownloadWindow(),
          Divider(),
          ListTile(
            title: Text(
              '更新选择',
              style: Theme.of(context).textTheme.title.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ListTile(
            title: Text('跳转到应用商店'),
            onTap: () async {
//              bool isSuccess =
//                  await RUpgrade.upgradeFromAndroidStore(AndroidStore.BAIDU);
//              print('${isSuccess ? '跳转成功' : '跳转失败'}');
              Fluttertoast.showToast(msg: "还没上架应用商店...");
            },
          ),
          ListTile(
            title: Text('点击这里直接下载更新'),
            onTap: () async {
              if (isClickHotUpgrade != null) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('已开始下载')));
                return;
              }
              isClickHotUpgrade = false;

              if (!await canReadStorage()) return;
              String url = widget.downloadUrl;
              url = url.replaceAll("github.com", "github.strcpy.cn");
              id = await RUpgrade.upgrade(
                  url,
                  apkName: widget.name,
                  isAutoRequestInstall: isAutoRequestInstall,
                  useDownloadManager: false);
              setState(() {});
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              '安装相关',
              style: Theme.of(context).textTheme.title.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ListTile(
            title: Text('安装apk'),
            onTap: () async {
              if (id != null) {
                bool isSuccess = await RUpgrade.install(id);
                if (isSuccess) {
                  _state.currentState
                      .showSnackBar(SnackBar(content: Text('请求成功')));
                }
              } else {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('请先下载安装包再安装.')));
              }
            },
          ),
          CheckboxListTile(
            value: isAutoRequestInstall,
            onChanged: (bool value) {
              setState(() {
                isAutoRequestInstall = value;
              });
            },
            title: Text('下载完进行安装'),
          ),
          Divider(),
          ListTile(
            title: Text(
              '更新进度选择',
              style: Theme.of(context).textTheme.title.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ListTile(
            title: Text('继续更新'),
            onTap: () async {
              if (id == null) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('当前没有ID可升级')));
                return;
              }
              await RUpgrade.upgradeWithId(id);
              setState(() {});
            },
          ),
          ListTile(
            title: Text('暂停更新'),
            onTap: () async {
              bool isSuccess = await RUpgrade.pause(id);
              if (isSuccess) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('暂停成功')));
                setState(() {});
              }
              print('cancel');
            },
          ),
          ListTile(
            title: Text('取消更新'),
            onTap: () async {
              bool isSuccess = await RUpgrade.cancel(id);
              if (isSuccess) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('取消成功')));
                id = null;
                isClickHotUpgrade = null;
                setState(() {});
              }
              print('cancel');
            },
          ),
          Divider(),
        ],
      );

  int lastId;

  DownloadStatus lastStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _state,
      appBar: AppBar(
        title: Text("新的版本: " + widget.version),
      ),
      body: _buildMultiPlatformWidget(),
    );
  }

  Widget _buildDownloadWindow() => Container(
        height: 250,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: id != null
            ? StreamBuilder(
                stream: RUpgrade.stream,
                builder: (BuildContext context,
                    AsyncSnapshot<DownloadInfo> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          height: 150,
                          width: 150,
                          child: CircleDownloadWidget(
                            backgroundColor: snapshot.data.status ==
                                    DownloadStatus.STATUS_SUCCESSFUL
                                ? Colors.green
                                : null,
                            progress: snapshot.data.percent / 100,
                            child: Center(
                              child: Text(
                                snapshot.data.status ==
                                        DownloadStatus.STATUS_RUNNING
                                    ? getSpeech(snapshot.data.speed)
                                    : getStatus(snapshot.data.status),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                            '${snapshot.data.planTime.toStringAsFixed(0)}s后完成'),
                      ],
                    );
                  } else {
                    return SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    );
                  }
                },
              )
            : Text('等待下载'),
      );

  String getStatus(DownloadStatus status) {
    if (status == DownloadStatus.STATUS_FAILED) {
      id = null;
      isClickHotUpgrade = null;
      return "下载失败";
    } else if (status == DownloadStatus.STATUS_PAUSED) {
      return "下载暂停";
    } else if (status == DownloadStatus.STATUS_PENDING) {
      return "获取资源中";
    } else if (status == DownloadStatus.STATUS_RUNNING) {
      return "下载中";
    } else if (status == DownloadStatus.STATUS_SUCCESSFUL) {
      return "下载成功";
    } else if (status == DownloadStatus.STATUS_CANCEL) {
      id = null;
      isClickHotUpgrade = null;
      return "下载取消";
    } else {
      id = null;
      isClickHotUpgrade = null;
      return "未知";
    }
  }

  Future<bool> canReadStorage() async {
    if (Platform.isIOS) return true;
    var status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      var future = await [Permission.storage].request();
      for (final item in future.entries) {
        if (item.value != PermissionStatus.granted) {
          return false;
        }
      }
    } else {
      return true;
    }
    return true;
  }

  String getSpeech(double speech) {
    String unit = 'kb/s';
    String result = speech.toStringAsFixed(2);
    if (speech > 1024 * 1024) {
      unit = 'gb/s';
      result = (speech / (1024 * 1024)).toStringAsFixed(2);
    } else if (speech > 1024) {
      unit = 'mb/s';
      result = (speech / 1024).toStringAsFixed(2);
    }
    return '$result$unit';
  }
}

class CircleDownloadWidget extends StatelessWidget {
  final double progress;
  final Widget child;
  final Color backgroundColor;

  const CircleDownloadWidget(
      {Key key, this.progress, this.child, this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: CircleDownloadCustomPainter(
          backgroundColor ?? Colors.grey[400],
          Theme.of(context).primaryColor,
          progress,
        ),
        child: child,
      ),
    );
  }
}

class CircleDownloadCustomPainter extends CustomPainter {
  final Color backgroundColor;
  final Color color;
  final double progress;

  Paint mPaint;

  CircleDownloadCustomPainter(this.backgroundColor, this.color, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (mPaint == null) mPaint = Paint();
    double width = size.width;
    double height = size.height;

    Rect progressRect =
        Rect.fromLTRB(0, height * (1 - progress), width, height);
    Rect widgetRect = Rect.fromLTWH(0, 0, width, height);
    canvas.clipPath(Path()..addOval(widgetRect));

    canvas.drawRect(widgetRect, mPaint..color = backgroundColor);
    canvas.drawRect(progressRect, mPaint..color = color);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
