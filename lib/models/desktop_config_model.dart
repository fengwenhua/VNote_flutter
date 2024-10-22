/// [DesktopConfigModel] 用于解析 _vnote.json 的内容
class DesktopConfigModel {
  String createdTime;
  List<Files> files;
  List<SubDirectories> subDirectories;
  String version;

  DesktopConfigModel(
      {this.createdTime, this.files, this.subDirectories, this.version});

  /// [addNewFile] 用于给 file 的字段新增内容
  void addNewFile(Map<String, dynamic> json) {
    this.files.add(new Files.fromJson(json));
  }

  /// [delFile] 根据 [name] 删除 file 的字段
  void delFile(String name) {
    this.files.removeWhere((f) => f.name == name);
  }

  /// [renameFile] 根据 [oldName] 和 [newName] 重命名 file 的字段
  void renameFile(String oldName, String newName) {
    List<Files> newList = this.files.map((f) {
      if (f.name == oldName) {
        print("在 _vnote.json 中给文件赋值");
        f.name = newName;
      }
      return f;
    }).toList();
    this.files = newList;
  }

  /// [addNewFolder] 用于新增 subdirectories 的字段
  void addNewFolder(Map<String, dynamic> json) {
    //print("添加进入的是: " + json['name']);
    this.subDirectories.add(new SubDirectories.fromJson(json));
  }

  /// [deleteFolder] 根据 [name] 删除 subdirectories 的字段
  void deleteFolder(String name) {
    this.subDirectories.removeWhere((s) => s.name == name);
  }

  /// [renameFolder] 根据 [oldName] 和 [newName] 重命名 subdirectories 的字段
  void renameFolder(String oldName, String newName) {
    List<SubDirectories> newList = this.subDirectories.map((f) {
      if (f.name == oldName) {
        print("在 _vnote.json 中给目录赋值");
        f.name = newName;
      }
      return f;
    }).toList();
    this.subDirectories = newList;
  }

  DesktopConfigModel.fromJson(Map<String, dynamic> json) {
    createdTime = json['created_time'];
    if (json['files'] != null) {
      files = new List<Files>();
      json['files'].forEach((v) {
        files.add(new Files.fromJson(v));
      });
    }
    if (json['sub_directories'] != null) {
      subDirectories = new List<SubDirectories>();
      json['sub_directories'].forEach((v) {
        subDirectories.add(new SubDirectories.fromJson(v));
      });
    }
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['created_time'] = this.createdTime;
    if (this.files != null) {
      data['files'] = this.files.map((v) => v.toJson()).toList();
    }
    if (this.subDirectories != null) {
      data['sub_directories'] =
          this.subDirectories.map((v) => v.toJson()).toList();
    }
    data['version'] = this.version;
    return data;
  }
}

class Files {
  String attachmentFolder;
  List<Attachments> attachments;
  String createdTime;
  String modifiedTime;
  String name;
  List<String> tags;

  Files(
      {this.attachmentFolder,
      this.attachments,
      this.createdTime,
      this.modifiedTime,
      this.name,
      this.tags});

  Files.fromJson(Map<String, dynamic> json) {
    attachmentFolder = json['attachment_folder'];
    if (json['attachments'] != null) {
      attachments = new List<Attachments>();
      json['attachments'].forEach((v) {
        attachments.add(new Attachments.fromJson(v));
      });
    }
    createdTime = json['created_time'];
    modifiedTime = json['modified_time'];
    name = json['name'];
    tags = json['tags'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['attachment_folder'] = this.attachmentFolder;
    if (this.attachments != null) {
      data['attachments'] = this.attachments.map((v) => v.toJson()).toList();
    }
    data['created_time'] = this.createdTime;
    data['modified_time'] = this.modifiedTime;
    data['name'] = this.name;
    data['tags'] = this.tags;
    return data;
  }
}

class Attachments {
  String name;

  Attachments({this.name});

  Attachments.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    return data;
  }
}

class SubDirectories {
  String name;

  SubDirectories({this.name});

  SubDirectories.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    //print("解析出来的名字为: " + name);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    return data;
  }
}
