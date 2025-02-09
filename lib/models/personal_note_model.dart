/// [PersonalNoteModel] 类用于缓存笔记，将笔记必备的字段存入 json 文件. 解析 _myNote.sjon
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

  /// [checkDocument] 根据 [id] 检查这篇文章是否在 _myNote.json 文件中
  bool checkDocument(String id) {
    for (Files file in this.files) {
      if (file.id == id) {
        print("文章在 _myNote.json 中");
        return true;
      }
    }
    print("文章不在 _myNote.json 中");
    return false;
  }

  /// [addNewFile] 添加笔记
  void addNewFile(Map<String, dynamic> json) {
    this.files.add(new Files.fromJson(json));
  }

  /// [delFile] 根据[id]删除笔记
  void delFile(String id) {
    this.files.removeWhere((f) => f.id == id);
  }

  /// [delForParentId] 删除整个 List 中 parentId 为 [parentId]的项
  void delForParentId(String parentId) {
    print("要删除的 parentId 为:" + parentId);
    this.files.removeWhere((element) {
      print("处理: " + element.name);
      print("parentId 为: " + element.parentId);
      return element.parentId == parentId;
    });
  }

  /// [delForNotebookId] 删除整个 List 中 notebookId 为 [notebookId]的项
  void delForNotebookId(String notebookId) {
    print("要删除的 notebookId 为:" + notebookId);
    this.files.removeWhere((element) {
      print("处理: " + element.name);
      print("notebookId 为: " + element.notebookId);
      return element.notebookId == notebookId;
    });
  }

  /// [renameFile] 根据 [id] 和 [newName] 重命名笔记
  /// 必须要修改成根据 id 来, 不然缓存下来的笔记中重名就 gg 了
  void renameFile(String id, String newName) {
    List<Files> newList = this.files.map((f) {
      if (f.id == id) {
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

/// [Files] 类就是缓存到本地的笔记
class Files {
  /// [id] 是唯一标识
  String id;

  /// [parentId] 这篇笔记对应的 爸爸文件夹的 id, 用于笔记 tab 的删除
  String parentId;

  /// [parentName] 这篇笔记赌赢的 爸爸文件夹的 name, 用于区分同名文件
  String parentName;

  /// [notebookId] 这篇文章所属笔记本的 id，用于文件夹、笔记本删除时候，级联删除笔记 tab
  String notebookId;

  /// [imageFolderId] 这篇笔记对应的 _v_images 文件夹的 id
  String imageFolderId;

  /// [configId] 是这篇笔记对应的 _vnote.json 文件的 id
  String configId;

  /// [modifiedTime] 这篇笔记的修改时间
  String modifiedTime;

  /// [name] 这篇笔记的名字
  String name;

  Files({this.id, this.modifiedTime, this.name});

  Files.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parentId = json['parent_id'];
    parentName = json['parent_name'];
    notebookId = json['notebook_id'];
    imageFolderId = json['image_folder_id'];
    configId = json['config_id'];
    modifiedTime = json['modified_time'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['parent_id'] = this.parentId;
    data['parent_name'] = this.parentName;
    data['notebook_id'] = this.notebookId;
    data['image_folder_id'] = this.imageFolderId;
    data['config_id'] = this.configId;
    data['modified_time'] = this.modifiedTime;
    data['name'] = this.name;
    return data;
  }
}
