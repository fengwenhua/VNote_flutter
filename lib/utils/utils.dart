import 'package:meta/meta.dart';

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

  /// 获取文章中的图片链接, 返回所有图片的名字
  static List<String> getMDImages(String value){
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
}