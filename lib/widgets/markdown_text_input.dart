import 'package:flutter/material.dart';
import 'format_markdown.dart';


/// Widget with markdown buttons
class MarkdownTextInput extends StatefulWidget {
  final controller;
  /// Callback called when text changed
  final Function onTextChanged;

  /// Initial value you want to display
  final String initialValue;

  /// Validator for the TextFormField
  final Function validators;

  /// String displayed at hintText in TextFormField
  final String label;

  /// Constructor for [MarkdownTextInput]
  MarkdownTextInput(
      this.controller,
    this.onTextChanged,
    this.initialValue, {
    this.label,
    this.validators,
  });

  @override
  _MarkdownTextInputState createState() => _MarkdownTextInputState();
}

class _MarkdownTextInputState extends State<MarkdownTextInput> {


  void onTap(BuildContext context, MarkdownType type, {int titleSize = 1}) {
    final basePosition = widget.controller.selection.baseOffset;

    FormatMarkdown.convertToMarkdown(
        type, widget.controller.text, widget.controller.selection.baseOffset, widget.controller.selection.extentOffset,context,
        titleSize: titleSize).then((result){
      widget.controller.value = widget.controller.value
          .copyWith(text: result.data, selection: TextSelection.collapsed(offset: basePosition + result.cursorIndex));
    });


  }

  @override
  void initState() {
    widget.controller.text = widget.initialValue;
    widget.controller.addListener(() {
      widget.onTextChanged(widget.controller.text);
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        //border: Border.all(color: Theme.of(context).accentColor, width: 2),
        //borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              textInputAction: TextInputAction.newline,
              maxLines: null,
              expands: true,
              maxLengthEnforced: false,
              enableInteractiveSelection: true,
              controller: widget.controller,
              textCapitalization: TextCapitalization.sentences,
              validator: widget.validators != null ? (value) => widget.validators(value) as String : null,
              cursorColor: Theme.of(context).primaryColor,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).accentColor)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).accentColor)),
                hintText: widget.label,
                hintStyle: const TextStyle(color: Color.fromRGBO(63, 61, 86, 0.5)),
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            ),
          ),
          Material(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  InkWell(
                    key: const Key('bold_button'),
                    onTap: () => onTap(context, MarkdownType.bold),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.format_bold,
                      ),
                    ),
                  ),
                  InkWell(
                    key: const Key('italic_button'),
                    onTap: () => onTap(context, MarkdownType.italic),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.format_italic,
                      ),
                    ),
                  ),
                  InkWell(
                    key: Key('H1_button'),
                    onTap: () => onTap(context, MarkdownType.title, titleSize: 1),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'H1',
                        style: TextStyle(fontSize: (18).toDouble(), fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  InkWell(
                    key: Key('H2_button'),
                    onTap: () => onTap(context, MarkdownType.title, titleSize: 2),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'H2',
                        style: TextStyle(fontSize: (17).toDouble(), fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  InkWell(
                    key: Key('H3_button'),
                    onTap: () => onTap(context, MarkdownType.title, titleSize: 3),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'H3',
                        style: TextStyle(fontSize: (16).toDouble(), fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  InkWell(
                    key: const Key('quote_button'),
                    onTap: () => onTap(context, MarkdownType.quote),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.format_quote,
                      ),
                    ),
                  ),
                  InkWell(
                    key: const Key('code_button'),
                    onTap: () => onTap(context, MarkdownType.code),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.code,
                      ),
                    ),
                  ),
                  InkWell(
                    key: const Key('photo_button'),
                    onTap: () => onTap(context, MarkdownType.photo),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.insert_photo,
                      ),
                    ),
                  ),
                  InkWell(
                    key: const Key('link_button'),
                    onTap: () => onTap(context, MarkdownType.link),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.link,
                      ),
                    ),
                  ),
                  InkWell(
                    key: const Key('list_button'),
                    onTap: () => onTap(context, MarkdownType.list),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.list,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }


}
