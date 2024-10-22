import 'dart:convert';
import 'package:undo/undo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:vnote/application.dart';
import 'package:vnote/dao/onedrive_data_dao.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/provider/config_id_provider.dart';
import 'package:vnote/provider/data_list_provider.dart';
import 'package:vnote/provider/dir_and_file_cache_provider.dart';
import 'package:vnote/provider/image_folder_id_provider.dart';
import 'package:vnote/provider/new_images_provider.dart';
import 'package:vnote/provider/parent_id_provider.dart';
import 'package:vnote/provider/token_provider.dart';
import 'package:vnote/widgets/markdown_text_input.dart';

class NoteEditPage extends StatefulWidget {
  final String markdownSource;
  final String id;
  final String name;

  NoteEditPage({Key key, String markdownSource, String id, String name})
      : this.markdownSource = markdownSource,
        this.id = id,
        this.name = name,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  String content;
  String oldContent;
  ProgressDialog pr;
  var changes = ChangeStack();
  var controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    content = widget.markdownSource;
  }

  @override
  Widget build(BuildContext context) {
    TokenModel tokenModel = Provider.of<TokenModel>(context, listen: false);
    pr = new ProgressDialog(context);
    pr.style(message: translate("updateContentTips"));

    return Scaffold(
      appBar: AppBar(
        title: Text(translate("edit.title")),
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
            icon: Icon(Icons.undo),
            onPressed: !changes.canUndo
                ? null
                : () {
                    //print("点击了撤销按钮");
                    if (mounted)
                      setState(() {
                        changes.undo();
                        //print("撤销之后的内容如下: ");
                        //print(content);
                        this.controller.text = content;
                      });
                  },
          ),
          IconButton(
            icon: Icon(Icons.redo),
            onPressed: !changes.canRedo
                ? null
                : () {
                    //print("点击的恢复按钮");
                    if (mounted)
                      setState(() {
                        changes.redo();
                        //print("恢复之后的内容如下: ");
                        //print(content);
                        this.controller.text = content;
                      });
                  },
          ),
          IconButton(
            icon: Icon(Icons.remove_red_eye),
            onPressed: () async {
              if (widget.markdownSource == content) {
                print("没有修改内容, 直接跳");
                Navigator.pop(context, content);
              } else {
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
                final _newImageList =
                    Provider.of<NewImageListProvider>(context, listen: false);
                final _imageFolderId =
                    Provider.of<ImageFolderIdProvider>(context, listen: false);
                ParentIdProvider parentIdModel =
                    Provider.of<ParentIdProvider>(context, listen: false);
                DataListProvider dataListModel =
                    Provider.of<DataListProvider>(context, listen: false);
                DirAndFileCacheProvider dirAndFileCacheModel =
                    Provider.of<DirAndFileCacheProvider>(context,
                        listen: false);
                // 本地增加的所有图片
                List<String> newImagesList = _newImageList.newImageList;

                // 本地新增了图片才上传, 不然上传个鸡儿
                // 如果没有_v_image , 记得新建这个目录
                if (newImagesList.length > 0) {
                  String imageFolderId = _imageFolderId.imageFolderId;

                  if (imageFolderId == "noimagefolder") {
                    print("没有 imagefolder 文件夹, 需要先创建 imageFolder 文件夹");

                    // 接下来是新建 _v_images 文件夹的过程???
                    await OneDriveDataDao.createFolder(
                            context,
                            tokenModel.token.accessToken,
                            "_v_images",
                            parentIdModel.parentId)
                        .then((data) {
                      print("更新本地 dataList");
                      Map<String, dynamic> jsonData =
                          jsonDecode(data.toString());
                      String id = jsonData["id"];
                      String newFolderName = jsonData["name"];
                      String dateString = jsonData['lastModifiedDateTime'];
                      DateTime date = DateTime.parse(dateString);
                      ConfigIdProvider configIdModel =
                          Provider.of<ConfigIdProvider>(context, listen: false);
                      Document doc = new Document(
                          id: id,
                          configId: configIdModel.configId,
                          name: newFolderName,
                          isFile: false,
                          dateModified: date);
                      dataListModel.addEle(doc);
                      dirAndFileCacheModel.addDirOrFileEle(
                          parentIdModel.parentId, doc);
                      print("接下来是更新这个 imageFolderId");
                      _imageFolderId.updateImageFolderId(id);
                      imageFolderId = _imageFolderId.imageFolderId;
                    });
                  }

                  int repeatCount = 10; // 重复上传 10 次
                  ProgressDialog uploadPR;
                  uploadPR = new ProgressDialog(context,
                      type: ProgressDialogType.Download, isDismissible: false);
                  uploadPR.style(
                      message: translate("uploadTips"),
                      progress: 0.0,
                      maxProgress:
                          double.parse(newImagesList.length.toString()));

                  await uploadPR.show();
                  print("需要处理的图片: " + newImagesList.length.toString());

                  // 调用接口上传, 上传成功后再替换
                  print("本文章中新增加的图片如下: ");
                  for (int i = 0; i < newImagesList.length; i++) {
                    print(newImagesList[i]);
                    var fileData =
                        await MultipartFile.fromFile(newImagesList[i]);

                    print("文件名: " + fileData.filename);
                    print("文件长度: " + fileData.length.toString());
                    print("_v_images的 id: " + imageFolderId);

                    //await uploadPR.hide();
                    await uploadPR.hide().then((isHidden) async {
                      print("关闭旧的进度框?");
                      print(isHidden);
                      if (!isHidden) {
                        Navigator.of(context).pop();
                      }
                    });
                    uploadPR = new ProgressDialog(context,
                        type: ProgressDialogType.Download,
                        isDismissible: false);
                    uploadPR.style(
                      message: translate("uploadingTips"),
                      progress: double.parse((i + 1).toString()),
                      maxProgress:
                          double.parse(newImagesList.length.toString()),
                    );
                    await uploadPR.show();

                    FormData formData = FormData.fromMap({"file": fileData});

                    await OneDriveDataDao.uploadFile(
                            context,
                            tokenModel.token.accessToken,
                            imageFolderId,
                            formData,
                            fileData.filename)
                        .then((value) {
                      if (value == null) {
                        print("没有数据, 应该上传失败了");

                        if (repeatCount > 0) {
                          Fluttertoast.showToast(
                              msg: "上传失败了! 重试! 还剩 " +
                                  repeatCount.toString() +
                                  " 次",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 3,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          print("重试还剩: " + repeatCount.toString() + " 次");
                          i--; // 减少 1, 让它重新操作
                          repeatCount--;
                        } else {
                          print("已经重试 10 次, 他妈的不管了");
                          Fluttertoast.showToast(
                              msg: "已经重试 10 次, 他妈的不管了!",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 3,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          repeatCount = 10; // 重置

                          print("处理完: " + fileData.filename);
                        }
                      } else {
                        t_content = t_content.replaceAll(
                            newImagesList[i], "_v_images/" + fileData.filename);

                        print("处理完: " + fileData.filename);
                        repeatCount = 10; // 重置
                      }
                    });
                  }

                  // 上传完关闭进度框
                  //uploadPR.hide();
                  await uploadPR.hide().then((isHidden) async {
                    print("关闭进度框?");
                    print(isHidden);
                    if (!isHidden) {
                      Navigator.of(context).pop();
                    }
                  });
                  // 记得要清空
                  _newImageList.clearList();
                }
                // 显示更新进度条
                await pr.show().then((_) async {
                  // 替换那些已经有的
                  t_content = t_content.replaceAll(image_path, "_v_images");
                  await OneDriveDataDao.updateContent(context,
                          tokenModel.token.accessToken, widget.id, t_content)
                      .then((_) {
                    // 3. 应该在这里更新 _vnote.json 文件
                  }).then((_) async {
                    print("到此更新完了, 可以跳转了!");
                    await pr.hide().then((isHidden) async {
                      print("到此更新完了, 可以跳转了! dialog killed ?");
                      print(isHidden);
                      if (!isHidden) {
                        Navigator.of(context).pop();
                      }
                    });
                    Navigator.pop(context, content);
                  });
                });
              }
            },
          ),
        ],
      ),
      body: MarkdownTextInput(
        controller,
        (String value) {
          setState(() {
            oldContent = content;
            content = value;
            if (mounted && oldContent != content) {
              print("提交");
              changes.add(new Change(
                oldContent,
                () => content = value,
                (oldContent) => content = oldContent,
              ));
              //changes.commit();
            }
          });
        },
        content,
        label: translate("edit.contentTips"),
      ),
    );
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
                    Navigator.pop(context, widget.markdownSource);
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
