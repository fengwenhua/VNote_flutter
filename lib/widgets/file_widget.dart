import 'package:flutter/material.dart';

import 'package:vnote/utils/utils.dart';

class FileWidget extends StatelessWidget {
  final String fileName;
  final DateTime lastModified;
  final VoidCallback onPressedNext;

  FileWidget({@required this.fileName, @required this.lastModified, this.onPressedNext,});

  @override
  Widget build(BuildContext context) {
    Widget fileNameWidget = Text(this.fileName);
    Widget lastModifiedWidget = Text(
      Utils.getFormattedDateTime(dateTime: lastModified),
    );
    Icon fileIcon = Icon(Icons.insert_drive_file);

    return Card(
      elevation: 0.0,
      child: ListTile(
        leading: fileIcon,
        title: fileNameWidget,
        subtitle: lastModifiedWidget,
        onTap: onPressedNext,
      ),
    );
  }
}