import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 页面常见的宽度与高度
// 宽度
double width100 = ScreenUtil.getInstance().setWidth(10);
double width750 = ScreenUtil.getInstance().setWidth(750);
// 高度
double height10 = ScreenUtil.getInstance().setHeight(10);
double height100 = ScreenUtil.getInstance().setHeight(100);
double height1314 = ScreenUtil.getInstance().setHeight(1314);
// 字体
double fontSize24 = ScreenUtil.getInstance().setSp(24);
double fontSize40 = ScreenUtil.getInstance().setSp(40);
double fontSize100 = ScreenUtil.getInstance().setSp(100);
double fontSize200 = ScreenUtil.getInstance().setSp(200);

final String CLIENT_ID = "fd49989c-b57c-49a4-9832-8172ae6a4162";
final String REDIRECT_URL = "https://login.microsoftonline.com/common/oauth2/nativeclient";
final String CLIENT_SECRET = "pHT_.O-ocr0@e2p0QqtOQfB33BQGvr.L";