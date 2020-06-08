import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 页面常见的宽度与高度
// 宽度
double width100 = ScreenUtil().setWidth(10);
double width750 = ScreenUtil().setWidth(750);
// 高度
double height10 = ScreenUtil().setHeight(10);
double height100 = ScreenUtil().setHeight(100);
double height1314 = ScreenUtil().setHeight(1314);
// 字体
double fontSize24 = ScreenUtil().setSp(24);
double fontSize40 = ScreenUtil().setSp(40);
double fontSize100 = ScreenUtil().setSp(100);
double fontSize200 = ScreenUtil().setSp(200);

final String CLIENT_ID = "fd49989c-b57c-49a4-9832-8172ae6a4162";
final String REDIRECT_URL = "https://login.microsoftonline.com/common/oauth2/nativeclient";
final String CLIENT_SECRET = "pHT_.O-ocr0@e2p0QqtOQfB33BQGvr.L";
final List<String> WHILE_NAME = [".md", ".json", ".jpg", ".png",".gif"];
final List<String> BLACK_NAME = ["_vnote.json","_v_recycle_bin","_v_images","_v_attachments",".vswp",".json"];
final String tutorialText = '''# 0x00 初始化
进入移动端, 登录微软账号, 因为不可描述的原因, 网络可能有些缓慢, 请耐心等待! 

移动端登录进去之后, 在 OneDrive 根目录下, `应用`和`VNote`文件夹会自动帮你创建好. **注意:这里不能手动新建, OneDrive 会无法识别!**

将你原来的 vnote 笔记本全部放在这个目录下:

![](https://gitee.com/fengwenhua/ImageBed/raw/master/1586945334_20200415173543145_241879937.png)

等待 OneDrive 同步完成, 就点击右上角`刷新`按钮, 就可以看到刚刚同步的目录了

![](https://gitee.com/fengwenhua/ImageBed/raw/master/1586945335_20200415175432550_89557388.png)

初始化至此完成.

# 0x01 新建笔记本
首先要在侧滑菜单, 在笔记本项中新建或者选择笔记本.

# 0x02 新建文件夹
选择笔记本之后, 在"文件夹"tab, 点击右上角的`加号`, 就是新建文件夹

# 0x02 新建文件
进入到指定文件夹, 然后点击右下角巨大的`加号`, 就是新建文件

# 0x03 重命名/删除
左滑指定项目, 就是重命名/删除

# 0x04 搜索
搜索只支持文件名, 注意, 如果是刚刚新建的笔记, 因为 OneDrive 的原因, 可能要等一段时间才能搜索到!

# 0x05 微信文章收藏
微信公众号关注`江南小虫虫`, 点击`设置`中的`复制 token`, 发送到公众号上进行绑定, 绑定成功之后, 之后就可以发送**微信文章**链接到公众号, 后台会自动将文章收藏到`收藏`笔记本下的`微信收藏`文件夹.''';

final String BROKEN_IMAGE = "iVBORw0KGgoAAAANSUhEUgAAACQAAAAkCAYAAADhAJiYAAAA8UlEQVR4Ae2VAQbDQBBFBwEU0AMUUOQAQW9QwCJHKIJFEBSLHiAoepAeLSiCdpDAV/KHbATzeFAz2Yc0KxlxnKPaqGllo1qKkaf6Ub8Z7YTkisuZHNSDECRczuhtb0HJgzzI4Jg7KKq9ISZMO+agmoyZ6cmYmQcVBLRkDEbR80QQdUhceR6DTFH48KgGw3xQL/DbWQgKPORvDLwfC/Nhmh0giqJdWIoLLy3SwF/eHJWmpUDEYBQ7b4pKeAg+HDXMY1TFBuEh0foBzHl1jPYrwi9XD9pX0H3DoFYIyg2DKiF5bxDzEgOFWqspg516kkw4zg8tzFvlyPi7NgAAAABJRU5ErkJggg==";