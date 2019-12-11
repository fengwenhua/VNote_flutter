class OnedriveDataModel {
  String odataContext;
  String odataDeltaLink;
  List<Value> value;

  OnedriveDataModel({this.odataContext, this.odataDeltaLink, this.value});

  OnedriveDataModel.fromJson(Map<String, dynamic> json) {
    odataContext = json['@odata.context'];
    odataDeltaLink = json['@odata.deltaLink'];
    if (json['value'] != null) {
      value = new List<Value>();
      json['value'].forEach((v) {
        value.add(new Value.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['@odata.context'] = this.odataContext;
    data['@odata.deltaLink'] = this.odataDeltaLink;
    if (this.value != null) {
      data['value'] = this.value.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Value {
  String odataType;
  String id;
  String name;
  String lastModifiedDateTime;
  ParentReference parentReference;
  Folder folder;

  Value(
      {this.odataType,
        this.id,
        this.name,
        this.lastModifiedDateTime,
        this.parentReference,
        this.folder});

  Value.fromJson(Map<String, dynamic> json) {
    odataType = json['@odata.type'];
    id = json['id'];
    name = json['name'];
    lastModifiedDateTime = json['lastModifiedDateTime'];
    parentReference = json['parentReference'] != null
        ? new ParentReference.fromJson(json['parentReference'])
        : null;
    folder =
    json['folder'] != null ? new Folder.fromJson(json['folder']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['@odata.type'] = this.odataType;
    data['id'] = this.id;
    data['name'] = this.name;
    data['lastModifiedDateTime'] = this.lastModifiedDateTime;
    if (this.parentReference != null) {
      data['parentReference'] = this.parentReference.toJson();
    }
    if (this.folder != null) {
      data['folder'] = this.folder.toJson();
    }
    return data;
  }
}

class ParentReference {
  String driveId;
  String driveType;
  String id;
  String name;
  String path;

  ParentReference(
      {this.driveId, this.driveType, this.id, this.name, this.path});

  ParentReference.fromJson(Map<String, dynamic> json) {
    driveId = json['driveId'];
    driveType = json['driveType'];
    id = json['id'];
    name = json['name'];
    path = json['path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['driveId'] = this.driveId;
    data['driveType'] = this.driveType;
    data['id'] = this.id;
    data['name'] = this.name;
    data['path'] = this.path;
    return data;
  }
}

class Folder {
  int childCount;
  View view;

  Folder({this.childCount, this.view});

  Folder.fromJson(Map<String, dynamic> json) {
    childCount = json['childCount'];
    view = json['view'] != null ? new View.fromJson(json['view']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['childCount'] = this.childCount;
    if (this.view != null) {
      data['view'] = this.view.toJson();
    }
    return data;
  }
}

class View {
  String viewType;
  String sortBy;
  String sortOrder;

  View({this.viewType, this.sortBy, this.sortOrder});

  View.fromJson(Map<String, dynamic> json) {
    viewType = json['viewType'];
    sortBy = json['sortBy'];
    sortOrder = json['sortOrder'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['viewType'] = this.viewType;
    data['sortBy'] = this.sortBy;
    data['sortOrder'] = this.sortOrder;
    return data;
  }
}
