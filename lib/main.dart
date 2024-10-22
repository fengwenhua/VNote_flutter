import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:vnote/pages/splash_screen_page.dart';
import 'package:vnote/provider/config_id_provider.dart';
import 'package:vnote/provider/data_list_provider.dart';
import 'package:vnote/provider/dir_and_file_cache_provider.dart';
import 'package:vnote/provider/image_folder_id_provider.dart';
import 'package:vnote/provider/local_document_provider.dart';
import 'package:vnote/provider/new_images_provider.dart';
import 'package:vnote/provider/notebooks_list_provider.dart';
import 'package:vnote/provider/parent_id_provider.dart';
import 'package:vnote/provider/theme_provider.dart';
import 'package:vnote/provider/token_provider.dart';
import 'package:vnote/application.dart';
import 'package:vnote/route/navigate_service.dart';
import 'package:vnote/route/routes.dart';
import 'package:vnote/utils/log_util.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vnote/utils/translate_preferences.dart';

void main() async {
  // 初始化路由
  final router = new FluroRouter();
  Routes.configureRoutes(router);
  Application.router = router;

  // 必须加入这一行，不然会报错
  // 这是由于 Provider 只能提供恒定的数据，不能通知依赖它的子部件刷新。
  // 提示也说的很清楚了，假如你想使用一个会发生 change 的 Provider，请使用下面的 Provider。
  // 这里我选择使用 ChangeNotifierProvider
  Provider.debugCheckInvalidValueType = null;

  LogUtil.init(tag: "VNote");

  // 国际化
  var delegate = await LocalizationDelegate.create(
      preferences: TranslatePreferences(),
      fallbackLocale: 'zh_Hans',
      basePath: 'assets/i18n/',
      supportedLocales: ['zh_Hans', 'en_US']);

  runApp(LocalizedApp(
      delegate,
      MultiProvider(
        providers: [
          ChangeNotifierProvider<TokenModel>(
            create: (context) => TokenModel(),
          ),
          ChangeNotifierProvider<DataListProvider>(
            create: (context) => DataListProvider(),
          ),
          ChangeNotifierProvider<NewImageListProvider>(
            create: (context) => NewImageListProvider(),
          ),
          ChangeNotifierProvider<ImageFolderIdProvider>(
            create: (context) => ImageFolderIdProvider(),
          ),
          ChangeNotifierProvider<ParentIdProvider>(
            create: (context) => ParentIdProvider(),
          ),
          ChangeNotifierProvider<ConfigIdProvider>(
            create: (context) => ConfigIdProvider(),
          ),
          ChangeNotifierProvider<DirAndFileCacheProvider>(
            create: (context) => DirAndFileCacheProvider(),
          ),
          ChangeNotifierProvider<ThemeProvider>(
            create: (context) => ThemeProvider(),
          ),
          ChangeNotifierProvider<LocalDocumentProvider>(
            create: (context) => LocalDocumentProvider(),
          ),
          ChangeNotifierProvider<NotebooksProvider>(
            create: (context) => NotebooksProvider(),
          )
        ],
        child: MyApp(),
      )));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;

    return LocalizationProvider(
        state: LocalizationProvider.of(context).state,
        child: Consumer<ThemeProvider>(
          builder: (context, ThemeProvider provider, child) {
            return MaterialApp(
              title: 'VNote',
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                localizationDelegate,
                const FallbackCupertinoLocalisationsDelegate(),
              ],
              supportedLocales: localizationDelegate.supportedLocales,
              locale: localizationDelegate.currentLocale,
              debugShowCheckedModeBanner: false, // 去除调试
              theme: provider.getTheme(),
              darkTheme: provider.getTheme(isDarkMode: true),
              themeMode: provider.getThemeMode(),
              home: SplashScreenPage(),
              // 初始化路由
              onGenerateRoute: Application.router.generator,
            );
          },
        ));
  }
}

/// CupertinoAlertDialog，点击弹出按键时报：The getter 'alertDialogLabel' was called on null
/// 加入这个类，然后在 material 里的 localizationsDelegates 引用解决
class FallbackCupertinoLocalisationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalisationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(FallbackCupertinoLocalisationsDelegate old) => false;
}
