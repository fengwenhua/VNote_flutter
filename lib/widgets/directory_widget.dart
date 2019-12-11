import 'package:flutter/material.dart';

import 'package:vnote/utils/utils.dart';

class DirectoryWidget extends StatelessWidget {
  final String directoryName;
  final DateTime lastModified;
  final VoidCallback onPressedNext;

  DirectoryWidget({
    @required this.directoryName,
    @required this.lastModified,
    this.onPressedNext,
  });

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = Text(directoryName);
    Icon folderIcon = Icon(Icons.folder);

    IconButton expandButton = IconButton(
      icon: Icon(Icons.keyboard_arrow_down),
      onPressed: onPressedNext,
    );

    Widget lastModifiedWidget = Text(
      Utils.getFormattedDateTime(dateTime: lastModified),
    );

    return Card(
      child: ListTile(
        leading: folderIcon,
        title: titleWidget,
        subtitle: lastModifiedWidget,
        trailing: expandButton,
      ),
    );
  }
}