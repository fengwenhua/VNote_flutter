# vnote

A Flutter application for VNote.

## 为了加速

修改 修改Flutter SDK包下的flutter.gradle文件, 如我的目录是: ``/Users/hua/flutter/packages/flutter_tools/gradle/flutter.gradle`

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