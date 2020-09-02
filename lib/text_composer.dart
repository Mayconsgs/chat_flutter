import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  final Function({String text, File imgFile}) sendMessage;

  TextComposer(this.sendMessage);

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  bool _isComposing = false;

  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: <Widget>[
          IconButton(
              icon: Icon(
                Icons.photo_camera,
              ),
              onPressed: () async {
                final File imgFile =
                    await ImagePicker.pickImage(source: ImageSource.camera);
                if (imgFile == null)
                  return;
                else {
                  widget.sendMessage(imgFile: imgFile);
                }
              }),
          Expanded(
            child: TextField(
              decoration: InputDecoration.collapsed(
                hintText: "Enviar uma mensagem",
              ),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                _send(text);
              },
              controller: _controller,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
            ),
            onPressed: _isComposing
                ? () {
                    _send(_controller.text);
                  }
                : null,
          )
        ],
      ),
    );
  }

  void _send(String text) {
    if (_isComposing) {
      widget.sendMessage(text: text);
      _controller.clear();
      setState(() {
        _isComposing = false;
      });
    }
  }
}