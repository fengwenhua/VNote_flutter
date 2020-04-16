import 'dart:convert';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:vnote/application.dart';
import 'package:vnote/dao/onedrive_data_dao.dart';
import 'package:vnote/models/desktop_config_model.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/provider/config_id_model.dart';
import 'package:vnote/provider/data_list_model.dart';
import 'package:vnote/provider/dir_and_file_cache_model.dart';
import 'package:vnote/provider/image_folder_id_model.dart';
import 'package:vnote/provider/new_images_model.dart';
import 'package:vnote/provider/parent_id_model.dart';
import 'package:vnote/provider/token_model.dart';
import 'package:vnote/utils/global.dart';
import 'package:vnote/utils/utils.dart';
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
  String fileName;
  String fileId;
  var _nameController = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);
    ParentIdModel parentIdModel =
        Provider.of<ParentIdModel>(context, listen: false);
    NewImageListModel _newImageList =
        Provider.of<NewImageListModel>(context, listen: false);
    ImageFolderIdModel _imageFolderId =
        Provider.of<ImageFolderIdModel>(context, listen: false);
    DataListModel dataListModel =
        Provider.of<DataListModel>(context, listen: false);
    DirAndFileCacheModel dirAndFileCacheModel =
        Provider.of<DirAndFileCacheModel>(context, listen: false);
    ConfigIdModel configIdModel =
        Provider.of<ConfigIdModel>(context, listen: false);

    pr = new ProgressDialog(context);
    pr.style(message: translate("createFileTips"));

    return Scaffold(
        appBar: AppBar(
          title: Text(translate("edit.currentDir") + parentIdModel.parentName),
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
                  if(fileId != null){
                    print("如果有 id, 说明已经存过了, 接下来是更新操作即可!");

                  }else{
                    print("没有 id, 说明没有存过, 接下来是保存新文件的操作!");
                    // 文件名和内容至少一个才继续下去
                    if (fileName != null || content != null) {
                      // put 请求
                      // dataList dirCache
                      // json
                      if(fileName==null){
                        fileName = "untitled";
                      }
                      fileName=fileName.trim();
                      if(content==null){
                        content = "";
                      }
                      content=content.trim();

                      if (!fileName.contains(".md")) {
                        fileName += ".md";
                      }
                      // 去掉前后空格
                      fileName = fileName.trim();
                      content = content.trim();

                      await pr.show().then((_) async {
                        await OneDriveDataDao.uploadFile(
                            context,
                            tokenModel.token.accessToken,
                            parentIdModel.parentId,
                            content,
                            fileName)
                            .then((value) async {
                          print("上传 $fileName 文件之后返回的内容" + value.toString());
                          // 更新本地数据
                          Map<String, dynamic> jsonData =
                          jsonDecode(value.toString());
                          String id = jsonData["id"];
                          fileId = id;
                          String newFileName = jsonData["name"];
                          String dateString = jsonData['lastModifiedDateTime'];
                          DateTime date = DateTime.parse(dateString);
                          Document doc = new Document(
                              id: id,
                              name: newFileName,
                              isFile: true,
                              dateModified: date);

                          dataListModel.addEle(doc);
                          dirAndFileCacheModel.addDirOrFileEle(
                              parentIdModel.parentId, doc);
                          // 下面是更新当前目录的 _vnote.json 文件
                          String configId = configIdModel.configId;
                          print("接下来开始下载当前目录下的 _vnote.json 文件, 然后更新它的 files 字段");
                          await OneDriveDataDao.getFileContent(
                              context, tokenModel.token.accessToken, configId)
                              .then((value) async {
                            print("要添加的文件名称: " + newFileName);
                            Map<String, dynamic> newFileMap =
                            jsonDecode(Utils.newFileJson(newFileName));
                            DesktopConfigModel desktopConfigModel =
                            DesktopConfigModel.fromJson(
                                json.decode(value.toString()));
                            //print("添加之前: ");
                            //print(json.encode(desktopConfigModel));
                            desktopConfigModel.addNewFile(newFileMap);

                            print("添加之后: ");
                            print(json.encode(desktopConfigModel));

                            print("添加成功_vnote.json 之后, 就是更新这个文件");
                            await OneDriveDataDao.updateContent(
                                context,
                                tokenModel.token.accessToken,
                                configId,
                                json.encode(desktopConfigModel))
                                .then((value) {
                              if (value != null) {
                                print("_vnote.json 更新成功");
                              }
                            });
                          });
                        });
                      }).then((_) async {
                        await pr.hide();
                        print("新建后将内容存入本地");
                        Application.sp.setString(fileId, content);

                        // 搞完进入预览页面, 销毁本页面
                        String route =
                            '/preview?content=${Uri.encodeComponent(content)}&id=${Uri.encodeComponent(fileId)}&name=${Uri.encodeComponent(fileName)}&type=${Uri.encodeComponent("1")}';
                        Application.router.navigateTo(context, route,
                            transition: TransitionType.fadeIn).then((result){
                              print("搞定直接滚");
                          Navigator.of(context).pop();
                        });
                      });
                    } else {
                      Fluttertoast.showToast(
                          msg: "起码先起个名字再保存啊~~",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 3,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  }


                }),
          ],
        ),
        body: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10.0),
                  icon: Icon(Icons.title),
                  hintText: translate("edit.fileNameTips")),
              autofocus: false,
              onChanged: (data) {
                fileName = data;
              },
            ),
            Expanded(
              child: MarkdownTextInput(
                (String value) => setState(() => content = value),
                content,
                label: translate("edit.contentTips"),
              ),
            )
          ],
        ));
  }

  Future<void> showAlertDialog(BuildContext context) async {
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(translate("giveUpDialog.content")),
            title: Center(
                child: Text(
              translate("giveUpDialog.title"),
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
                  child: Text(translate("giveUpDialog.ok"))),
              FlatButton(
                  onPressed: () {
                    print("点击了放弃修改的取消");
                    Navigator.of(context).pop();
                  },
                  child: Text(translate("giveUpDialog.cancel"))),
            ],
          );
        });
  }
}
