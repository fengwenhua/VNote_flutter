import 'package:flutter/material.dart';

import 'package:vnote/utils/utils.dart';

class FileWidget extends StatelessWidget {
  final String fileName;
  final String parentName;
  final DateTime lastModified;
  final bool isNote;
  final VoidCallback onPressedNext;

  FileWidget(
      {this.parentName,
      @required this.fileName,
      @required this.lastModified,
      this.onPressedNext,
      this.isNote = false});

  @override
  Widget build(BuildContext context) {
    Widget fileNameWidget = Text(this.fileName);
    Widget lastModifiedWidget;
    if (isNote) {
      lastModifiedWidget = Row(
        children: <Widget>[
          Text(Utils.getFormattedDateTime(dateTime: lastModified)),
          Text(" /" + this.parentName + "/")
        ],
      );
    } else {
      lastModifiedWidget = Row(
        children: <Widget>[
          Text(Utils.getFormattedDateTime(dateTime: lastModified)),
        ],
      );
    }

    Icon fileIcon = Icon(Icons.insert_drive_file);

    return Card(
      elevation: 1.0,
      child: ListTile(
        leading: fileIcon,
        title: fileNameWidget,
        subtitle: lastModifiedWidget,
        onTap: onPressedNext,
      ),
    );
  }
}
