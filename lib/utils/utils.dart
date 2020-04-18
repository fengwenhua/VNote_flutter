import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vnote/application.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/models/personal_note_model.dart';

class Utils {
  static String getFormattedDateTime({@required DateTime dateTime}) {
    String day = '${dateTime.day}';
    String month = '${dateTime.month}';
    String year = '${dateTime.year}';

    String hour = '${dateTime.hour}';
    String minute = '${dateTime.minute}';
    String second = '${dateTime.second}';
    return '$day/$month/$year $hour/$minute/$second';
  }

  static String getFormattedDateTimeForJson({@required DateTime dateTime}) {
    String day = '${dateTime.day}';
    if(int.parse(day)<10){
      day = '0${dateTime.day}';
    }
    String month = '${dateTime.month}';
    if(int.parse(month)<10){
      month = '0${dateTime.month}';
    }
    String year = '${dateTime.year}';

    String hour = '${dateTime.hour}';
    if(int.parse(hour)<10){
      hour = '0${dateTime.hour}';
    }
    String minute = '${dateTime.minute}';
    if(int.parse(minute)<10){
      minute = '0${dateTime.minute}';
    }
    String second = '${dateTime.second}';
    if(int.parse(second)<10){
      second = '0${dateTime.second}';
    }
    return '$year-$month-${day}T$hour:$minute:${second}Z';
  }

  /// [newFolderJson] 用于新建空目录时, 返回需要在该目录里面生成的 _vnote.json 文件内容.
  static String newFolderJson() {
    String time = Utils.getFormattedDateTimeForJson(dateTime: DateTime.now());
    String jsonData = '''{
    "created_time": "$time",
    "files": [
    ],
    "sub_directories": [
    ],
    "version": "1"
}
    ''';
    return jsonData;
  }

  /// 用于点击文件的时候, 记录该内容到 _myNote.json
  static String newLocalFileJson(String id, String configId, String fileName) {
    String time = Utils.getFormattedDateTimeForJson(dateTime: DateTime.now());
    String jsonData = '''{
    "id":"$id",
    "config_id":"$configId",
    "name":"$fileName",
    "modified_time":"$time"
}''';
    return jsonData;
  }

  /// [newFileJson] 用于新建文件时, 返回_vnote.json 所需要的内容
  static String newFileJson(String fileName) {
    String time = Utils.getFormattedDateTimeForJson(dateTime: DateTime.now());
    String jsonData = '''        {
            "attachment_folder": "",
            "attachments": [
            ],
            "created_time": "$time",
            "modified_time": "$time",
            "name": "$fileName",
            "tags": [
            ]
        }''';
    return jsonData;
  }

  /// 获取文章中的图片链接, 返回所有图片的名字
  static List<String> getMDImages(String value) {
    RegExp reg = new RegExp(r"!\[.*?\]\((.*?)\)");

    /// 正则匹配所有图片
    //调用allMatches函数，对字符串应用正则表达式
    //返回包含所有匹配的迭代器
    Iterable<Match> matches = reg.allMatches(value);
    // 存放所有图片的名字
    List<String> imageUrls = [];
    print("解析文章中的图片链接如下: ");
    String matchString = "";
    for (Match m in matches) {
      //groupCount返回正则表达式的分组数
      //由于group(0)保存了匹配信息，因此字符串的总长度为：分组数+1
      matchString = m.group(1);
      print(matchString);
      if (matchString.contains("_v_images")) {
        imageUrls.add(matchString.split("/")[1]);
      } else {
        continue;
      }
    }
    return imageUrls;
  }

  static Future<void> setImageFolder() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    String appImagePath = appDocPath + '/image';
    print("设置图片文件夹: " + appImagePath);
    Application.sp.setString("appImagePath", appImagePath);
  }

  static Future<void> deleteTemp() async {
    final cacheDir = await getTemporaryDirectory();
    print("tempDir 大小: " + cacheDir.statSync().size.toString());
    final file = File(cacheDir.path);
    final isExists = await file.exists();
    if (isExists) {
      await file.delete(recursive: true);
    }
  }

  static Future<void> deleteAppSupport() async {
    final appDir = await getApplicationSupportDirectory();
    print("appSupport 大小: " + appDir.statSync().size.toString());
    final file = File(appDir.path);
    final isExists = await file.exists();
    if (isExists) {
      await file.delete(recursive: true);
    }
  }

  static Future<void> deleteAppDoc() async {
    final appDir = await getApplicationDocumentsDirectory();
    print("appDoc 大小: " + appDir.statSync().size.toString());
    final file = File(appDir.path);
    final isExists = await file.exists();
    if (isExists) {
      await file.delete(recursive: true);
    }
  }

  /// 获取 _myNote.json 文件
  static Future<File> loadPersonalNoteConfig() async {
    var appDocDir = await getApplicationDocumentsDirectory();
    //或者file对象（操作文件记得导入import 'dart:io'）
    return new File('${appDocDir.path}/_myNote.json');
  }

  /// 将 _myNote.json 数据, 转成 model
  static getPersonalNoteModel() async {
    try {
      // 打开文件
      print("打开文件");
      final file = await loadPersonalNoteConfig();
      // 读成 String
      //print("读成 String");
      String jsonDataStr;
      try {
        jsonDataStr = await file.readAsString();
      } catch (e) {
        print("有异常, 说明文件没有内容, 先写内容");
        var t = '{"files":[]}';
        file.writeAsString(t);
      }

      if (jsonDataStr == "" || jsonDataStr == null) {
        print("_myNote.json 文件里内容为空");
        jsonDataStr = '{"files":[]}';
        file.writeAsString(jsonDataStr);
      }
      // 转成 json
      print(jsonDataStr);
      //print("转成 json");
      Map<String, dynamic> json = jsonDecode(jsonDataStr);
      // json 转成实体类
      //print("转成 model");
      PersonalNoteModel personalNoteModel = PersonalNoteModel.fromJson(json);
      return personalNoteModel;
    } catch (err) {
      print(err);
    }
  }

  /// 将 PersonalNoteModel 转换成 List<Document>
  static model2ListDocument() async {
    List<Document> result = new List<Document>();
    PersonalNoteModel personalNoteModel = await getPersonalNoteModel();
    if (personalNoteModel.files == null) {
      print("本地没有笔记缓存");
      return null;
    }
    print("本地有笔记缓存");
    for (Files file in personalNoteModel.files) {
      //print("这个时间是: " + file.modifiedTime.toString());
      Document temp = new Document(
          id: file.id,
          configId: file.configId,
          name: file.name,
          isFile: true,
          dateModified: DateTime.parse(file.modifiedTime));
      result.add(temp);
    }
    return result;
  }

  // 将 model 转换成 json 写入 _myNote.json
  static writeModelToFile(PersonalNoteModel personalNoteModel) async {
    try {
      final file = await loadPersonalNoteConfig();
      print("写进 _myNote.json 的内容是: ");
      print(json.encode(personalNoteModel));
      return file.writeAsString(json.encode(personalNoteModel)); // 这是覆盖, 还是附加?
    } catch (err) {
      print(err);
    }
  }

  static showMyToast(String text){
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
