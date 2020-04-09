import 'package:flutter/material.dart';

/// 存储每个md 文件同目录下的_v_images 的 id, 以及 _vnote.json 的 id
class ConfigIdModel with ChangeNotifier {
  String _configId;

  String get configId => _configId;

  void updateConfigId(String newId) {
    print("***********************************************");
    print("更新 _vnote.json 的 id");
    print("***********************************************");
    _configId = newId;
    notifyListeners();
  }
}
