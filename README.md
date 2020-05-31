# vnote

用 Flutter 写的 Android 移动端!

## 为了能够正常下载图片
`dio` 要修改`form_data.dart`, 才能成功上传, 可以通过点击如下图来找到`form_data.dart`

![](https://gitee.com/fengwenhua/ImageBed/raw/master/1590918605_20200531175002355_1595626590.png)

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

## build 报错了
运行flutter 构建时，长时间卡在`Running Gradle task 'assembleDebug'...`

```bash
flutter build apk -v
```

build 了很久没有反应, 最后报错大概如下:

```info
[+104793 ms] FAILURE: Build failed with an exception.
[   +3 ms] * What went wrong:
[        ] Could not determine the dependencies of task ':app:lintVitalRelease'.
[        ] > Could not resolve all artifacts for configuration ':app:debugCompileClasspath'.
[   +1 ms]    > Could not download armeabi_v7a_debug.jar (io.flutter:armeabi_v7a_debug:1.0.0-540786dd51f112885a89792d678296b95e6622e5)
[        ]       > Could not get resource 'https://storage.googleapis.com/download.flutter.io/io/flutter/armeabi_v7a_debug/1.0.0-540786dd51f112885a89792d678296b95e6622e5/armeabi_v7a_debug-1.0.0-540786dd51f112885a89792d678296b95e6622e5.jar'.
[        ]          > Could not GET 'https://storage.googleapis.com/download.flutter.io/io/flutter/armeabi_v7a_debug/1.0.0-540786dd51f112885a89792d678296b95e6622e5/armeabi_v7a_debug-1.0.0-540786dd51f112885a89792d678296b95e6622e5.jar'.
[        ]             > Connect to storage.googleapis.com:443 [storage.googleapis.com/34.64.4.16] failed: Read timed out
[        ]    > Could not download arm64_v8a_debug.jar (io.flutter:arm64_v8a_debug:1.0.0-540786dd51f112885a89792d678296b95e6622e5)
[   +1 ms]       > Could not get resource 'https://storage.googleapis.com/download.flutter.io/io/flutter/arm64_v8a_debug/1.0.0-540786dd51f112885a89792d678296b95e6622e5/arm64_v8a_debug-1.0.0-540786dd51f112885a89792d678296b95e6622e5.jar'.
[        ]          > Could not GET 'https://storage.googleapis.com/download.flutter.io/io/flutter/arm64_v8a_debug/1.0.0-540786dd51f112885a89792d678296b95e6622e5/arm64_v8a_debug-1.0.0-540786dd51f112885a89792d678296b95e6622e5.jar'.
[        ]             > Connect to storage.googleapis.com:443 [storage.googleapis.com/34.64.4.16] failed: Read timed out
[        ] * Try:
[        ] Run with --stacktrace option to get the stack trace. Run with --info or --debug option to get more log output. Run with --scan to get full insights.
[        ] * Get more help at https://help.gradle.org
[        ] BUILD FAILED in 1m 51s
```

### 方法 1
运行时会卡在`Running 'gradle assembleDebug`, 因为Gradle的Maven仓库在国外, 可以使用阿里云的镜像地址

修改`android`下的`build.gradle`如下:

```gradle
maven { url 'https://maven.aliyun.com/repository/google' }
maven { url 'https://maven.aliyun.com/repository/jcenter' }
maven { url 'https://maven.aliyun.com/nexus/content/groups/public' }
```

![](https://gitee.com/fengwenhua/ImageBed/raw/master/1590277396_20200524073835701_471869241.png)

修改Flutter SDK包下的`flutter.gradle`文件, 如我的目录是: `/Users/hua/flutter/packages/flutter_tools/gradle/flutter.gradle`

将

```gradle
repositories{
    google()
    gcenter()
}
```

改成

```gradle
maven { url 'https://maven.aliyun.com/repository/google' }
maven { url 'https://maven.aliyun.com/repository/jcenter' }
maven { url 'https://maven.aliyun.com/nexus/content/groups/public' }
```

![](https://gitee.com/fengwenhua/ImageBed/raw/master/1590277395_20200524073749564_744562330.png)

### 方法2
使用方法 1 还是解决不了, 请继续往下看.

> 解决地址: https://stackoverflow.com/questions/5991194/gradle-proxy-configuration

添加如下到`gradle.properties`, 其中`1087`是我的 v2ray http 监听端口. Android Studio 不用设置代理, 设置了也没用...

```properties
systemProp.http.proxyHost=127.0.0.1
systemProp.http.proxyPort=1087
systemProp.https.proxyHost=127.0.0.1
systemProp.https.proxyPort=1087
```

![](https://gitee.com/fengwenhua/ImageBed/raw/master/1590277392_20200524072644755_579676049.png)