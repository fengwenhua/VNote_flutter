import 'package:meta/meta.dart';

class Document {
  final String id;
  String name;
  final bool isFile;
  final DateTime dateModified;
  List<Document> childData;
  Document parent;
  String configId;
  String imageFolderId;
  //final List<Document> childFiles;

  Document({
    this.id,
    this.configId,
    @required this.name,
    this.dateModified,
    this.isFile = false,
    this.parent,
    this.childData,
    this.imageFolderId
  //  this.childFiles
  });


}