// 用于跳转时获取router
import 'package:fluro/fluro.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Application{
  static Router router;
  static SharedPreferences sp;

  static double screenWidth;
  static double screenHeight;
  static double statusBarHeight;
  static double bottomBarHeight;

  static initSp() async{
    sp = await SharedPreferences.getInstance();
  }

}