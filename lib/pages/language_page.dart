import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:vnote/utils/global.dart';

class LanguagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;
    var color = Theme.of(context).primaryColor;

    //构建语言选择项
    Widget _buildLanguageItem(String lan, value) {
      return ListTile(
        title: Text(
          lan,
          // 对APP当前语言进行高亮显示
          style: TextStyle(
              color:
                  '${localizationDelegate.currentLocale.languageCode}_${localizationDelegate.currentLocale.countryCode}' ==
                          value
                      ? color
                      : null),
        ),
        trailing:
            '${localizationDelegate.currentLocale.languageCode}_${localizationDelegate.currentLocale.countryCode}' ==
                    value
                ? Icon(Icons.done, color: color)
                : null,
        onTap: () {
          print("点击切换语言");
          print(value);
          // 切换语言
          changeLocale(context, value);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(
            translate(
                'language.name.${localizationDelegate.currentLocale.languageCode}'),
          ),
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: ListView(
        children: <Widget>[
          _buildLanguageItem("中文简体", "zh_Hans"),
          _buildLanguageItem("English", "en_US")
        ],
      ),
    );
  }
}
