import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:vnote/application.dart';
import 'package:vnote/dao/onedrive_data_dao.dart';
import 'package:vnote/provider/token_model.dart';
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
  ProgressDialog pr;

  @override
  void initState() {
    super.initState();
    content = widget.markdownSource;
  }

  @override
  Widget build(BuildContext context) {
    TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);
    pr = new ProgressDialog(context);
    pr.style(message: '更新内容 ing');

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.remove_red_eye),
            color: Colors.white,
            onPressed: () async {
              if (widget.markdownSource == content) {
                print("没有修改内容, 直接跳");
                Navigator.pop(context, content);
              } else {
                await pr.show();
                print("点击预览, 将编辑的内容返回去!");

                // 这里应该有几个步骤
                // 点击了预览, 说明要保存
                // 1. 保存到本地, 图片链接不变
                print("更新后的内容存入本地");
                Application.sp.setString(widget.id, content);

                // 2. 调用接口更新, 图片链接需要替换, 而且需要找到新增的图片
                // 这里因为还没有写添加本地图片, 所以逻辑会简单一些
                String image_path = Application.sp.getString("appImagePath");
                print("本地图片放置目录: " + image_path);
                String t_content = content;
                t_content = t_content.replaceAll(image_path, "_v_images");
                await OneDriveDataDao.updateContent(context,
                        tokenModel.token.accessToken, widget.id, t_content)
                    .then((_) {
                  // 3. 更新 _vnote.json 文件
                  print("到此更新完了, 可以跳转了!");
                  pr.hide().then((_) {
                    Navigator.pop(context, content);
                  });
                });
              }
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
