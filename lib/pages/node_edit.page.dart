import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:vnote/application.dart';
import 'package:vnote/dao/onedrive_data_dao.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/provider/new_images_model.dart';
import 'package:vnote/provider/token_model.dart';
import 'package:vnote/utils/utils.dart';
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
  String _choice = 'Nothing';

  @override
  void initState() {
    super.initState();
    content = widget.markdownSource;
  }

  Future<void> showAlertDialog(BuildContext context) async {
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('是否放弃编辑?'),
            title: Center(
                child: Text(
              '警告',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            )),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    print("点击了放弃修改的确定");
                    Navigator.of(context).pop();
                    Navigator.pop(context, widget.markdownSource);
                  },
                  child: Text('确定')),
              FlatButton(
                  onPressed: () {
                    print("点击了放弃修改的取消");
                    Navigator.of(context).pop();
                  },
                  child: Text('取消')),
            ],
          );
        });
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            print("放弃修改, 直接返回?");
            showAlertDialog(context);
            //Navigator.pop(context, widget.markdownSource);
          },
        ),
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

                // 获取到 newImageList
                final _newImageList = Provider.of<NewImageListModel>(context, listen: false);
                // 本地增加的所有图片
                List<String> newImagesList = _newImageList.newImageList;
                // 调用接口上传, 上传成功后再替换
                print("本文章中新增加的图片如下: ");
                for(String i in newImagesList){
                  print(i);

                }

                t_content = t_content.replaceAll(image_path, "_v_images");
                await OneDriveDataDao.updateContent(context,
                        tokenModel.token.accessToken, widget.id, t_content)
                    .then((_) {
                  // 3. 应该在这里更新 _vnote.json 文件
                }).then((_) {
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
