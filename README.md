# vnote

A Flutter application for VNote.

## 为了能够正常下载图片
`dio` 要修改`form_data.dart`, 才能成功上传

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'multipart_file.dart';
import 'utils.dart';

/// A class to create readable "multipart/form-data" streams.
/// It can be used to submit forms and file uploads to http server.
class FormData {
  static const String _BOUNDARY_PRE_TAG = '--dio-boundary-';
  static const _BOUNDARY_LENGTH = _BOUNDARY_PRE_TAG.length + 10;

  /// The boundary of FormData, it consists of a constant prefix and a random
  /// postfix to assure the the boundary unpredictable and unique, each FormData
  /// instance will be different. And you can custom it by yourself.
  String _boundary;

  String get boundary => _boundary;

  final _newlineRegExp = RegExp(r'\r\n|\r|\n');

  /// The form fields to send for this request.
  final fields = <MapEntry<String, String>>[];

  /// The [files].
  final files = <MapEntry<String, MultipartFile>>[];

  /// Whether [finalize] has been called.
  bool get isFinalized => _isFinalized;
  bool _isFinalized = false;

  FormData() {
    _init();
  }

  /// Create FormData instance with a Map.
  FormData.fromMap(Map<String, dynamic> map) {
    _init();
    encodeMap(
      map,
      (key, value) {
        if (value == null) return null;
        if (value is MultipartFile) {
          files.add(MapEntry(key, value));
        } else {
          fields.add(MapEntry(key, value.toString()));
        }
        return null;
      },
      encode: false,
    );
  }

  void _init() {
    // Assure the boundary unpredictable and unique
    var random = Random();
    _boundary = _BOUNDARY_PRE_TAG +
        random.nextInt(4294967296).toString().padLeft(10, '0');
  }

  /// Returns the header string for a field. The return value is guaranteed to
  /// contain only ASCII characters.
  String _headerForField(String name, String value) {
    var header =
        'content-disposition: form-data; name="${_browserEncode(name)}"';
    if (!isPlainAscii(value)) {
      header = '$header\r\n'
          'content-type: text/plain; charset=utf-8\r\n'
          'content-transfer-encoding: binary';
    }
    return '$header\r\n\r\n';
  }

  /// Returns the header string for a file. The return value is guaranteed to
  /// contain only ASCII characters.
  String _headerForFile(MapEntry<String, MultipartFile> entry) {
    var file = entry.value;
    var header =
        'content-disposition: form-data; name="${_browserEncode(entry.key)}"';
    if (file.filename != null) {
      header = '$header; filename="${_browserEncode(file.filename)}"';
    }
    header = '$header\r\n'
        'content-type: ${file.contentType}';
    return '$header\r\n\r\n';
  }

  /// Encode [value] in the same way browsers do.
  String _browserEncode(String value) {
    // http://tools.ietf.org/html/rfc2388 mandates some complex encodings for
    // field names and file names, but in practice user agents seem not to
    // follow this at all. Instead, they URL-encode `\r`, `\n`, and `\r\n` as
    // `\r\n`; URL-encode `"`; and do nothing else (even for `%` or non-ASCII
    // characters). We follow their behavior.
    return value.replaceAll(_newlineRegExp, '%0D%0A').replaceAll('"', '%22');
  }

  /// The total length of the request body, in bytes. This is calculated from
  /// [fields] and [files] and cannot be set manually.
  int get length {
    var length = 0;
    for (var file in files) {
      length +=
          file.value.length;
    }

    return length;
  }

  Stream<List<int>> finalize() {
    if (isFinalized) {
      throw StateError("Can't finalize a finalized MultipartFile.");
    }
    _isFinalized = true;
    var controller = StreamController<List<int>>(sync: false);
    void writeAscii(String string) {
      controller.add(utf8.encode(string));
    }

    void writeUtf8(String string) => controller.add(utf8.encode(string));
    void writeLine() => controller.add([13, 10]); // \r\n

//    fields.forEach((entry) {
//      writeAscii('--$boundary\r\n');
//      writeAscii(_headerForField(entry.key, entry.value));
//      writeUtf8(entry.value);
//      writeLine();
//    });

    Future.forEach(files, (file) {
      //writeAscii('--$boundary\r\n');
      //writeAscii(_headerForFile(file));
      return writeStreamToSink(file.value.finalize(), controller)
          ;
    }).then((_) {
      //writeAscii('--$boundary--\r\n');
      controller.close();
    });
    return controller.stream;
  }

  ///Transform the entire FormData contents as a list of bytes asynchronously.
  Future<List<int>> readAsBytes() {
    return finalize().reduce((a, b) => [...a, ...b]);
  }
}
```

## 为了 android 部署加速

修改 修改Flutter SDK包下的flutter.gradle文件, 如我的目录是: /Users/hua/flutter/packages/flutter_tools/gradle/flutter.gradle`

将

```
repositories{
    google()
    gcenter()
}
```

改成

```
maven { url 'https://maven.aliyun.com/repository/google' }
maven { url 'https://maven.aliyun.com/repository/jcenter' }
maven { url 'http://maven.aliyun.com/nexus/content/groups/public' }
```