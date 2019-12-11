import 'package:meta/meta.dart';

class Document {
  final String id;
  final String name;
  final bool isFile;
  final DateTime dateModified;
  final List<Document> childData;

  Document({
    @required this.id,
    @required this.name,
    @required this.dateModified,
    this.isFile = false,
    this.childData = const <Document>[],
  });
}