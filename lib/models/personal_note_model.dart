class PersonalNoteModel {
  List<Files> files;

  PersonalNoteModel({this.files});

  PersonalNoteModel.fromJson(Map<String, dynamic> json) {
    if (json['files'] != null) {
      files = new List<Files>();
      json['files'].forEach((v) {
        files.add(new Files.fromJson(v));
      });
    }
  }
  void addNewFile(Map<String, dynamic> json) {
    this.files.add(new Files.fromJson(json));
  }

  void delFile(String name) {
    this.files.removeWhere((f) => f.name == name);
  }

  void renameFile(String oldName, String newName) {
    List<Files> newList = this.files.map((f) {
      if (f.name == oldName) {
        print("在 _myNote.json 中给文件赋值");
        f.name = newName;
      }
      return f;
    }).toList();
    this.files = newList;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.files != null) {
      data['files'] = this.files.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Files {
  String id;
  String modifiedTime;
  String name;

  Files({this.id, this.modifiedTime, this.name});

  Files.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    modifiedTime = json['modified_time'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['modified_time'] = this.modifiedTime;
    data['name'] = this.name;
    return data;
  }
}
