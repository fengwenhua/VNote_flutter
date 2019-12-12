import 'package:shared_preferences/shared_preferences.dart';

class StorageUtils {
  static Future save(String key, String value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(key, value);
    print("存储完毕");
  }

  static Future<String> load(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String value = sharedPreferences.get(key);
    if (value != null) {
      return value;
    } else {
      print("该key没有值");
      return "";
    }
  }

  static Future remove(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(key);
    print("删除成功");
  }
}
