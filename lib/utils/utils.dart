import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:vnote/application.dart';
import 'package:vnote/models/document_model.dart';
import 'package:vnote/models/personal_note_model.dart';
import 'package:vnote/provider/image_folder_id_provider.dart';

import 'global.dart';
import 'log_util.dart';

class Utils {
  static String getFormattedDateTime({@required DateTime dateTime}) {
    String day = '${dateTime.day}';
    String month = '${dateTime.month}';
    String year = '${dateTime.year}';

    String hour = '${dateTime.hour}';
    // 不知道为啥差八个小时, 这里加上
    hour = (int.parse(hour) + 8).toString();
    String minute = '${dateTime.minute}';
    String second = '${dateTime.second}';
    // 不显示时分秒了
    //  $hour:$minute:$second
    return '$year-$month-$day';
  }

  static String getFormattedDateTimeForJson({@required DateTime dateTime}) {
    String day = '${dateTime.day}';
    if (int.parse(day) < 10) {
      day = '0${dateTime.day}';
    }
    String month = '${dateTime.month}';
    if (int.parse(month) < 10) {
      month = '0${dateTime.month}';
    }
    String year = '${dateTime.year}';

    String hour = '${dateTime.hour}';
    if (int.parse(hour) < 10) {
      hour = '0${dateTime.hour}';
    }
    String minute = '${dateTime.minute}';
    if (int.parse(minute) < 10) {
      minute = '0${dateTime.minute}';
    }
    String second = '${dateTime.second}';
    if (int.parse(second) < 10) {
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
  static String newLocalFileJson(
      String id,
      String parentId,
      String parentName,
      String notebookId,
      String configId,
      String imageFolderId,
      String fileName) {
    String time = Utils.getFormattedDateTimeForJson(dateTime: DateTime.now());
    String jsonData = '''{
    "id":"$id",
    "parent_id":"$parentId",
    "parent_name":"$parentName",
    "notebook_id":"$notebookId",
    "config_id":"$configId",
    "image_folder_id":"$imageFolderId",
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

  // 获取文章中所有的本地图片
  // 替换成 base64
  // <img src="data:image/jpg;base64,  "/>
  static Future<String> getBase64Content(String content) async {
    RegExp reg = new RegExp(r"!\[.*?\]\((.*?)\)");

    Iterable<Match> matches = reg.allMatches(content);
    // 存放所有图片的名字
    List<String> imageUrls = [];
    List<String> entireImageUrls = [];
    //print("解析文章中的图片链接如下: ");
    String matchString = "";
    String entireMatchString = "";
    for (Match m in matches) {
      //groupCount返回正则表达式的分组数
      //由于group(0)保存了匹配信息，因此字符串的总长度为：分组数+1
      matchString = m.group(1);
      entireMatchString = m.group(0);
      if (matchString.contains("/image/")) {
        //print("添加进来");
        imageUrls.add(matchString);
        entireImageUrls.add(entireMatchString);
      } else {
        continue;
      }
    }
    for (int i = 0; i < imageUrls.length; i++) {
      await image2Base64(imageUrls[i]).then((data) {
        String newData = "";
        if (data == "") {
          print("返回来的图片打不开, 用占位图片替代!");
          newData = '<img  src="data:image/jpg;base64,$BROKEN_IMAGE"/>';
        } else {
          // 先不用 base64 的方式
          newData = '<img  src="data:image/jpg;base64,$data"/>';
          String path = imageUrls[i];
          //newData = "<img  src=\"$path\"/>";

        }

        // 这里替换
        //content = content.replaceAll(entireImageUrls[i], newData);
      });
    }

    return content;
  }

  /// 开局设置图片文件夹位置
  /// 如果文件夹不存在咋办?
  static Future<void> setImageFolder() async {
    Directory appDocDir;
    if (Platform.isIOS) {
      appDocDir = await getApplicationDocumentsDirectory();
    } else {
      appDocDir = await getApplicationSupportDirectory();
    }

    String appDocPath = appDocDir.path;
    String appImagePath = appDocPath + '/image';

    Directory directory = new Directory(appImagePath);
    try {
      bool exists = await directory.exists();
      if (!exists) {
        print("图片目录不存在 创建它");
        await directory.create(recursive: true);
      }
    } catch (e) {
      print(e);
    }

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
    print("model2ListDocument 本地有笔记缓存");
    for (Files file in personalNoteModel.files) {
      //print("这个时间是: " + file.modifiedTime.toString());
      print("读进来的名字和 imageFolderId");
      print(file.name);
      print(file.imageFolderId);
      Document temp = new Document(
          id: file.id,
          parentId: file.parentId,
          parentName: file.parentName,
          notebookId: file.notebookId,
          imageFolderId: file.imageFolderId,
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
      await file.writeAsString(json.encode(personalNoteModel)); // 这是覆盖, 还是附加?
    } catch (err) {
      print(err);
    }
  }

  static showMyToast(String text, {type = 1}) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: type == 1 ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static Future<String> loadJS(String name) async {
    var givenJS = rootBundle.loadString('assets/js/$name');
    return givenJS;
  }

  static Future<String> loadCss(String name) async {
    var cssFile = rootBundle.loadString('assets/styles/$name');
    return cssFile;
  }

  /// 根据[title]和[content]生成一个 html
  /// return 该 html 的路径
  static getMarkdownHtml(String title, String content) async {
    String markdown_it_js;
    String high_js;
    String footnote_js;
    String toc_js;
    String math_js;
    String htmlString;
    String cssString;
    await loadJS("highlight.min.js").then((data) {
      high_js = data;
      print("high_js 赋值了");
    });
    await loadJS("markdown-it.min.js").then((data) {
      markdown_it_js = data;
      print("markdown_it_js 赋值了");
    });
    await loadJS("markdown-it-footnote.min.js").then((data) {
      footnote_js = data;
      print("footnote_js 赋值了");
    });
    await loadJS("markdown-it-toc.min.js").then((data) {
      toc_js = data;
      print("toc_js 赋值了");
    });
    await loadCss("monokai.css").then((data) {
      cssString = data;
    });

    await loadJS("MathJax.js").then((data){
      math_js=data;
    });

    await getBase64Content(content).then((data) {
      content = data;
      print("替换成功!!!!");
    });

    htmlString = '''
  <!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>$title</title>
    <meta name="viewport" content="width=device-width,initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
    <script type="text/javascript">$markdown_it_js</script>
    <script type="text/javascript">$high_js</script>
    <script type="text/x-mathjax-config">
      MathJax.Hub.Config({tex2jax: {inlineMath: [['\$','\$'], ['\\\\(','\\\\)']]}});
    </script>
    <script type="text/javascript"
      src="https://cdn.bootcss.com/mathjax/2.7.1/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
    </script>
    
  <!--<script type="text/javascript">$math_js</script>-->
    <script type="text/javascript">$footnote_js</script>
    <script type="text/javascript">$toc_js</script>
     <style type="text/css">$cssString</style>
     <style type="text/css">img{max-width:100%;} </style>
    <script type="text/javascript">
    
function returnSource(){
  return document.documentElement.outerHTML;
}
// 初始化 markdownit
var md = window.markdownit({
    html:true,
    linkify:true,
    typographer:true,
  // markdown-it 高亮配置
  highlight: function (str, lang) {
      // 添加这两行才能正确显示 <>
    str = str.replace(/&lt;/g, "<");
    str = str.replace(/&gt;/g, ">");
    if (lang && hljs.getLanguage(lang)) {
      try {
        return '<pre class="hljs"><code>' +
          hljs.highlight(lang, str, true).value +
          '</code></pre>';
      } catch (__) { }
    }

    return '<pre class="hljs"><code>' + md.utils.escapeHtml(str) + '</code></pre>';
  }
}).use(window.markdownitFootnote)
.use(window.markdownitTOC);

    </script>
</head>

<body onload="mdSwitch()">
    <style>
    .markdown-here-wrapper {
        font-size: 16px;
        line-height: 1.8em;
        letter-spacing: 0.1em;
    }

    pre,
    code {
        font-size: 14px;
        font-family: Roboto, 'Courier New', Consolas, Inconsolata, Courier, monospace;
        margin: auto 5px;
    }

    code {
        white-space: pre-wrap;
        border-radius: 2px;
        display: inline;
    }

    pre {
        font-size: 15px;
        line-height: 1.4em;
        display: block;
         !important;
    }

    pre code {
        white-space: pre;
        overflow: auto;
        border-radius: 3px;
        padding: 1px 1px;
        display: block !important;
    }

    strong,
    b {
        color: #BF360C;
    }

    em,
    i {
        color: #009688;
    }

    hr {
        border: 1px solid #BF360C;
        margin: 1.5em auto;
    }

    p {
        margin: 1.5em 5px !important;
    }

    table,
    pre,
    dl,
    blockquote,
    q,
    ul,
    ol {
        margin: 10px 5px;
    }

    ul,
    ol {
        padding-left: 15px;
    }

    li {
        margin: 10px;
    }

    li p {
        margin: 10px 0 !important;
    }

    ul ul,
    ul ol,
    ol ul,
    ol ol {
        margin: 0;
        padding-left: 10px;
    }

    ul {
        list-style-type: circle;
    }

    dl {
        padding: 0;
    }

    dl dt {
        font-size: 1em;
        font-weight: bold;
        font-style: italic;
    }

    dl dd {
        margin: 0 0 10px;
        padding: 0 10px;
    }

    blockquote,
    q {
        border-left: 2px solid #009688;
        padding: 0 10px;
        color: #777;
        quotes: none;
        margin-left: 1em;
    }

    blockquote::before,
    blockquote::after,
    q::before,
    q::after {
        content: none;
    }

    h1,
    h2,
    h3,
    h4,
    h5,
    h6 {
        margin: 20px 0 10px;
        padding: 0;
        font-style: bold !important;
        color: #009688 !important;
        text-align: center !important;
        margin: 1.5em 5px !important;
        padding: 0.5em 1em !important;
    }

    h1 {
        font-size: 24px !important;
        border-bottom: 1px solid #ddd !important;
    }

    h2 {
        font-size: 20px !important;
        border-bottom: 1px solid #eee !important;
    }

    h3 {
        font-size: 18px;
    }

    h4 {
        font-size: 16px;
    }


    table {
        padding: 0;
        border-collapse: collapse;
        border-spacing: 0;
        font-size: 1em;
        font: inherit;
        border: 0;
        margin: 0 auto;
    }

    tbody {
        margin: 0;
        padding: 0;
        border: 0;
    }

    table tr {
        border: 0;
        border-top: 1px solid #CCC;
        background-color: white;
        margin: 0;
        padding: 0;
    }

    table tr:nth-child(2n) {
        background-color: #F8F8F8;
    }

    table tr th,
    table tr td {
        font-size: 16px;
        border: 1px solid #CCC;
        margin: 0;
        padding: 5px 10px;
    }

    table tr th {
        font-weight: bold;
        color: #eee;
        border: 1px solid #009688;
        background-color: #009688;
    }
    </style>
    <script>
    function mdSwitch() {
        var mdValue =  document.getElementById("md-area").value;
        var html = md.render(mdValue);
        document.getElementById("show-area").innerHTML = html;
    }
    </script>

    <textarea name="" id="md-area"  style="display:none;">$content</textarea>
    <div id="show-area" class="clearfix">
    </div>
    </body>

</html>
  ''';

    // 将这个 html 写到 document 下, 看看行不行
    print("尝试将内容写到 document 下的 index.html");
    Directory docsDir;
    if (Platform.isIOS) {
      docsDir = await getApplicationDocumentsDirectory();
    } else {
      docsDir = await getApplicationSupportDirectory();
      //docsDir = await getApplicationDocumentsDirectory();
    }

    String path = docsDir.path;
    String filename = 'index.html';
    File okFile = File('$path/image/$filename');
    await okFile.writeAsString(htmlString);
    print("写完了");
    //print(htmlString);
    print("file://$path/image/$filename");
    // 这里直接返回那个 html 的地址算了
    return "file://$path/image/$filename";
  }

  static Future image2Base64(String path) async {
    try {
      File file = new File(path);
      List<int> imageBytes = await file.readAsBytes();
      return base64Encode(imageBytes);
    } catch (e) {
      print("图片转换 base64 异常: " + e.toString());
      return "";
    }
  }
}
