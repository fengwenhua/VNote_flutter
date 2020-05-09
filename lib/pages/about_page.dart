import 'dart:async';
import 'dart:math';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:vnote/application.dart';
import 'package:vnote/widgets/click_item.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String theme;
  var _styles = [
    FlutterLogoStyle.stacked,
    FlutterLogoStyle.markOnly,
    FlutterLogoStyle.horizontal
  ];
  var _colors = [
    Colors.red,
    Colors.green,
    Colors.brown,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.amber
  ];
  var _curves = [
    Curves.ease,
    Curves.easeIn,
    Curves.easeInOutCubic,
    Curves.easeInOut,
    Curves.easeInQuad,
    Curves.easeInCirc,
    Curves.easeInBack,
    Curves.easeInOutExpo,
    Curves.easeInToLinear,
    Curves.easeOutExpo,
    Curves.easeInOutSine,
    Curves.easeOutSine,
  ];

  // 取随机颜色
  Color _randomColor() {
    var red = Random.secure().nextInt(255);
    var greed = Random.secure().nextInt(255);
    var blue = Random.secure().nextInt(255);
    return Color.fromARGB(255, red, greed, blue);
  }

  Timer _countdownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 2s定时器
      _countdownTimer = Timer.periodic(Duration(seconds: 2), (timer) {
        // https://www.jianshu.com/p/e4106b829bff
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    });
    theme = Application.sp.getString("AppTheme");
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(translate("about.name")),
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: Column(
        children: <Widget>[
          SizedBox(height: 50),
          FlutterLogo(
            size: 100.0,
            colors: _colors[Random.secure().nextInt(7)],
            textColor: _randomColor(),
            style: _styles[Random.secure().nextInt(3)],
            curve: _curves[Random.secure().nextInt(12)],
          ),
          SizedBox(height: 10),
          ClickItem(
              title: 'Github',
              content: 'Go Star',
              onTap: () {
                String route =
                    '/webview?url=${Uri.encodeComponent("https://github.com/fengwenhua/VNote_flutter")}&title=${Uri.encodeComponent("VNote_flutter")}';
                Application.router.navigateTo(context, route,
                    transition: TransitionType.fadeIn);
              }),
          ClickItem(
              title: 'developer',
              onTap: () {
                String route =
                    '/webview?url=${Uri.encodeComponent("https://fengwenhua.top/")}&title=${Uri.encodeComponent("作者博客")}';
                Application.router.navigateTo(context, route,
                    transition: TransitionType.fadeIn);
              }),
        ],
      ),
    );
  }
}
