import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vnote/application.dart';
import 'package:vnote/dao/onedrive_data_dao.dart';
import 'package:vnote/pages/create_page.dart';
import 'package:vnote/pages/directory_page.dart';
import 'package:vnote/pages/note_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vnote/provider/data_list_provider.dart';
import 'package:vnote/provider/parent_id_provider.dart';
import 'package:vnote/utils/navigator_util.dart';
import 'package:vnote/pages/search_page.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:vnote/utils/utils.dart';

class TabNavigator extends StatefulWidget {
  @override
  _TabNavigatorState createState() => _TabNavigatorState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _TabNavigatorState extends State<TabNavigator> {
  // 没选中状态是灰色
  final _defaultColor = Colors.grey;
  // 选中状态是蓝色
  final _activeColor = Colors.blue;
  // 当前的层次
  int level = 0;

  // 默认是笔记
  int _currentIndex = 0;

  final PageController _controller = PageController(
    initialPage: 0, // 初始状态下显示第0个tab
  );

  void _pageChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    //设置适配尺寸 (填入设计稿中设备的屏幕尺寸) 假如设计稿是按iPhone6的尺寸设计的(iPhone6 750*1334)
    ScreenUtil.init(context, width: 750, height: 1334);

    return Scaffold(
        floatingActionButton: _currentIndex == 1
            ? FloatingActionButton(
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () {
                  print('FloatingActionButton');
                  // 这里应该点击进入 create 页面
                  ParentIdProvider parentIdModel =
                      Provider.of<ParentIdProvider>(context, listen: false);
                  if (parentIdModel.parentId == parentIdModel.rootId) {
                    print("在根目录, 没办法新建文件");
                    Fluttertoast.showToast(
                        msg: translate("tab.tips"),
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 3,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  } else {
                    String route =
                        '/newFile?content=${Uri.encodeComponent("null")}&id=${Uri.encodeComponent("null")}&name=${Uri.encodeComponent("null")}';

                    Application.router.navigateTo(context, "/newFile",
                        transition: TransitionType.fadeIn);
                  }
                },
              )
            : null,
        drawer: Drawer(
          child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView(
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 60.0,
                        height: 60.0,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: ExactAssetImage('assets/images/vnote.png'),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(translate("drawer.notebooks")),
                        leading: Icon(Icons.import_contacts, color: Colors.blue),
                        onTap: () {
                          print("点击笔记本");
                          Navigator.of(context).pop();
                          Application.router.navigateTo(context, "/notebooks",
                              transition: TransitionType.fadeIn);

                        },
                      ),
                      ListTile(
                        title: Text(translate("drawer.settings")),
                        leading: Icon(Icons.settings, color: Colors.blue),
                        onTap: () {
                          print("点击设置");
                          Application.router.navigateTo(context, "/settings",
                              transition: TransitionType.fadeIn);
                        },
                      ),
                      ListTile(
                        title: Text(translate("drawer.logout")),
                        leading: Icon(
                          Icons.power_settings_new,
                          color: Colors.blue,
                        ),
                        onTap: () {
                          // 关闭侧滑菜单
                          Navigator.of(context).pop();
                          // 进入注销界面
                          // 1. 删除之前从 OAuth 流收到的任何已缓存 access_token 或 refresh_token 值。
                          // 2. 在应用中执行任意注销操作（例如，清除本地状态、删除所有缓存项等）
                          // 3. 使用以下 URL 调用授权 Web 服务：
                          //Utils.deleteTemp();
                          //Utils.deleteAppSupport();
                          Utils.deleteAppDoc();
                          NavigatorUtil.goLogoutPage(context);
                          //NavigatorUtil.goLoginPage(context);
                        },
                      ),
                    ],
                  )
                ],
              )),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex, // 当前选中的是哪个页面
          onTap: (index) {
            _controller.jumpToPage(index); // 调用controller切换页面
            setState(() {
              _currentIndex = index; // 更新页面
            });
          },
          type: BottomNavigationBarType.fixed, // 默认显示文字
          items: [
            // 笔记
            BottomNavigationBarItem(
                icon: Icon(
                  // 没激活的图标
                  Icons.note,
                  color: _defaultColor,
                ),
                activeIcon: Icon(
                  // 选中后的图标
                  Icons.note,
                  color: _activeColor,
                ),
                title: Text(
                  translate("tab.note"),
                  style: TextStyle(
                    color: _currentIndex != 0 ? _defaultColor : _activeColor,
                  ),
                )),
            // 文件夹
            BottomNavigationBarItem(
                icon: Icon(
                  // 没激活的图标
                  Icons.library_books,
                  color: _defaultColor,
                ),
                activeIcon: Icon(
                  // 选中后的图标
                  Icons.library_books,
                  color: _activeColor,
                ),
                title: Text(
                  translate("tab.dir"),
                  style: TextStyle(
                    color: _currentIndex != 1 ? _defaultColor : _activeColor,
                  ),
                )),
            // 搜索
            BottomNavigationBarItem(
                icon: Icon(
                  // 没激活的图标
                  Icons.search,
                  color: _defaultColor,
                ),
                activeIcon: Icon(
                  // 选中后的图标
                  Icons.search,
                  color: _activeColor,
                ),
                title: Text(
                  translate("tab.search"),
                  style: TextStyle(
                    color: _currentIndex != 2 ? _defaultColor : _activeColor,
                  ),
                )),
          ],
        ),
        body: Consumer<DataListProvider>(
          builder: (context, DataListProvider model, _) => PageView(
            onPageChanged: _pageChange,
            controller: _controller,
            children: <Widget>[NotePage(), DirectoryPage(), SearchPage()],
            physics: new NeverScrollableScrollPhysics(), //禁止滑动
          ),
        ));
  }
}
