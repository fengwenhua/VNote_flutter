import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:vnote/application.dart';
import 'package:vnote/provider/new_images_model.dart';

/// Use this class for converting String to [ResultMarkdown]
class FormatMarkdown {
  /// Convert [data] part into [ResultMarkdown] from [type].
  /// Use [fromIndex] and [toIndex] for converting part of [data]
  /// [titleSize] is used for markdown titles
  static Future<ResultMarkdown> convertToMarkdown(MarkdownType type,
      String data, int fromIndex, int toIndex, BuildContext context,
      {int titleSize = 1}) async {
    String changedData;
    int cursorIndex;

    switch (type) {
      case MarkdownType.bold:
        changedData = '**${data.substring(fromIndex, toIndex)}**';
        break;
      case MarkdownType.italic:
        changedData = '_${data.substring(fromIndex, toIndex)}_';
        break;
      case MarkdownType.link:
        changedData =
            '[${data.substring(fromIndex, toIndex)}](${data.substring(fromIndex, toIndex)})';
        break;
      case MarkdownType.photo:
        return await _showInputDialog(context).then((String res) {
          print("返回来的整体是: " + res);
          print("返回来的名字是: " + res.split("#####")[0]);
          print("返回来的路径是: " + res.split("#####")[1]);
          if (res.split("#####")[1] == "") {
            changedData = "";
          } else {
            changedData =
                '![${res.split("#####")[0]}](${res.split("#####")[1]})';
          }
          print("changeData 是: " + changedData);
          cursorIndex = changedData.length;
          return ResultMarkdown(
              data.substring(0, fromIndex) +
                  changedData +
                  data.substring(toIndex, data.length),
              cursorIndex);
        });
        break;
      case MarkdownType.quote:
        changedData = '>  ${data.substring(fromIndex, toIndex)}';
        break;
      case MarkdownType.code:
        changedData = '```\n${data.substring(fromIndex, toIndex)}```';
        break;
      case MarkdownType.title:
        changedData =
            "${"#" * titleSize} ${data.substring(fromIndex, toIndex)}";
        break;
      case MarkdownType.list:
        var index = 0;
        final splitedData = data.substring(fromIndex, toIndex).split('\n');
        changedData = splitedData.map((value) {
          index++;
          return index == splitedData.length ? '* $value' : '* $value\n';
        }).join();
        break;
    }
    if (fromIndex == toIndex) {
      if (type == MarkdownType.bold ||
          type == MarkdownType.quote ||
          type == MarkdownType.list ||
          type == MarkdownType.photo) {
        cursorIndex = 2;
      } else if (type == MarkdownType.title) {
        cursorIndex = titleSize + 1;
      } else if (type == MarkdownType.code || type == MarkdownType.link) {
        cursorIndex = 3;
      } else {
        cursorIndex = 1;
      }
    } else {
      cursorIndex = changedData.length;
    }

    return ResultMarkdown(
        data.substring(0, fromIndex) +
            changedData +
            data.substring(toIndex, data.length),
        cursorIndex);
  }
}

/// 图片控件
Widget _imageView(image) {
  if (image == null) {
    return Center(
      child: Text("NO PHOTO"),
    );
  } else {
    return Image.file(
      image,
    );
  }
}

enum Action { Ok, Cancel }

Future<String> _showInputDialog(BuildContext context) async {
  File _image;
  var _imgName = "";
  final action = await showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(translate("picDialog.title")),
          content:
              new StatefulBuilder(builder: (context, StateSetter setState) {
            return Card(
              elevation: 0.0,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        MaterialButton(
                          color: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () async {
                            try {
                              File image = await ImagePicker.pickImage(
                                  source: ImageSource.camera);
                              setState(() {
                                _image = image;
                              });
                            } catch (e) {
                              print("异常是: " + e.toString());
                              Fluttertoast.showToast(
                                  msg: translate(
                                      "permission.camera_access_denied"),
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              Future.delayed(Duration(seconds: 1), () {
                                print('延时1s执行');
                                openAppSettings();
                              });
                            }
                          },
                          child: Text(translate("picDialog.takePic")),
                        ),
                        MaterialButton(
                          color: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () async {
                            try {
                              File image = await ImagePicker.pickImage(
                                  source: ImageSource.gallery);
                              setState(() {
                                _image = image;
                              });
                            } catch (e) {
                              print("异常是: " + e.toString());
                              Fluttertoast.showToast(
                                  msg: translate(
                                      "permission.photo_access_denied"),
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);

                              Future.delayed(Duration(seconds: 1), () {
                                print('延时1s执行');
                                openAppSettings();
                              });
                            }
                          },
                          child: Text(translate("picDialog.selectPic")),
                        ),
                      ],
                    ),
                    TextField(
                      decoration: InputDecoration(
                          hintText: translate("picDialog.tips"),
                          filled: true,
                          fillColor: Colors.grey.shade50),
                      onChanged: (String value) {
                        print("输入内容是: " + value);
                        _imgName = value;
                      },
                    ),
                    _imageView(_image),
                  ],
                ),
              ),
            );
          }),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                print("取消图片");
                Navigator.pop(context, Action.Cancel);
              },
              child: Text(translate("picDialog.cancel")),
            ),
            CupertinoDialogAction(
              onPressed: () {
                print("确定图片");
                if (_image?.path != null) {
                  Navigator.pop(context, Action.Ok);
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text(translate("picDialog.ok")),
            ),
          ],
        );
      });
  switch (action) {
    case Action.Ok:
      String imgPath = Application.sp.getString("appImagePath");
      Directory directory = new Directory(imgPath);
      try {
        bool exists = await directory.exists();
        if (!exists) {
          print("图片目录不存在 创建它");
          await directory.create(recursive: true);
        }
      } catch (e) {
        print(e);
      }

      print("旧路径: " + _image.path);
      File file = new File(_image.path);
      String newName = new DateTime.now().millisecondsSinceEpoch.toString();

      if (_image.path.contains(".jpg")) {
        newName = newName + ".jpg";
      } else if (_image.path.contains(".png")) {
        newName = newName + ".png";
      } else if (_image.path.contains(".gif")) {
        newName = newName + ".gif";
      } else {
        print("不存在的后缀名??");
      }
      print("新名字: " + newName);
      // 重命名
      String newPath = imgPath + Platform.pathSeparator + newName;
      return await file.copy(newPath).then((_) {
        final _newImageList =
            Provider.of<NewImageListModel>(context, listen: false);
        _newImageList.addImage(newPath);

        var temp = _imgName.trim() + "#####" + newPath.trim();
        print("图片名和图片路径: " + temp);
        return temp;
      });

      break;
    case Action.Cancel:
      return "#####";
      break;
    default:
      return "#####";
      break;
  }
}

/// [ResultMarkdown] give you the converted [data] to markdown and the [cursorIndex]
class ResultMarkdown {
  /// String converted to mardown
  String data;

  /// cursor index just after the converted part in markdown
  int cursorIndex;

  /// Return [ResultMarkdown]
  ResultMarkdown(this.data, this.cursorIndex);
}

/// Represent markdown possible type to convert

enum MarkdownType {
  /// For **bold** text
  bold,

  /// For _italic_ text
  italic,

  /// For [link](https://flutter.dev)
  link,

  /// For # Title or ## Title or ### Title
  title,

  /// For :
  ///   * Item 1
  ///   * Item 2
  ///   * Item 3
  list,

  /// for:
  /// > 引用
  quote,

  code,

  photo,
}
