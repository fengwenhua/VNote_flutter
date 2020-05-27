import 'package:flutter/material.dart';

/// [ConfigIdProvider] 存储每个文件同目录下的配置文件 _vnote.json 的 id
class ConfigIdProvider with ChangeNotifier {
  String _configId;

  String get configId => _configId;

  void updateConfigId(String newId) {
//    print("\n\n\n");
//    print("###############################################################");
    print("更新了 configId 如下: ");
    print(newId);
//    print("###############################################################");
//    print("\n\n\n");
    _configId = newId;
    notifyListeners();
  }
}
