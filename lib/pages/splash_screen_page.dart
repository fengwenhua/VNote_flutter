import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vnote/application.dart';
import 'package:vnote/dao/onedrive_token_dao.dart';
import 'package:vnote/provider/token_model.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/utils/navigator_util.dart';

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

    _logoAnimation =
        new Tween<double>(begin: 0, end: 0.8).animate(_logoController)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              Future.delayed(Duration(milliseconds: 500), () {
                goPage();
              });
            }
          });

  }

  void goPage() async{
    // 初始化shared_preferences
    await Application.initSp();
    TokenModel tokenModel = Provider.of<TokenModel>(context);
    // 从本地存储中读取token
    tokenModel.initToken();
    if(tokenModel.token != null){
      // 本地有token, 应该刷新一下token, 然后跳到主页
      await OnedriveTokenDao.refreshToken(context, tokenModel.token.refreshToken).then((value){
        if(value.data != -1){
          // 跳转到主页
          print("跳转到主页");
          NavigatorUtil.goHomePage(context);
        }
      });
    }else{
      // 否则跳到微软登录界面
      print("跳转到微软登录界面");
      NavigatorUtil.goLoginPage(context);
    }
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