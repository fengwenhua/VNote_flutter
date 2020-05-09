import 'package:flutter/material.dart';

/// [ConfigIdModel] 存储每个文件同目录下的配置文件 _vnote.json 的 id
class ConfigIdModel with ChangeNotifier {
  String _configId;

  String get configId => _configId;

  void updateConfigId(String newId) {
    _configId = newId;
    notifyListeners();
  }
}
