import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:vnote/pages/splash_screen_page.dart';
import 'package:vnote/provider/config_id_model.dart';
import 'package:vnote/provider/data_list_model.dart';
import 'package:vnote/provider/dir_and_file_cache_model.dart';
import 'package:vnote/provider/image_folder_id_model.dart';
import 'package:vnote/provider/local_document_provider.dart';
import 'package:vnote/provider/new_images_model.dart';
import 'package:vnote/provider/parent_id_model.dart';
import 'package:vnote/provider/preview_model.dart';
import 'package:vnote/provider/theme_model.dart';
import 'package:vnote/provider/token_model.dart';
import 'package:vnote/application.dart';
import 'package:vnote/route/navigate_service.dart';
import 'package:vnote/route/routes.dart';
import 'package:vnote/utils/log_util.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vnote/utils/translate_preferences.dart';

void main() async {
  // 初始化路由
  final router = new Router();
  Routes.configureRoutes(router);
  Application.router = router;
  Application.setupLocator();
  Provider.debugCheckInvalidValueType = null;
  LogUtil.init(tag: "VNote");

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
          ChangeNotifierProvider<DataListModel>(
            create: (context) => DataListModel(),
          ),
          ChangeNotifierProvider<PreviewModel>(
            create: (context) => PreviewModel(),
          ),
          ChangeNotifierProvider<NewImageListModel>(
            create: (context) => NewImageListModel(),
          ),
          ChangeNotifierProvider<ImageFolderIdModel>(
            create: (context) => ImageFolderIdModel(),
          ),
          ChangeNotifierProvider<ParentIdModel>(
            create: (context) => ParentIdModel(),
          ),
          ChangeNotifierProvider<ConfigIdModel>(
            create: (context) => ConfigIdModel(),
          ),
          ChangeNotifierProvider<DirAndFileCacheModel>(
            create: (context) => DirAndFileCacheModel(),
          ),
          ChangeNotifierProvider<ThemeProvider>(
            create: (context) => ThemeProvider(),
          ),
          ChangeNotifierProvider<LocalDocumentProvider>(
            create: (context) => LocalDocumentProvider(),
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
              navigatorKey: Application.getIt<NavigateService>().key,
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
