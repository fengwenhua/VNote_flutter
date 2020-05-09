import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vnote/application.dart';
import 'package:vnote/res/colors.dart';
import 'package:vnote/res/styles.dart';

/// [ThemeProvider] 用于设置主题
class ThemeProvider extends ChangeNotifier {
  static const Map<ThemeMode, String> themes = {
    ThemeMode.dark: 'Dark',
    ThemeMode.light: 'Light',
    ThemeMode.system: 'System'
  };

  /// [initTheme] 用于初始化主题, 默认是跟随系统
  void initTheme() {
    String theme = Application.sp.getString('AppTheme');
    if (theme == null) {
      Application.sp.setString("AppTheme", "System");
      theme = "System";
    }
    if (theme.isNotEmpty && theme != themes[ThemeMode.system]) {
      notifyListeners();
    }
  }

  /// [setTheme] 用于设置主题
  void setTheme(ThemeMode themeMode) {
    Application.sp.setString('AppTheme', themes[themeMode]);
    notifyListeners();
  }

  ThemeMode getThemeMode() {
    String theme = Application.sp?.getString('AppTheme');
    print(theme);
    switch (theme) {
      case 'Dark':
        return ThemeMode.dark;
      case 'Light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  /// [getTheme] 用于获取主题
  getTheme({bool isDarkMode: false}) {
    //print("夜间模式?" + isDarkMode.toString());
    return ThemeData(
        errorColor: isDarkMode ? Colours.dark_red : Colours.red,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
        accentColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
        // Tab指示器颜色
        indicatorColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
        // 页面背景色
        scaffoldBackgroundColor:
            isDarkMode ? Colours.dark_bg_color : Colors.white,
        // 主要用于Material背景色
        canvasColor: isDarkMode ? Colours.dark_material_bg : Colors.white,
        // 文字选择色（输入框复制粘贴菜单）
        textSelectionColor: Colours.app_main.withAlpha(70),
        textSelectionHandleColor: Colours.app_main,
        textTheme: TextTheme(
          // TextField输入文字颜色
          subtitle1: isDarkMode ? TextStyles.textDark : TextStyles.text,
          // Text文字样式
          bodyText2: isDarkMode ? TextStyles.textDark : TextStyles.text,
          subtitle2:
              isDarkMode ? TextStyles.textDarkGray12 : TextStyles.textGray12,
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle:
              isDarkMode ? TextStyles.textHint14 : TextStyles.textDarkGray14,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0.0,
          color: isDarkMode ? Colours.dark_bg_color : Colors.blue,
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        dividerTheme: DividerThemeData(
            color: isDarkMode ? Colours.dark_line : Colours.line,
            space: 0.6,
            thickness: 0.6),
        cupertinoOverrideTheme: CupertinoThemeData(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ));
  }
}
