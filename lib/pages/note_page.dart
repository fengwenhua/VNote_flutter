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
import 'package:vnote/provider/local_document_provider.dart';
import 'package:vnote/provider/token_model.dart';
import 'package:vnote/utils/document_list_util.dart';
import 'package:vnote/utils/global.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:vnote/utils/utils.dart';
import 'package:vnote/widgets/file_widget.dart';

class NotePage extends StatefulWidget {
  @override
  _NotePageState createState() => _NotePageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _NotePageState extends State<NotePage> {
  // 先判断本地有没有 _myNote.json
  // 没有就新建, 内容为 {"files":[]}
  // 有就读取进来, 变成 Document, 渲染出来
  // 在 directroy_page 中, 每次点击一个 md 文件, 都用 SP 记录下来(id,content),并且写入_myNote.json 文件
  // 不搞 provider, 直接弄个下拉更新, 或者点击更新按钮

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          title: Text(translate("note.appbar"),
              style: TextStyle(fontSize: fontSize40)),
          leading: IconButton(
            icon: Icon(
              Icons.dehaze,
              color: Colors.white,
            ),
            onPressed: () {
              // 打开Drawer抽屉菜单
              print("点击了侧滑按钮");
              Scaffold.of(context).openDrawer();
            },
          ),
      actions: <Widget>[
        new IconButton(
            icon: new Icon(Icons.refresh),
            tooltip: "Update",
            onPressed: () async {
              print("点击刷新");
              // 这里应该重新比对???
              LocalDocumentProvider localDocumentProvider =
              Provider.of<LocalDocumentProvider>(context, listen: false);
              await Utils.model2ListDocument().then((data) {
                print("directory_page 这里拿到 _myNote.json 的数据");
                localDocumentProvider.updateList(data);
                Fluttertoast.showToast(
                    msg: "本地缓存读取完成!",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 3,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);

              });
            })
      ],),
      body: Consumer<LocalDocumentProvider>(
        builder: (context, LocalDocumentProvider localDocumentProvider, child)=>localDocumentProvider.list == null ||
            localDocumentProvider.list.length == 0
            ? Center(
          child: Text(translate("note.tips")),
        )
            : Scrollbar(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: localDocumentProvider.list.length,
            itemBuilder: (context, index) {
              return localDocumentProvider.list
                  .map((document) {
                return Container(
                  margin: const EdgeInsets.only(left: 4.0),
                  child: getFileWidget(context, document: document),
                );
              })
                  .toList()
                  .elementAt(index);
            },
          ),
        ),
      )
    );
  }
}

FileWidget getFileWidget(BuildContext context, {@required Document document}) =>
    FileWidget(
      fileName: document.name,
      lastModified: document.dateModified,
      onPressedNext: () async {
        ProgressDialog pr;
        pr = new ProgressDialog(context, isDismissible: true);
        pr.style(message: translate("waitTips"));
        print("点击了 ${document.name} 文件");

        // 转圈圈和下载 md 文件
        await pr.show().then((_) {
          _getMDFile(context, document, pr);
        });
        //_clickDocument(document);
      },
    );

_getMDFile(BuildContext context, Document document, ProgressDialog prt) async {
  TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);
  // 这里
  DataListModel dataListModel =
      Provider.of<DataListModel>(context, listen: false);

  bool hasImageFolder = false;
  final _imageFolderIdAndConfigIdModel =
      Provider.of<ImageFolderIdModel>(context, listen: false);
  for (Document d in dataListModel.dataList) {
    if (d.name == "_v_images") {
      // 在这里拿到了 imageFolder 的 id, 即是 _v_images的 id
      _imageFolderIdAndConfigIdModel.updateImageFolderId(d.id);
      hasImageFolder = true;
      break;
    }
  }

  if (!hasImageFolder) {
    _imageFolderIdAndConfigIdModel.updateImageFolderId("noimagefolder");
  }

  // 测试 Application.sp.containsKey(document.id)
  if (Application.sp.containsKey(document.id)) {
    // 本地有文档缓存
    print("使用本地文章缓存");
    await Future.delayed(Duration(milliseconds: 100), () {
      prt.hide().whenComplete(() {
        String route =
            '/preview?content=${Uri.encodeComponent(Application.sp.getString(document.id))}&id=${Uri.encodeComponent(document.id)}&name=${Uri.encodeComponent(document.name)}&type=${Uri.encodeComponent("0")}';
        Application.router
            .navigateTo(context, route, transition: TransitionType.fadeIn);
      });
    });
  } else {
    // 本地没有, 从网络下载
    print("从网络下载文章");
    await DocumentListUtil.instance
        .getMDFileContentFromNetwork(
            context, tokenModel.token.accessToken, document.id, prt)
        .then((data) {
      print("看看这玩意张啥样:");
      print(data);
      if (data == null) {
        print("超时, 没有获得数据");
        if (prt.isShowing()) {
          prt.hide();
        }
        Fluttertoast.showToast(
            msg: "网络连接超时!!!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        // 这里需要跳转到预览页面
        print("跳转到预览页面");
        prt.hide().whenComplete(() {
          String route =
              '/preview?content=${Uri.encodeComponent(data.toString())}&id=${Uri.encodeComponent(document.id)}&name=${Uri.encodeComponent(document.name)}&type=${Uri.encodeComponent("0")}';
          Application.router
              .navigateTo(context, route, transition: TransitionType.fadeIn);
        });
      }
    });
  }
}
