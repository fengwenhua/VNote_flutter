import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:vnote/provider/parent_id_model.dart';
import 'package:vnote/provider/token_model.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/widgets/markdown_text_input.dart';
import 'package:vnote/widgets/webview.dart';

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

// 前面加下划线即为内部类, 不能为外部访问
class _CreatePageState extends State<CreatePage> {
  String content;
  ProgressDialog pr;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);
    ParentIdModel parentIdModel =
    Provider.of<ParentIdModel>(context, listen: false);

    pr = new ProgressDialog(context);
    pr.style(message: '文件创建 ing');

    return Scaffold(
      appBar: AppBar(
        title: Text("当前目录: " + parentIdModel.parentName),
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
                  print("点击预览, 准备保存新文件");
                }
            ),
          ],
      ),
      body: Column(
        children: <Widget>[
          TextField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10.0),
              icon: Icon(Icons.title),
              labelText: '请输入文件名'
            ),
            autofocus: false,
            onChanged: (data){

            },
          ),
          Expanded(
            child: MarkdownTextInput(
                  (String value) => setState(() => content = value),
              content,
              label: '输入 markdown 内容',
            ),
          )
        ],
      )
    );
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
                    Navigator.pop(context);
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
}
