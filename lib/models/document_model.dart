import 'package:meta/meta.dart';

class Document {
  final String id;
  final String name;
  final bool isFile;
  final DateTime dateModified;
  final List<Document> childData;
  final Document parent;
  //final List<Document> childFiles;

  Document({
    @required this.id,
    @required this.name,
    this.dateModified,
    this.isFile = false,
    this.parent,
    this.childData,
  //  this.childFiles
  });


}