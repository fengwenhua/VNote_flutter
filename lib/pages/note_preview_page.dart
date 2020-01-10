import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:vnote/provider/token_model.dart';
import 'package:vnote/utils/document_list_util.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/widgets/webview.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class NotePreviewPage extends StatefulWidget {
  final String markdownSource;
  final String id;
  final String name;

  NotePreviewPage(
      {Key key,
      @required String markdownSource,
      @required String id,
      @required String name})
      : this.markdownSource = markdownSource,
        this.id = id,
        this.name = name,
        super(key: key);
  @override
  _NotePreviewPageState createState() => _NotePreviewPageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _NotePreviewPageState extends State<NotePreviewPage> {
  String content;
  ProgressDialog pr;

  @override
  void initState() {
    super.initState();
    content = widget.markdownSource;
  }

  /// 点击更新按钮, 更新 md 文件
  _updateMDFile(String id) async {
    TokenModel tokenModel = Provider.of<TokenModel>(context);
    await DocumentListUtil.instance
        .getMDFileContentFromNetwork(context, tokenModel.token.accessToken, id).then((value){
        pr.hide().whenComplete((){
          setState(() {
            content = value;
          });
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context);
    pr.style(message: 'Please wait...');

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.name, style: TextStyle(fontSize: fontSize40)),
          leading: IconButton(
            icon: Icon(Icons.keyboard_arrow_left),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.cached),
              color: Colors.white,
              onPressed: () {
                print("点击刷新了");
                pr.show();
                _updateMDFile(widget.id);
              },
            )
          ],
        ),
        body: Material(
          child: Markdown(data: content),
        ));
  }
}
