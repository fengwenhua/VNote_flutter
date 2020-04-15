import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:vnote/application.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/provider/data_list_model.dart';
import 'package:vnote/provider/image_folder_id_model.dart';
import 'package:vnote/provider/token_model.dart';
import 'package:vnote/utils/document_list_util.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/widgets/webview.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class NotePreviewPage extends StatefulWidget {
  final String markdownSource;
  final String id;
  final String name;
  final String type;

  NotePreviewPage(
      {Key key,
      @required String markdownSource,
      @required String id,
      @required String name,
      @required String type})
      : this.markdownSource = markdownSource,
        this.id = id,
        this.name = name,
        this.type = type,
        super(key: key);
  @override
  _NotePreviewPageState createState() => _NotePreviewPageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _NotePreviewPageState extends State<NotePreviewPage> {
  String content;
  ProgressDialog pr1;

  @override
  void initState() {
    super.initState();
    content = widget.markdownSource;
  }

  /// 点击更新按钮, 更新 md 文件
  _updateMDFile(String id) async {
    TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);
    DataListModel dataListModel =
        Provider.of<DataListModel>(context, listen: false);
    final _imageFolderIdModel =
        Provider.of<ImageFolderIdModel>(context, listen: false);

    print("开始找图片");
    for (Document d in dataListModel.dataList) {
      if (d.name == "_v_images") {
        // 在这里更新 imageFolderid , 也就是 _v_images 文件夹的 id
        // 这里再次更新是为了预防某个叼毛, 将_v_images 干掉...

        _imageFolderIdModel.updateImageFolderId(d.id);
        break;
      }
    }

    print("准备从网络获取 md 内容");
    await DocumentListUtil.instance
        .getMDFileContentFromNetwork(
        context, tokenModel.token.accessToken, id, pr1)
        .then((value) {
      if (value == null) {
        print("gg, 拿不到更新的数据");
        if (pr1.isShowing()) {
          pr1.hide();
        }

        Fluttertoast.showToast(
            msg: "网络超时, 拿不到更新的数据",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        print("拿到更新的数据");
        pr1.hide().whenComplete(() {
          // 这里需要修改
          setState(() {
            content = value;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("初始化");
    pr1 = new ProgressDialog(context);
    pr1.style(message: '预览页面: 请等待...');

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.name, style: TextStyle(fontSize: fontSize40)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              print("点击了预览页面的返回");
              //FocusScope.of(context).requestFocus(new FocusNode());
              if (pr1.isShowing()) {
                pr1.hide().whenComplete(() {
                  Navigator.pop(context);
                });
              } else {
                Navigator.pop(context);
              }
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.cached),
              color: Colors.white,
              onPressed: () async {
                print("点击刷新了");
                await pr1.show().then((_) {
                  _updateMDFile(widget.id);
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.edit),
              color: Colors.white,
              onPressed: () {
                print("点击编辑");
                // 1 代表新建
                String route = "";

                  route =
                      '/edit?content=${Uri.encodeComponent(content)}&id=${Uri.encodeComponent(widget.id)}&name=${Uri.encodeComponent(widget.name)}';
                Application.router
                    .navigateTo(context, route,
                        transition: TransitionType.fadeIn)
                    .then((result) {
                  print("获取从编辑页面返回的数据");
                  //print(result);
                  setState(() {
                    content = result;
                  });
                });
              },
            ),
          ],
        ),
        body: Material(
          child: Markdown(data: content),
        ));
  }
}
