import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';
import 'package:vnote/application.dart';
import 'package:vnote/provider/theme_provider.dart';

class ThemePage extends StatefulWidget {
  @override
  _ThemePageState createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  var _list = [
    translate("theme.followSystem"),
    translate("theme.open"),
    translate("theme.close")
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Application.initSp();
    });
  }

  @override
  Widget build(BuildContext context) {
    String theme = Application.sp.getString("AppTheme");
    String themeMode;
    switch (theme) {
      case 'Dark':
        themeMode = _list[1];
        break;
      case 'Light':
        themeMode = _list[2];
        break;
      default:
        themeMode = _list[0];
        break;
    }
    return Scaffold(
      appBar: AppBar(
          title: Text(translate("theme.title")),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: ListView.separated(
          shrinkWrap: true,
          itemCount: _list.length,
          separatorBuilder: (_, index) {
            return const Divider();
          },
          itemBuilder: (_, index) {
            return InkWell(
              onTap: () => Provider.of<ThemeProvider>(context, listen: false)
                  .setTheme(index == 0
                      ? ThemeMode.system
                      : (index == 1 ? ThemeMode.dark : ThemeMode.light)),
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 50.0,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(_list[index]),
                    ),
                    Opacity(
                        opacity: themeMode == _list[index] ? 1 : 0,
                        child: Icon(Icons.done, color: Colors.blue))
                  ],
                ),
              ),
            );
          }),
    );
  }
}
