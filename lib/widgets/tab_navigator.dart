import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnote/pages/create_page.dart';
import 'package:vnote/pages/directory_page.dart';
import 'package:vnote/pages/label_page.dart';
import 'package:vnote/pages/note_page.dart';
import 'package:vnote/pages/search_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vnote/provider/data_list_model.dart';
import 'package:vnote/utils/navigator_util.dart';

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
        floatingActionButton: Container(
          height: 60,
          width: 60,
          padding: EdgeInsets.all(4),
          margin: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: Colors.white,
          ),
          child: FloatingActionButton(
              child: Icon(Icons.add,color: Colors.black,size: 40,),
              onPressed: (){
                print('FloatingActionButton');
                _controller.jumpToPage(2); // 调用controller切换页面
                setState(() {
                  _currentIndex = 2; // 更新页面
                });
              },
              backgroundColor: this._currentIndex==2?Colors.red:Colors.yellow,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        drawer: Drawer(
          child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: Text("江南小虫虫"),
                    accountEmail: Text("807296772@qq.com"),
                    currentAccountPicture: GestureDetector(
                      child: CircleAvatar(
                        backgroundImage: ExactAssetImage('images/vnote.png'),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text("退出登录"),
                    leading: Icon(
                      Icons.arrow_drop_down_circle,
                      color: Colors.orange,
                    ),
                    onTap: () {
                      // 关闭侧滑菜单
                      Navigator.of(context).pop();
                      // 执行清除token的操作, 并且进入登录界面
                      NavigatorUtil.goLoginPage(context);
                    },
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
                  "笔记",
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
                  "文件夹",
                  style: TextStyle(
                    color: _currentIndex != 1 ? _defaultColor : _activeColor,
                  ),
                )),
            // 新建
            BottomNavigationBarItem(
                icon: Icon(
                  // 没激活的图标
                  Icons.add,
                  color: _defaultColor,
                ),
                activeIcon: Icon(
                  // 选中后的图标
                  Icons.add,
                  color: _activeColor,
                ),
                title: Text(
                  "新建",
                  style: TextStyle(
                    color: _currentIndex != 2 ? _defaultColor : _activeColor,
                  ),
                )),
            // 标签
            BottomNavigationBarItem(
                icon: Icon(
                  // 没激活的图标
                  Icons.label,
                  color: _defaultColor,
                ),
                activeIcon: Icon(
                  // 选中后的图标
                  Icons.label,
                  color: _activeColor,
                ),
                title: Text(
                  "标签",
                  style: TextStyle(
                    color: _currentIndex != 3 ? _defaultColor : _activeColor,
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
                  "搜索",
                  style: TextStyle(
                    color: _currentIndex != 3 ? _defaultColor : _activeColor,
                  ),
                )),
          ],
        ),
        body: Consumer<DataListModel>(
          builder: (context, DataListModel model, _) => PageView(
            onPageChanged: _pageChange,
            controller: _controller,
            children: <Widget>[
              NotePage(),
              DirectoryPage(documents: model.dataList),
              CreatePage(),
              LabelPage(),
              SearchPage()
            ],
            physics: new NeverScrollableScrollPhysics(), //禁止滑动
          ),
        ));
  }
}
