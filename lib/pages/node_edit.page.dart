import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:vnote/application.dart';
import 'package:vnote/widgets/markdown_text_input.dart';

class NoteEditPage extends StatefulWidget {
  final String markdownSource;
  final String id;
  final String name;

  NoteEditPage(
      {Key key,
      @required String markdownSource,
      @required String id,
      @required String name})
      : this.markdownSource = markdownSource,
        this.id = id,
        this.name = name,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  String content;

  @override
  void initState() {
    super.initState();
    content = widget.markdownSource;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.remove_red_eye),
            color: Colors.white,
            onPressed: () {
              print("点击预览, 将编辑的内容返回去!");

              // 这里应该有几个步骤
              // 点击了预览, 说明要保存
              // 1. 保存到本地, 图片链接不变
              print("更新后的内容存入本地");
              Application.sp.setString(widget.id, content);

              // 2. 调用接口更新, 图片链接需要替换, 而且需要找到新增的图片

              // 3. 更新 _vnote.json 文件

              //print(content);
              // 这里将编辑后的内容返回去
              Navigator.pop(context, content);
              // 同时应该保存下来
            },
          ),
        ],
      ),
      body: MarkdownTextInput(
        (String value) => setState(() => content = value),
        content,
        label: '输入 markdown 内容',
      ),
    );
  }
}
