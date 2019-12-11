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
    Widget titleWidget = GestureDetector(
      child: Text(directoryName),
      onTap: onPressedNext,
    );
    //Icon folderIcon = Icon(Icons.folder);
    IconButton folderIcon = IconButton(
      icon: Icon(Icons.folder),
      onPressed: onPressedNext,
    );

    Icon expandButton = Icon(Icons.keyboard_arrow_down);

    Widget lastModifiedWidget = GestureDetector(
      child: Text(
        Utils.getFormattedDateTime(dateTime: lastModified),
      ),
      onTap: onPressedNext,
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