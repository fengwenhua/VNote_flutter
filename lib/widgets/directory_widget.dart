import 'package:flutter/material.dart';
import 'package:vnote/application.dart';
import 'package:vnote/utils/utils.dart';

class DirectoryWidget extends StatefulWidget {
  final String directoryName;
  final DateTime lastModified;
  final VoidCallback onPressedNext;

  DirectoryWidget({
    Key key,
    @required this.directoryName,
    @required this.lastModified,
    this.onPressedNext,
  }) : super(key: key);

  @override
  _DirectoryWidgetState createState() => _DirectoryWidgetState();
}

class _DirectoryWidgetState extends State<DirectoryWidget> {
  @override
  Widget build(BuildContext context) {
    Widget titleWidget = GestureDetector(
      child: Text(widget.directoryName),
      onTap: widget.onPressedNext,
    );
    //Icon folderIcon = Icon(Icons.folder);
    IconButton folderIcon = IconButton(
      icon: Icon(Icons.folder),
      onPressed: () => widget.onPressedNext,
    );

    Widget lastModifiedWidget = GestureDetector(
      child: Text(
        Utils.getFormattedDateTime(dateTime: widget.lastModified),
      ),
      onTap: widget.onPressedNext,
    );

    return Card(
        elevation: 1.0,
        child: ListTile(
          leading: folderIcon,
          title: titleWidget,
          subtitle: lastModifiedWidget,
          onTap: widget.onPressedNext,
        ));
  }
}
