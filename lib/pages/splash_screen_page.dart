import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vnote/application.dart';
import 'package:vnote/utils/global.dart';

class SplashScreenPage extends StatefulWidget {
  SplashScreenPage({Key key}) : super(key: key);
  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>
    with TickerProviderStateMixin {
  AnimationController _logoController;
  //double类型动画
  Animation<double> _logoAnimation;
  Tween _scaleTween;

  @override
  void initState() {
    super.initState();

    _scaleTween = Tween(begin: 0,end: 1);
    _logoController =  AnimationController(
        vsync: this, duration: Duration(milliseconds: 500))..drive(_scaleTween);

    Future.delayed(Duration(milliseconds: 500),(){
      //启动动画
      _logoController.forward();
    });

    //animation第一种创建方式：
    _logoAnimation =
        new Tween<double>(begin: 0, end: 0.8).animate(_logoController)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((AnimationStatus status) {
            //执行完成后反向执行
            if (status == AnimationStatus.completed) {
              Future.delayed(Duration(milliseconds: 500), () {
                print("跳转到引导页面");
              });
            }
          });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _logoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);
    final size = MediaQuery.of(context).size;
    Application.screenWidth = size.width;
    Application.screenHeight = size.height;
    Application.statusBarHeight = MediaQuery.of(context).padding.top;
    Application.bottomBarHeight = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: ScaleTransition(
          scale: _logoAnimation,
          child: Image.asset('images/vnote.png'),
        ),
      ),
    );
  }
}
