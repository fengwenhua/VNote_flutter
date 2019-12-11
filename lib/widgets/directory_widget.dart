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
      onTap: (){
        print("点击了大标题");
      },
    );
    //Icon folderIcon = Icon(Icons.folder);
    IconButton folderIcon = IconButton(
      icon: Icon(Icons.folder),
      onPressed: (){
        print("点击了左边的图标");
      },
    );

    IconButton expandButton = IconButton(
      icon: Icon(Icons.keyboard_arrow_down),
      onPressed: onPressedNext,
    );

    Widget lastModifiedWidget = GestureDetector(
      child: Text(
        Utils.getFormattedDateTime(dateTime: lastModified),
      ),
      onTap: (){
        print("点击了子标题");
      },
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