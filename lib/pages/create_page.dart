import 'dart:convert';
import 'package:dio/dio.dart';
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
import 'package:vnote/models/personal_note_model.dart';
import 'package:vnote/provider/config_id_model.dart';
import 'package:vnote/provider/data_list_model.dart';
import 'package:vnote/provider/dir_and_file_cache_model.dart';
import 'package:vnote/provider/image_folder_id_model.dart';
import 'package:vnote/provider/local_document_provider.dart';
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
  var controller = TextEditingController();

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
              if (fileName == null && content == null) {
                Navigator.of(context).pop();
              } else {
                showAlertDialog(context);
              }
            },
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.remove_red_eye),
                color: Colors.white,
                onPressed: () async {
                  print("点击预览, 准备保存新文件");
                  if (fileId != null) {
                    print("如果有 id, 说明已经存过了, 接下来是更新操作即可!");
                  } else {
                    print("没有 id, 说明没有存过, 接下来是保存新文件的操作!");
                    // 文件名和内容至少一个才继续下去
                    if (fileName != null || content != null) {
                      // put 请求
                      // dataList dirCache
                      // json
                      if (fileName == null) {
                        fileName = "untitled";
                      }
                      fileName = fileName.trim();
                      if (content == null) {
                        content = "";
                      }
                      content = content.trim();

                      if (!fileName.contains(".md")) {
                        fileName += ".md";
                      }
                      // 去掉前后空格
                      fileName = fileName.trim();
                      content = content.trim();
                      //pr.update(message: "开始创建...");
                      Utils.showMyToast("上传内容到 onedrive 中...");
                      await pr.show().then((_) async {
                        // 应该先找图片

                        // 本地增加的所有图片
                        List<String> newImagesList = _newImageList.newImageList;
                        ProgressDialog uploadPR;
                        String t_content = content;
                        String image_path =
                            Application.sp.getString("appImagePath");
                        // 本地新增了图片才上传, 不然上传个鸡儿
                        // 如果没有_v_image , 记得新建这个目录
                        bool needToUpdateImageFolderId = true;
                        if (newImagesList.length > 0) {
                          print("create_page 本地新增加了图片!");
                          String imageFolderId;

                          // 对于新建文件来说, 需要在这里遍历 dataList, 更新 imageFolderId
                          for (Document d in dataListModel.dataList) {
                            if (d.name == "_v_images") {
                              print("这是当前目录的 imageFolderId");
                              print(d.id);
                              _imageFolderId.updateImageFolderId(d.id);
                              imageFolderId = _imageFolderId.imageFolderId;
                            }
                          }

                          print("create_page 当前的 imageFolderId: ");
                          print(imageFolderId);
                          if (imageFolderId == "noimagefolder" ||
                              imageFolderId == null) {
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
                              String dateString =
                                  jsonData['lastModifiedDateTime'];
                              DateTime date = DateTime.parse(dateString);
                              ConfigIdModel configIdModel =
                                  Provider.of<ConfigIdModel>(context,
                                      listen: false);
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
                              needToUpdateImageFolderId = false;
                              imageFolderId = _imageFolderId.imageFolderId;
                            });
                          }

                          int repeatCount = 10; // 重复上传 10 次

                          uploadPR = new ProgressDialog(context,
                              type: ProgressDialogType.Download,
                              isDismissible: true);
                          uploadPR.style(
                              message: translate("uploadTips"),
                              borderRadius: 10.0,
                              progressWidget: CircularProgressIndicator(),
                              elevation: 10.0,
                              insetAnimCurve: Curves.easeInOut,
                              progress: 0.0,
                              maxProgress: 100.0,
                              progressTextStyle: TextStyle(
                                  fontSize: 13.0, fontWeight: FontWeight.w400),
                              messageTextStyle: TextStyle(
                                  fontSize: 19.0, fontWeight: FontWeight.w600));

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

                            await uploadPR.hide();
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

                            FormData formData =
                                FormData.fromMap({"file": fileData});

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
                                  print(
                                      "重试还剩: " + repeatCount.toString() + " 次");
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
                                    newImagesList[i],
                                    "_v_images/" + fileData.filename);

                                print("处理完: " + fileData.filename);
                                repeatCount = 10; // 重置

                              }
                            });
                          }
                        }

                        if (uploadPR != null && uploadPR.isShowing()) {
                          // 上传完关闭进度框
                          uploadPR.hide();
                        }
                        // 记得要清空
                        _newImageList.clearList();
                        print("新建一个进度对话框!");
                        uploadPR = new ProgressDialog(context,
                            type: ProgressDialogType.Normal,
                            isDismissible: true);
                        uploadPR.style(message: translate("uploadTips"));
                        await uploadPR.show();
                        t_content =
                            t_content.replaceAll(image_path, "_v_images");
                        await OneDriveDataDao.uploadFile(
                                context,
                                tokenModel.token.accessToken,
                                parentIdModel.parentId,
                                t_content,
                                fileName)
                            .then((value) async {
                          print("上传 $fileName 文件之后返回的内容" + value.toString());
                          // 更新本地数据
                          Map<String, dynamic> jsonData =
                              jsonDecode(value.toString());
                          String id = jsonData["id"];
                          fileId = id;
                          String configId = configIdModel.configId;
                          String newFileName = jsonData["name"];
                          String dateString = jsonData['lastModifiedDateTime'];
                          DateTime date = DateTime.parse(dateString);
                          print("要添加进去的 Document 的 imageFolderId: ");
                          print(_imageFolderId.imageFolderId);
                          if (_imageFolderId.imageFolderId == null) {
                            print(
                                "这个笔记没有图片, 所以将 imageFolderId 的值赋值为 noimagefolder");
                            _imageFolderId.updateImageFolderId("noimagefolder");
                          }
                          Document doc = new Document(
                              id: id,
                              configId: configId,
                              imageFolderId: _imageFolderId.imageFolderId,
                              name: newFileName,
                              isFile: true,
                              dateModified: date);

                          dataListModel.addEle(doc);
                          dirAndFileCacheModel.addDirOrFileEle(
                              parentIdModel.parentId, doc);
                          // 下面是更新当前目录的 _vnote.json 文件
                          Utils.showMyToast("开始下载 _vnote.json");
                          //pr.update(message: "开始下载_vnote.json");
                          await uploadPR.hide();
                          uploadPR = new ProgressDialog(context,
                              type: ProgressDialogType.Normal,
                              isDismissible: true);
                          uploadPR.style(message: "开始下载 _vnote.json");
                          await uploadPR.show();
                          print(
                              "接下来开始下载当前目录下的 _vnote.json 文件, 然后更新它的 files 字段");
                          await OneDriveDataDao.getFileContent(context,
                                  tokenModel.token.accessToken, configId)
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
                            //pr.style(message: "开始更新 _vnote.json");
                            print("添加成功_vnote.json 之后, 就是更新这个文件");
                            await uploadPR.hide();

                            uploadPR = new ProgressDialog(context,
                                type: ProgressDialogType.Normal,
                                isDismissible: true);
                            uploadPR.style(message: "更新 _vnote.json");
                            await uploadPR.show();

                            Utils.showMyToast("更新 _vnote.json");
                            await OneDriveDataDao.updateContent(
                                    context,
                                    tokenModel.token.accessToken,
                                    configId,
                                    json.encode(desktopConfigModel))
                                .then((value) async {
                              if (value != null) {
                                print("_vnote.json 更新成功");
                                await uploadPR.hide();
                              }
                            });
                          });
                        });
                      }).then((_) async {
                        await pr.hide();
                        print("新建后将内容存入本地");
                        Application.sp.setString(fileId, content);

                        PersonalNoteModel personalNoteModel =
                            await Utils.getPersonalNoteModel();

                        ConfigIdModel configIdModel =
                            Provider.of<ConfigIdModel>(context, listen: false);
                        print("要写进_myNote.json 的 imageFolderId是: ");
                        print(_imageFolderId.imageFolderId);
                        Map<String, dynamic> newFileMap = jsonDecode(
                            Utils.newLocalFileJson(
                                fileId,
                                configIdModel.configId,
                                _imageFolderId.imageFolderId,
                                fileName));
                        print("这个 Map 的 imageFolderId 是:");
                        print(newFileMap['image_folder_id']);
                        personalNoteModel.addNewFile(newFileMap);
                        LocalDocumentProvider localDocumentProvider =
                            Provider.of<LocalDocumentProvider>(context,
                                listen: false);

                        Utils.writeModelToFile(personalNoteModel);
                        await Utils.model2ListDocument().then((data) {
                          print("create_page 这里拿到 _myNote.json 的数据");
                          localDocumentProvider.updateList(data);
                        });

                        // 搞完进入预览页面, 销毁本页面
//                        String route =
//                            '/preview?content=${Uri.encodeComponent(content)}&id=${Uri.encodeComponent(fileId)}&name=${Uri.encodeComponent(fileName)}&configId=${Uri.encodeComponent(configIdModel.configId)}&imageFolderId=${Uri.encodeComponent(_imageFolderId.imageFolderId)}';
//                        Application.router
//                            .navigateTo(context, route,
//                                transition: TransitionType.fadeIn)
//                            .then((result) {
//                          print("搞定直接滚");
//                          Navigator.of(context).pop();
//                        });

                        await Utils.getMarkdownHtml(
                                fileName, Application.sp.getString(fileId))
                            .then((data) {
                          String route =
                              '/markdownWebView?content=${Uri.encodeComponent(data.toString())}&title=${Uri.encodeComponent(fileName)}&id=${Uri.encodeComponent(fileId)}&configId=${Uri.encodeComponent(configIdModel.configId)}&imageFolderId=${Uri.encodeComponent(_imageFolderId.imageFolderId)}';
                          Application.router
                              .navigateTo(context, route,
                                  transition: TransitionType.fadeIn)
                              .then((result) {
                            print("搞定直接滚");
                            Navigator.of(context).pop();
                          });
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
                controller,
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
