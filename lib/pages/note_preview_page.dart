import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/widgets/webview.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class NotePreviewPage extends StatefulWidget {
  final String markdownSource;

  NotePreviewPage({Key key, @required String markdownSource})
      : this.markdownSource = markdownSource,
        super(key: key);
  @override
  _NotePreviewPageState createState() => _NotePreviewPageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _NotePreviewPageState extends State<NotePreviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我是预览', style: TextStyle(fontSize: fontSize40)),
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left),
          color: Colors.white,
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      body: Material(
        child: Markdown(data: widget.markdownSource),
      )
    );
  }
}
